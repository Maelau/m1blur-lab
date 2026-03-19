#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}┌─────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│  🔄  M1BLUR - Reset Lab to Clean State   │${NC}"
echo -e "${BLUE}└─────────────────────────────────────────┘${NC}"

echo -e "${RED}⚠️  WARNING: This will destroy all containers and data!${NC}"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Reset cancelled.${NC}"
    exit 0
fi

echo -e "${YELLOW}🛑 Stopping containers...${NC}"
cd "$(dirname "$0")/../docker"
docker compose down -v

echo -e "${YELLOW}🗑️  Removing network...${NC}"
docker network rm lab-network 2>/dev/null

echo -e "${YELLOW}🚀 Starting fresh lab...${NC}"
cd ../scripts
./init-lab.sh

echo -e "${GREEN}✅ Lab has been reset to clean state!${NC}"
