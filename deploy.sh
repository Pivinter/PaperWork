#!/bin/bash

# Скрипт для швидкого розгортання системи

set -e

# Кольори
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║     Task Management System - Deploy Script            ║"
echo "║     Розгортання інформаційної системи                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Перевірка наявності Docker
echo -e "${YELLOW}[1/6] Перевірка Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker не встановлено!${NC}"
    echo "Встановіть Docker: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓ Docker встановлено: $(docker --version)${NC}"

# Перевірка Docker Compose
echo -e "${YELLOW}[2/6] Перевірка Docker Compose...${NC}"
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose не встановлено!${NC}"
    echo "Встановіть Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose встановлено: $(docker compose version)${NC}"

# Зупинка старих контейнерів
echo -e "${YELLOW}[3/6] Зупинка старих контейнерів...${NC}"
docker compose down 2>/dev/null || true
echo -e "${GREEN}✓ Старі контейнери зупинено${NC}"

# Збірка образів
echo -e "${YELLOW}[4/6] Збірка Docker образів...${NC}"
docker compose build
echo -e "${GREEN}✓ Образи зібрано${NC}"

# Запуск сервісів
echo -e "${YELLOW}[5/6] Запуск сервісів...${NC}"
docker compose up -d
echo -e "${GREEN}✓ Сервіси запущено${NC}"

# Очікування готовності сервісів
echo -e "${YELLOW}[6/6] Очікування готовності сервісів...${NC}"
echo -n "  Перевірка backend"
for i in {1..30}; do
    if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

echo -n "  Перевірка frontend"
for i in {1..30}; do
    if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Виведення інформації
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Система успішно розгорнута! 🚀                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Доступ до сервісів:${NC}"
echo -e "  📱 Frontend:   ${GREEN}http://localhost:8080${NC}"
echo -e "  🔧 Backend:    ${GREEN}http://localhost:3000${NC}"
echo -e "  💚 Health:     ${GREEN}http://localhost:3000/health${NC}"
echo -e "  🗄️  Database:   ${GREEN}localhost:5432${NC}"
echo ""
echo -e "${BLUE}Корисні команди:${NC}"
echo -e "  📋 Переглянути логи:     ${YELLOW}docker compose logs -f${NC}"
echo -e "  ⏹️  Зупинити:            ${YELLOW}docker compose stop${NC}"
echo -e "  🔄 Перезапустити:        ${YELLOW}docker compose restart${NC}"
echo -e "  🗑️  Видалити:            ${YELLOW}docker compose down -v${NC}"
echo -e "  📊 Статус:               ${YELLOW}docker compose ps${NC}"
echo ""
echo -e "${BLUE}Тестування API:${NC}"
echo -e "  curl -X POST http://localhost:3000/api/tasks \\"
echo -e "    -H 'Content-Type: application/json' \\"
echo -e "    -d '{\"title\":\"Test\",\"priority\":\"high\"}'"
echo ""
echo -e "${GREEN}Готово! Відкрийте браузер на http://localhost:8080${NC}"
echo ""
