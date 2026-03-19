#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│  🧹  M1BLUR - Lab Cleanup                │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"

cd "$(dirname "$0")/../docker"

# Stop containers
echo -e "${YELLOW}🛑 Stopping containers...${NC}"
docker compose down

# Ask for volumes
echo ""
read -p "❓ Delete volumes as well (data will be lost)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🗑️  Removing volumes...${NC}"
    docker compose down -v
    echo -e "${GREEN}✅ Volumes removed${NC}"
fi

# Ask for network
read -p "❓ Delete lab-network? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🗑️  Removing network...${NC}"
    docker network rm lab-network 2>/dev/null
    echo -e "${GREEN}✅ Network removed${NC}"
fi

echo ""
echo -e "${GREEN}✅ CLEANUP COMPLETE${NC}"
