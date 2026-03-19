# Docker Configuration for M1BLUR

## Services
- **Metasploitable2** : 172.20.0.20 (FTP, SSH, HTTP, SMB, MySQL...)
- **DVWA** : 172.20.0.30 (Damn Vulnerable Web Application)
- **DVWA-DB** : 172.20.0.31 (MySQL Database)

## Commands
```bash
# Start the lab
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Stop
docker compose down
