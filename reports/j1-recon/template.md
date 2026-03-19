# Reconnaissance Report - Day 1

## General Information
- **Date**: Thursday 19 March 2026
- **Target**: Metasploitable2 (172.22.0.20)
- **Author**: Laurent Zang

## Executive Summary
Initial reconnaissance on target 172.22.0.20 revealed 8 open ports including critical services such as SMB (445), HTTP (80), FTP (2121), and MySQL (3306).
Service version enumeration identified Samba 3.0.20, Apache 2.2.8, and ProFTPD 1.3.1.
Three critical vulnerabilities were prioritized for Day 2 exploitation: Samba usermap script (CVE-2007-2447), distccd (CVE-2004-2687),
and multiple Apache vulnerabilities.

## Network Scan
### Full Nmap Scan
nmap -sS -p- --min-rate 1000 172.22.0.20

PORT STATE SERVICE
25/tcp open smtp
80/tcp open http
139/tcp open netbios-ssn
445/tcp open microsoft-ds
2121/tcp open ccproxy-ftp
3306/tcp open mysql
3632/tcp open distccd
5432/tcp open postgresql

### Detailed Service Scan
nmap -sC -sV -p 25,80,139,445,2121,3306,3632,5432 172.22.0.20

PORT STATE SERVICE VERSION
25/tcp open smtp Postfix smtpd
80/tcp open http Apache httpd 2.2.8 ((Ubuntu) DAV/2)
139/tcp open netbios-ssn Samba smbd 3.X - 4.X
445/tcp open netbios-ssn Samba smbd 3.0.20-Debian
2121/tcp open ftp ProFTPD 1.3.1
3306/tcp open mysql MySQL 5.0.51a-3ubuntu5
3632/tcp open distccd distccd v1 ((GNU) 4.2.4)
5432/tcp open postgresql PostgreSQL DB 8.3.0 - 8.3.7


### Open Ports
| Port | Service | Version | Status |
|------|---------|---------|--------|
| 25 | SMTP | Postfix | open |
| 80 | HTTP | Apache 2.2.8 | open |
| 139 | SMB | Samba 3.x | open |
| 445 | SMB | Samba 3.0.20 | open |
| 2121 | FTP | ProFTPD 1.3.1 | open |
| 3306 | MySQL | MySQL 5.0.51a | open |
| 3632 | distcc | distccd v1 | open |
| 5432 | PostgreSQL | PostgreSQL 8.3 | open |

## Enumeration
### SMB (enum4linux)
enum4linux -a 172.22.0.20

[Summary]

    Workgroup: WORKGROUP

    Domain: METASPLOITABLE

    OS: Unix

    Users found: root, msfadmin, user, postgres, syslog, etc.

    Shares found: tmp, opt, IPC$

    SMB signing: disabled (dangerous)

### FTP Anonymous ?
nc -nv 172.22.0.20 2121
(UNKNOWN) [172.22.0.20] 2121 (?) open
220 ProFTPD 1.3.1 Server (Debian)
USER anonymous
331 Anonymous login ok, send your complete email address as your password
PASS test@test.com
230 Anonymous access granted, restrictions apply
SYST
215 UNIX Type: L8
Result: ✅ Anonymous FTP login allowed

### Web Directories (gobuster)
gobuster dir -u http://172.22.0.20 -w ~/m1blur-lab/wordlists/common.txt

/.htaccess (Status: 403)
/.htpasswd (Status: 403)
/cgi-bin/ (Status: 403)
/dav (Status: 301)
/doc (Status: 301)
/icons/ (Status: 200)
/index (Status: 200)
/phpMyAdmin (Status: 301)
/test (Status: 200)
/twiki (Status: 301)

## Service Fingerprinting
### Banner Grabbing
FTP (2121): 220 ProFTPD 1.3.1 Server (Debian)
HTTP (80): Apache/2.2.8 (Ubuntu) DAV/2
SMB (445): Samba 3.0.20-Debian
MySQL (3306): 5.0.51a-3ubuntu5
distcc (3632): distccd v1

## Vulnerability Research
| CVE | CVSS | Service | Description | Exploit Available |
|-----|------|---------|-------------|-------------------|
| CVE-2007-2447 | 10.0 | Samba 3.0.20 | Samba usermap script command execution | Yes (Metasploit) |
| CVE-2004-2687 | 9.8 | distccd v1 | distccd command execution | Yes (Metasploit) |
| Multiple | 7.5+ | Apache 2.2.8 | Multiple Apache vulnerabilities | Yes |
| CVE-2008-0227 | 7.5 | ProFTPD 1.3.1 | ProFTPD directory traversal | Yes |

## Attack Plan for Day 2
1. Exploit Samba usermap script (CVE-2007-2447) on port 445 to gain initial access
2. Alternative: Exploit distccd (CVE-2004-2687) on port 3632
3. After initial access, perform privilege escalation if needed
4. Dump password hashes from /etc/shadow
5. Crack passwords using John/Hashcat

## Attachments
- [scan-rapide.txt]
- [scan-detail.txt]
- [enum4linux.txt]
- [gobuster.txt]
