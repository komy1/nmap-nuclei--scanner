#!/bin/bash

OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$OUTPUT_DIR/logs.txt"
}

log_vulnerability() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$OUTPUT_DIR/vulnerabilities.txt"
}

if [ -z "$1" ]; then
   echo "Usage: $0 [-c to clean up] <target-ip> [<target> ...] or $0 -f <target-file>"
   exit 1
fi

if [ "$1" = "-c" ]; then
   echo "Cleaning up output directory..."
   rm -rf "$OUTPUT_DIR"
   echo "Cleanup complete."
   exit 0
fi

process_target() {
  local target="$1"
  log_message "Processing target: $target"
  local target_dir="$OUTPUT_DIR/$target"
  mkdir -p "$target_dir"
  local nmap_file="$target_dir/nmap_ftp.txt"

  log_message "Scanning $target using Nmap for FTP vulnerabilities..."
  nmap -p 21 -sV --script "ftp-vuln*,ftp-anon,ftp-syst,ftp-bounce,ftp-proftpd-backdoor,ftp-vsftpd-backdoor" "$target" -oN "$nmap_file"

  if grep -q "failed to resolve" "$nmap_file" || grep -q "0 hosts up" "$nmap_file"; then
     log_message "Nmap scan failed or no hosts found for $target. Skipping..."
     return 1
  fi

  if ! grep -qE "21/tcp\s+open" "$nmap_file"; then
     log_message "FTP port is not open on $target"
     return 1
  fi

  local vulnerable=0

  if grep -Eqi "VULNERABLE|backdoor|exploitable|insecure|misconfigured" "$nmap_file"; then
    log_vulnerability "Critical FTP vulnerabilities detected on $target! See $nmap_file for details."
    vulnerable=1
  fi

  if grep -Eqi "drwxrwxrwx|writable" "$nmap_file"; then
    log_vulnerability "World-writable FTP directories detected on $target. Check permissions."
    vulnerable=1
  fi

  if grep -Eqi "Plaintext authentication" "$nmap_file"; then
    log_vulnerability "Plaintext FTP authentication detected on $target. Credentials may be exposed."
    vulnerable=1
  fi

  if grep -Eqi "FTP bounce attack" "$nmap_file"; then
    log_vulnerability "FTP bounce attack possible on $target."
    vulnerable=1
  fi

  if grep -Eqi "vsftpd backdoor" "$nmap_file"; then
    log_vulnerability "Backdoor detected in vsFTPd on $target. Upgrade the FTP server immediately."
    vulnerable=1
  fi  

  if [ "$vulnerable" -eq 1 ]; then
     run_nuclei "$target"
  fi

  log_message "Processing completed for $target"
}

run_nuclei() {
  local target="$1"
  local target_dir="$OUTPUT_DIR/$target"
  local nuclei_file="$target_dir/nuclei_ftp.txt"

  log_message "Running nuclei on $target..."
  nuclei -target "$target" -t cves/ -o "$nuclei_file"

  if [ -s "$nuclei_file" ]; then
    log_vulnerability "Nuclei detected issues on $target. See $nuclei_file for details."
  else
    log_message "No issues detected on $target using nuclei."
  fi
}

# Handle -f for file input
if [ "$1" = "-f" ]; then
   if [ -z "$2" ] || [ ! -f "$2" ]; then
      echo "Error: File '$2' not found or not specified."
      exit 1
   fi 
   readarray -t TARGETS < "$2"
   shift 2
   TARGETS+=("$@")
else
   TARGETS=("$@")
fi

# Dependency checks
if ! command -v nmap &> /dev/null; then
  echo "nmap is not installed. Please install it first."
  exit 1
fi

if ! command -v nuclei &> /dev/null; then
  echo "nuclei is not installed. Please install it first."
  exit 1
fi

# Process targets
for TARGET in "${TARGETS[@]}"; do
    process_target "$TARGET"
done

# Display vulnerabilities summary
if [ -f "$OUTPUT_DIR/vulnerabilities.txt" ]; then
   echo -e "\n======================[ VULNERABILITIES FOUND ]======================"
   cat "$OUTPUT_DIR/vulnerabilities.txt"
   echo "====================================================================="
else
   echo -e "\nNo vulnerabilities detected on any target."
fi

log_message "All targets processed. Script complete. Exiting."
