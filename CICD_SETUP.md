# Налаштування CI/CD з GitHub Actions

## Крок 1: Підготовка репозиторію

1. Створіть новий репозиторій на GitHub
2. Завантажте код проекту:

```bash
cd /шлях/до/проекту
git init
git add .
git commit -m "Initial commit: Task Management System"
git branch -M main
git remote add origin https://github.com/username/task-management-system.git
git push -u origin main
```

## Крок 2: Налаштування Docker Hub (опціонально)

Якщо хочете публікувати образи на Docker Hub:

1. Створіть обліковий запис на https://hub.docker.com/
2. Створіть Access Token:
   - Settings → Security → New Access Token
   - Назва: `github-actions-token`
   - Скопіюйте згенерований token

## Крок 3: Додавання GitHub Secrets

1. Перейдіть у налаштування репозиторію:
   `Settings` → `Secrets and variables` → `Actions`

2. Додайте наступні secrets:
   - `DOCKER_USERNAME` - ваш Docker Hub username
   - `DOCKER_PASSWORD` - згенерований Access Token

**Скріншот процесу:**
```
Settings → Secrets and variables → Actions → New repository secret
```

## Крок 4: Перевірка Pipeline

1. Зробіть будь-яку зміну в коді
2. Закоміттіть та запуште:

```bash
git add .
git commit -m "Test CI/CD pipeline"
git push
```

3. Перевірте статус в GitHub:
   - Перейдіть до вкладки `Actions`
   - Перегляньте запущений workflow
   - Переконайтеся, що всі jobs успішні ✅

## Крок 5: Налаштування Branch Protection (опціонально)

Захистіть гілку `main` від прямих push без перевірки:

1. Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Увімкніть:
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Виберіть: `backend-build`, `frontend-build`, `integration-test`

## Структура Workflow

```
CI/CD Pipeline
├── Backend Build & Test
│   ├── Checkout
│   ├── Setup Node.js
│   ├── Install deps
│   ├── Run tests
│   └── Build Docker image
├── Frontend Build & Test
│   ├── Checkout
│   ├── Setup Node.js
│   ├── Install deps
│   ├── Build app
│   └── Build Docker image
├── Integration Tests
│   ├── Load images
│   ├── Start services
│   ├── Health checks
│   └── API tests
└── Deploy (on main)
    ├── Login to Docker Hub
    ├── Tag images
    └── Push images
```

## Workflow файли

### Основний CI/CD: `.github/workflows/ci-cd.yml`
- Автоматична збірка при push/PR
- Тестування всіх компонентів
- Інтеграційні тести
- Розгортання на Docker Hub

### Security Scan: `.github/workflows/security-scan.yml`
- Щотижневе сканування безпеки
- Виявлення вразливостей
- Аналіз залежностей

## Моніторинг Pipeline

### GitHub Actions Dashboard
```
Repository → Actions → CI/CD Pipeline
```

Тут ви побачите:
- ✅ Успішні запуски
- ❌ Невдалі запуски
- 🔄 Запуски в процесі
- ⏱️ Час виконання кожного job

### Badges для README

Додайте бейдж статусу в README:
```markdown
[![CI/CD Pipeline](https://github.com/username/repo/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/username/repo/actions/workflows/ci-cd.yml)
```

## Troubleshooting

### Pipeline падає на тестах
```bash
# Запустіть тести локально
cd backend
npm test

cd ../frontend
npm run build
```

### Docker Hub push не працює
1. Перевірте secrets:
   - DOCKER_USERNAME
   - DOCKER_PASSWORD
2. Переконайтеся, що secrets додані в Settings → Secrets
3. Перевірте, що push відбувається на main гілці

### Integration tests timeout
Збільште timeout в workflow:
```yaml
- name: Start services
  run: |
    docker compose up -d
    sleep 30  # Збільште час очікування
```

## Best Practices

1. **Використовуйте Pull Requests**
   - Створюйте feature branches
   - Відкривайте PR для змін
   - CI перевірить код перед merge

2. **Моніторте час виконання**
   - Оптимізуйте повільні jobs
   - Використовуйте кешування

3. **Перегляньте логи**
   - При помилках дивіться детальні логи
   - GitHub Actions показує кожен крок

4. **Версіонування**
   - Образи автоматично тегуються SHA коміту
   - Легко відкотити до попередньої версії

## Корисні посилання

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com/)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
