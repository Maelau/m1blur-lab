#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│  🔍  M1BLUR - Lab Health Check          │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"

# Check if containers are running
echo -e "${YELLOW}🔍 Checking container status...${NC}"
if docker ps | grep -q m1blur-metasploitable; then
    echo -e "   Metasploitable: ${GREEN}✅ RUNNING${NC}"
else
    echo -e "   Metasploitable: ${RED}❌ NOT RUNNING${NC}"
fi

if docker ps | grep -q m1blur-dvwa; then
    echo -e "   DVWA: ${GREEN}✅ RUNNING${NC}"
else
    echo -e "   DVWA: ${RED}❌ NOT RUNNING${NC}"
fi

echo ""

# Check network connectivity
echo -e "${YELLOW}🔍 Testing connectivity...${NC}"

# Kali to Metasploitable
if ping -c 1 -W 1 172.20.0.20 >/dev/null 2>&1; then
    echo -e "   Kali → Metasploitable (172.20.0.20): ${GREEN}✅ OK${NC}"
else
    echo -e "   Kali → Metasploitable (172.20.0.20): ${RED}❌ FAILED${NC}"
fi

# Kali to DVWA
if ping -c 1 -W 1 172.20.0.30 >/dev/null 2>&1; then
    echo -e "   Kali → DVWA (172.20.0.30): ${GREEN}✅ OK${NC}"
else
    echo -e "   Kali → DVWA (172.20.0.30): ${RED}❌ FAILED${NC}"
fi

# Metasploitable to DVWA
if docker exec m1blur-metasploitable ping -c 1 -W 1 172.20.0.30 >/dev/null 2>&1; then
    echo -e "   Metasploitable → DVWA: ${GREEN}✅ OK${NC}"
else
    echo -e "   Metasploitable → DVWA: ${RED}❌ FAILED${NC}"
fi

echo ""

# Check open ports on Metasploitable
echo -e "${YELLOW}🔍 Checking critical ports on Metasploitable...${NC}"
critical_ports=(21 22 23 80 139 445 3306 6667)
for port in "${critical_ports[@]}"; do
    if nc -zv -w 1 172.20.0.20 $port 2>&1 | grep -q succeeded; then
        echo -e "   Port $port: ${GREEN}✅ OPEN${NC}"
    else
        echo -e "   Port $port: ${RED}❌ CLOSED${NC}"
    fi
done

echo ""

# Check DVWA login page
echo -e "${YELLOW}🔍 Checking DVWA...${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://172.20.0.30/ | grep -q 200; then
    echo -e "   DVWA web interface: ${GREEN}✅ RESPONDING${NC}"
else
    echo -e "   DVWA web interface: ${RED}❌ NOT RESPONDING${NC}"
fi

echo ""
echo -e "${GREEN}✅ Health check complete!${NC}"
