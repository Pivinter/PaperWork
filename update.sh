#!/bin/bash

# 🔄 Simple Update Script
# Ручне оновлення системи одним скриптом

set -e

# Кольори
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔄 Task Management System - Update${NC}"
echo ""

# Перевірити, чи є оновлення в Git
echo -e "${BLUE}1. Checking Git repository...${NC}"
git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo -e "${GREEN}✅ New commits found. Pulling changes...${NC}"
    git pull origin main
else
    echo -e "${YELLOW}📝 Repository is up to date${NC}"
fi

# Використати правильний compose file
if [ -f "docker-compose.prod.yml" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
    echo -e "${BLUE}Using production compose file${NC}"
else
    COMPOSE_FILE="docker-compose.yml"
    echo -e "${BLUE}Using development compose file${NC}"
fi

# Стягнути нові Docker образи
echo ""
echo -e "${BLUE}2. Pulling Docker images from Docker Hub...${NC}"
docker compose -f ${COMPOSE_FILE} pull

# Перезапустити контейнери
echo ""
echo -e "${BLUE}3. Restarting containers...${NC}"
docker compose -f ${COMPOSE_FILE} down
docker compose -f ${COMPOSE_FILE} up -d

# Почекати запуску
echo ""
echo -e "${BLUE}4. Waiting for services to start...${NC}"
sleep 10

# Health checks
echo ""
echo -e "${BLUE}5. Health checks...${NC}"

if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Backend is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Backend health check failed (may still be starting)${NC}"
fi

if curl -f http://localhost:8080 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Frontend is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend health check failed (may still be starting)${NC}"
fi

# Показати статус
echo ""
echo -e "${BLUE}6. Container status:${NC}"
docker compose -f ${COMPOSE_FILE} ps

# Очистити старі образи
echo ""
echo -e "${BLUE}7. Cleaning up old images...${NC}"
docker image prune -f

echo ""
echo -e "${GREEN}✨ Update completed!${NC}"
echo -e "${YELLOW}🌐 Frontend: http://localhost:8080${NC}"
echo -e "${YELLOW}🔌 Backend:  http://localhost:3000${NC}"
