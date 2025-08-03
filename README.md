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
Output_sample:-
[WRN] Found 1 template[s] loaded with deprecated paths, update before v3 for continued support.
[INF] Current nuclei version: v3.4.6 (outdated)
[INF] Current nuclei-templates version: v10.2.6 (latest)
[WRN] Scan results upload to cloud is disabled.
[INF] New templates added in latest release: 41
[INF] Templates loaded for current scan: 3143
[INF] Executing 3140 signed templates from projectdiscovery/nuclei-templates
[WRN] Loading 3 unsigned templates for scan. Use with caution.
[INF] Targets loaded for current scan: 1
[INF] Running httpx on input host
[INF] Found 1 URL from httpx
[INF] Templates clustered: 20 (Reduced 12 Requests)
[CVE-2012-1823] [http] [high] http://192.168.190.129/index.php?-d+allow_url_include%3don+-d+auto_prepend_file%3dphp%3a//input
[INF] Using Interactsh Server: oast.live
[INF] Scan completed in 51.365038776s. 1 matches found.
[2025-08-02 20:16:40] Nuclei detected issues on 192.168.190.129. See output/192.168.190.129/nuclei_ftp.txt for details.
[2025-08-02 20:16:40] Processing completed for 192.168.190.129

======================[ VULNERABILITIES FOUND ]======================
[2025-08-02 19:45:53] ⚠ Critical FTP vulnerabilities detected on 192.168.190.129! See output/192.168.190.129/nmap_ftp.txt for details.
