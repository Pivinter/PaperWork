# Contributing Guide

Дякуємо за інтерес до проекту! Цей файл містить рекомендації для контрибюторів.

## Як зробити внесок

### 1. Fork та Clone

```bash
# Fork репозиторій через GitHub UI
# Потім клонуйте свій fork
git clone https://github.com/your-username/task-management-system.git
cd task-management-system
```

### 2. Створіть гілку

```bash
git checkout -b feature/your-feature-name
# або
git checkout -b fix/bug-description
```

### 3. Внесіть зміни

Дотримуйтесь структури проекту та стилю коду.

### 4. Тестуйте

```bash
# Запустіть локально
docker compose up -d

# Перевірте, що все працює
make health
make api-test

# Запустіть тести
cd backend && npm test
cd frontend && npm run build
```

### 5. Commit

Використовуйте чіткі commit messages:

```bash
git add .
git commit -m "feat: додати фільтрацію за датою"
# або
git commit -m "fix: виправити помилку в API endpoint"
```

### Формат commit messages:

- `feat:` - нова функціональність
- `fix:` - виправлення помилки
- `docs:` - зміни в документації
- `style:` - форматування, пропущені крапки з комою тощо
- `refactor:` - рефакторинг коду
- `test:` - додавання тестів
- `chore:` - оновлення build процесу, залежностей тощо

### 6. Push та Pull Request

```bash
git push origin feature/your-feature-name
```

Створіть Pull Request через GitHub UI.

## Coding Standards

### JavaScript/Vue

- Використовуйте ES6+ синтаксис
- 2 spaces для індентації
- Semicolons обов'язкові
- Осмислені назви змінних та функцій
- Коментарі для складної логіки

### Vue Components

- Single File Components (.vue)
- Composition API preferred
- Props validation
- Emits declaration

### API Design

- RESTful principles
- HTTP status codes
- JSON responses
- Input validation
- Error handling

### Docker

- Multi-stage builds
- Non-root users
- Health checks
- .dockerignore files

## Тестування

Перед створенням PR:

```bash
# 1. Локальні тести
make test

# 2. Збірка Docker образів
make build

# 3. Інтеграційні тести
make up
make health
make api-test

# 4. Перевірка логів
make logs
```

## Документація

Оновлюйте документацію при необхідності:
- README.md - загальна інформація
- API endpoints - в README
- CHANGELOG.md - опис змін
- Коментарі в коді

## Код ревʼю

Всі PR проходять code review:
- CI/CD checks мають пройти ✅
- Мінімум 1 approval required
- Без merge conflicts

## Питання?

- Створіть Issue на GitHub
- Напишіть в Discussions
- Email автору проекту

## License

Внесками ви погоджуєтесь, що ваш код буде ліцензовано під тією ж ліцензією, що й проект.
