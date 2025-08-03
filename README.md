# nmap&nuclei_scanner
-Scan for as many vulnerabilities as possible using Nmap and Nuclei 
-Handle multiple targets or files 
-Log vulnerabilities, errors, and summaries
usage:-
chmod +x recon.sh
./recon.sh 192.168.1.10 192.168.1.20          # Scan multiple IPs
./recon.sh -f targets.txt                     # Scan from a list
./recon.sh -c                                 # Clean output directory
#### you can modify script check more ftp to detect more vulnerabilities or use other ports to make full scan 
