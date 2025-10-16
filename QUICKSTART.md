# Швидкий старт 🚀

## Передумови
- Docker >= 24.0
- Docker Compose >= 2.0
- Git

## Запуск за 3 кроки

### 1. Клонування та перехід до проекту
```bash
git clone <your-repo-url>
cd task-management-system
```

### 2. Запуск системи
```bash
docker compose up -d
```

### 3. Перевірка
- Frontend: http://localhost:8080
- Backend: http://localhost:3000
- Health: http://localhost:3000/health

## Корисні команди

```bash
# Перегляд логів
docker compose logs -f

# Зупинка
docker compose stop

# Перезапуск
docker compose restart

# Повне видалення (включаючи дані)
docker compose down -v
```

## Перевірка роботи API

```bash
# Створити тестове завдання
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Тестове завдання",
    "description": "Перевірка API",
    "priority": "high",
    "status": "pending"
  }'

# Отримати всі завдання
curl http://localhost:3000/api/tasks

# Статистика
curl http://localhost:3000/api/tasks/stats/summary
```

## Розробка

### Backend (з hot-reload)
```bash
cd backend
npm install
npm run dev
```

### Frontend (з hot-reload)
```bash
cd frontend
npm install
npm run dev
```

Frontend dev server: http://localhost:5173

## Проблеми?

### Порт зайнятий
Змініть порти в `docker-compose.yml`:
```yaml
ports:
  - "8081:80"    # Frontend
  - "3001:3000"  # Backend
```

### База даних не підключається
```bash
# Перевірте статус
docker compose ps

# Переглянте логи
docker compose logs database

# Пересоздайте з очисткою
docker compose down -v
docker compose up -d
```

### Помилки збірки
```bash
# Очистіть Docker кеш
docker system prune -a

# Пересоберіть образи
docker compose build --no-cache
docker compose up -d
```

## Потрібна допомога?
Див. повний [README.md](./README.md)
