#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│  🚀  M1BLUR - Lab Initialization        │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"

# Check Docker
echo -ne "${YELLOW}🔍 Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌\nDocker is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅${NC}"

# Check Docker Compose
echo -ne "${YELLOW}🔍 Checking Docker Compose...${NC}"
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌\nDocker Compose is not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅${NC}"

# Create network
echo -ne "${YELLOW}📡 Setting up network...${NC}"
if ! docker network inspect lab-network >/dev/null 2>&1; then
    docker network create --subnet=172.20.0.0/16 lab-network >/dev/null 2>&1
    echo -e "${GREEN}✅ (created)${NC}"
else
    echo -e "${GREEN}✅ (already exists)${NC}"
fi

# Start containers
echo -e "${YELLOW}🐳 Starting containers...${NC}"
cd "$(dirname "$0")/../docker"
docker compose up -d

# Wait for containers to be ready
echo -ne "${YELLOW}⏳ Waiting for startup...${NC}"
sleep 5
echo -e "${GREEN}✅${NC}"

# Display information
echo ""
echo -e "${GREEN}📋 AVAILABLE TARGETS:${NC}"
echo -e "${BLUE}─────────────────────────${NC}"
echo -e " Metasploitable : ${GREEN}http://172.20.0.20/${NC}"
echo -e " DVWA           : ${GREEN}http://172.20.0.30/${NC} (admin/password)"
echo ""

# Test connectivity
echo -e "${YELLOW}🔄 CONNECTIVITY TEST:${NC}"
echo -e "${BLUE}─────────────────────────${NC}"

# Test Metasploitable → DVWA
if docker exec m1blur-metasploitable ping -c 1 172.20.0.30 >/dev/null 2>&1; then
    echo -e " Metasploitable → DVWA : ${GREEN}✅ OK${NC}"
else
    echo -e " Metasploitable → DVWA : ${RED}❌ FAILED${NC}"
fi

# Test Kali → Metasploitable
if ping -c 1 172.20.0.20 >/dev/null 2>&1; then
    echo -e " Kali → Metasploitable  : ${GREEN}✅ OK${NC}"
else
    echo -e " Kali → Metasploitable  : ${RED}❌ FAILED${NC}"
fi

# Test Kali → DVWA
if ping -c 1 172.20.0.30 >/dev/null 2>&1; then
    echo -e " Kali → DVWA            : ${GREEN}✅ OK${NC}"
else
    echo -e " Kali → DVWA            : ${RED}❌ FAILED${NC}"
fi

echo ""
echo -e "${GREEN}✅ LAB IS READY!${NC}"
echo -e "${BLUE}📝 Logs: docker compose -f ../docker/docker-compose.yml logs -f${NC}"
