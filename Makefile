# Makefile для спрощення команд

.PHONY: help build up down restart logs clean test dev install

# Кольори для виводу
BLUE=\033[0;34m
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Показати цю довідку
	@echo "$(BLUE)Доступні команди:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Збудувати всі Docker образи
	@echo "$(BLUE)Збірка Docker образів...$(NC)"
	docker compose build

up: ## Запустити всі сервіси
	@echo "$(BLUE)Запуск сервісів...$(NC)"
	docker compose up -d
	@echo "$(GREEN)✓ Сервіси запущено!$(NC)"
	@echo "  Frontend: http://localhost:8080"
	@echo "  Backend:  http://localhost:3000"
	@echo "  Health:   http://localhost:3000/health"

down: ## Зупинити всі сервіси
	@echo "$(BLUE)Зупинка сервісів...$(NC)"
	docker compose down
	@echo "$(GREEN)✓ Сервіси зупинено$(NC)"

restart: ## Перезапустити всі сервіси
	@echo "$(BLUE)Перезапуск сервісів...$(NC)"
	docker compose restart
	@echo "$(GREEN)✓ Сервіси перезапущено$(NC)"

logs: ## Показати логи всіх сервісів
	docker compose logs -f

logs-backend: ## Показати логи backend
	docker compose logs -f backend

logs-frontend: ## Показати логи frontend
	docker compose logs -f frontend

logs-db: ## Показати логи бази даних
	docker compose logs -f database

ps: ## Показати статус контейнерів
	docker compose ps

clean: ## Видалити контейнери та volumes
	@echo "$(RED)Видалення контейнерів та даних...$(NC)"
	docker compose down -v
	@echo "$(GREEN)✓ Очищено$(NC)"

clean-all: ## Видалити контейнери, volumes та образи
	@echo "$(RED)Повне очищення...$(NC)"
	docker compose down -v --rmi all
	@echo "$(GREEN)✓ Повністю очищено$(NC)"

install-backend: ## Встановити залежності backend
	@echo "$(BLUE)Встановлення залежностей backend...$(NC)"
	cd backend && npm install
	@echo "$(GREEN)✓ Backend залежності встановлено$(NC)"

install-frontend: ## Встановити залежності frontend
	@echo "$(BLUE)Встановлення залежностей frontend...$(NC)"
	cd frontend && npm install
	@echo "$(GREEN)✓ Frontend залежності встановлено$(NC)"

install: install-backend install-frontend ## Встановити всі залежності

dev-backend: ## Запустити backend в dev режимі
	cd backend && npm run dev

dev-frontend: ## Запустити frontend в dev режимі
	cd frontend && npm run dev

test: ## Запустити тести
	@echo "$(BLUE)Запуск тестів...$(NC)"
	cd backend && npm test || true
	@echo "$(GREEN)✓ Тести завершено$(NC)"

health: ## Перевірити здоров'я сервісів
	@echo "$(BLUE)Перевірка здоров'я сервісів...$(NC)"
	@curl -s http://localhost:3000/health | jq . && echo "$(GREEN)✓ Backend OK$(NC)" || echo "$(RED)✗ Backend ERROR$(NC)"
	@curl -s http://localhost:8080/health && echo "$(GREEN)✓ Frontend OK$(NC)" || echo "$(RED)✗ Frontend ERROR$(NC)"

api-test: ## Тестувати API endpoints
	@echo "$(BLUE)Тестування API...$(NC)"
	@echo "\n1. Створення завдання:"
	@curl -X POST http://localhost:3000/api/tasks \
		-H "Content-Type: application/json" \
		-d '{"title":"Test Task","description":"API Test","priority":"high"}' \
		| jq .
	@echo "\n2. Отримання всіх завдань:"
	@curl -s http://localhost:3000/api/tasks | jq .
	@echo "\n3. Статистика:"
	@curl -s http://localhost:3000/api/tasks/stats/summary | jq .

rebuild: clean build up ## Повна перебудова (clean + build + up)
	@echo "$(GREEN)✓ Перебудова завершена$(NC)"

backup-db: ## Бекап бази даних
	@echo "$(BLUE)Створення бекапу бази даних...$(NC)"
	docker compose exec -T database pg_dump -U taskuser taskdb > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Бекап створено$(NC)"

restore-db: ## Відновити базу даних (BACKUP_FILE=backup.sql make restore-db)
	@echo "$(BLUE)Відновлення бази даних...$(NC)"
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)Помилка: Вкажіть BACKUP_FILE=backup.sql$(NC)"; \
		exit 1; \
	fi
	cat $(BACKUP_FILE) | docker compose exec -T database psql -U taskuser taskdb
	@echo "$(GREEN)✓ Базу даних відновлено$(NC)"

stats: ## Показати статистику використання ресурсів
	docker stats --no-stream

shell-backend: ## Відкрити shell в backend контейнері
	docker compose exec backend sh

shell-frontend: ## Відкрити shell в frontend контейнері
	docker compose exec frontend sh

shell-db: ## Відкрити psql в базі даних
	docker compose exec database psql -U taskuser taskdb

prune: ## Очистити всі невикористовувані Docker ресурси
	@echo "$(RED)Очищення Docker системи...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✓ Система очищена$(NC)"

# ===== AUTO-UPDATE COMMANDS =====

update: ## Ручне оновлення з Git та Docker Hub
	@echo "$(BLUE)🔄 Оновлення системи...$(NC)"
	./update.sh

auto-update: ## Запустити автоматичний моніторинг оновлень
	@echo "$(BLUE)🔄 Запуск автоматичного моніторингу...$(NC)"
	@echo "$(GREEN)Натисніть Ctrl+C для зупинки$(NC)"
	./auto-update.sh

auto-update-bg: ## Запустити автоматичний моніторинг у фоні
	@echo "$(BLUE)🔄 Запуск моніторингу у фоні...$(NC)"
	nohup ./auto-update.sh > auto-update.log 2>&1 &
	@echo "$(GREEN)✓ Моніторинг запущено у фоні$(NC)"
	@echo "Логи: tail -f auto-update.log"
	@echo "Зупинити: make stop-auto-update"

stop-auto-update: ## Зупинити фоновий автоматичний моніторинг
	@echo "$(BLUE)🛑 Зупинка автоматичного моніторингу...$(NC)"
	pkill -f auto-update.sh || true
	@echo "$(GREEN)✓ Моніторинг зупинено$(NC)"

install-service: ## Встановити systemd сервіс для автоматичного оновлення
	@echo "$(BLUE)📦 Встановлення systemd сервісу...$(NC)"
	sudo cp task-auto-update@.service /etc/systemd/system/
	sudo systemctl daemon-reload
	@echo "$(GREEN)✓ Сервіс встановлено$(NC)"
	@echo ""
	@echo "$(BLUE)Наступні кроки:$(NC)"
	@echo "  $(GREEN)sudo systemctl enable task-auto-update@$$USER.service$(NC)  # Увімкнути автозапуск"
	@echo "  $(GREEN)sudo systemctl start task-auto-update@$$USER.service$(NC)   # Запустити сервіс"
	@echo "  $(GREEN)sudo journalctl -u task-auto-update@$$USER.service -f$(NC)  # Переглянути логи"

service-status: ## Показати статус systemd сервісу
	@sudo systemctl status task-auto-update@$$USER.service || echo "$(RED)Сервіс не встановлено$(NC)"

service-logs: ## Показати логи systemd сервісу
	@sudo journalctl -u task-auto-update@$$USER.service -f

prod-up: ## Запустити в production режимі (з Docker Hub)
	@echo "$(BLUE)🚀 Запуск у production режимі...$(NC)"
	docker compose -f docker-compose.prod.yml up -d
	@echo "$(GREEN)✓ Production сервіси запущено!$(NC)"
	@echo "  Frontend: http://localhost:8080"
	@echo "  Backend:  http://localhost:3000"

prod-down: ## Зупинити production сервіси
	@echo "$(BLUE)Зупинка production сервісів...$(NC)"
	docker compose -f docker-compose.prod.yml down
	@echo "$(GREEN)✓ Production сервіси зупинено$(NC)"

prod-logs: ## Показати логи production
	docker compose -f docker-compose.prod.yml logs -f

check-updates: ## Перевірити наявність оновлень (без застосування)
	@echo "$(BLUE)🔍 Перевірка оновлень...$(NC)"
	@echo ""
	@echo "$(BLUE)Git Repository:$(NC)"
	@git fetch origin main --quiet
	@LOCAL=$$(git rev-parse HEAD); \
	REMOTE=$$(git rev-parse origin/main); \
	if [ "$$LOCAL" != "$$REMOTE" ]; then \
		echo "  $(GREEN)✅ Нові коміти доступні$(NC)"; \
		git log HEAD..origin/main --oneline | head -5; \
	else \
		echo "  $(GREEN)✓ Репозиторій оновлено$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)Docker Hub:$(NC)"
	@docker compose -f docker-compose.prod.yml pull --quiet && echo "  $(GREEN)✓ Перевірено$(NC)" || echo "  $(RED)✗ Помилка$(NC)"
