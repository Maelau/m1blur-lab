#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│  📥  M1BLUR - Download Wordlists        │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"

# Create wordlists directory if it doesn't exist
mkdir -p "$(dirname "$0")/../wordlists"
cd "$(dirname "$0")/../wordlists"

# Function to download with progress
download() {
    local url=$1
    local output=$2
    echo -ne "${YELLOW}   Downloading $output...${NC}"
    if wget -q --show-progress "$url" -O "$output" 2>&1; then
        echo -e "${GREEN} Done ✅${NC}"
    else
        # Try without progress if wget version doesn't support --show-progress
        if wget -q "$url" -O "$output" 2>/dev/null; then
            echo -e "${GREEN} Done ✅${NC}"
        else
            echo -e "${RED} Failed ❌${NC}"
        fi
    fi
}

echo -e "${BLUE}📦 Downloading essential wordlists...${NC}"
echo ""

# SecLists (small samples)
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt" "common.txt"
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-small.txt" "dir-small.txt"
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" "subdomains.txt"

# Fuzzing wordlists
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/LFI/LFI-Jhaddix.txt" "lfi.txt"
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/SQLi/Generic-SQLi.txt" "sqli.txt"
download "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/XSS/XSS-BruteLogic.txt" "xss.txt"

# Passwords
echo -e "${YELLOW}   Note: rockyou.txt is large (134MB). Download?${NC}"
read -p "   Download rockyou.txt? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    download "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt" "rockyou.txt"
fi

# Create custom small wordlist
echo -e "${BLUE}📝 Creating custom wordlist...${NC}"
cat > custom.txt << 'EOL'
admin
root
password
123456
password123
admin123
root123
test
user
guest
backup
support
webmaster
kali
msfadmin
postgres
mysql
oracle
tomcat
manager
letmein
qwerty
abc123
monkey
dragon
master
hello
secret
changeme
administrator
EOL
echo -e "${GREEN}   custom.txt created ✅${NC}"

# Show results
echo ""
echo -e "${GREEN}📊 Wordlists downloaded:${NC}"
ls -lh | awk '{print "   " $9 " (" $5 ")"}'

echo ""
echo -e "${GREEN}✅ Download complete!${NC}"
echo -e "${BLUE}📁 Location: $(pwd)${NC}"
