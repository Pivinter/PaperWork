<template>
  <div id="app" class="app">
    <header class="app-header">
      <div class="container">
        <h1 class="app-title">📋 Task Management System</h1>
        <nav class="app-nav">
          <router-link to="/" class="nav-link">Завдання</router-link>
          <router-link to="/statistics" class="nav-link">Статистика</router-link>
        </nav>
      </div>
    </header>

    <main class="app-main">
      <router-view />
    </main>

    <footer class="app-footer">
      <div class="container">
        <p>&copy; 2025 Task Management System | Курсова робота | Docker + VueJS + CI/CD</p>
      </div>
    </footer>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style scoped>
.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 1.5rem 0;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.app-title {
  margin: 0 0 1rem 0;
  font-size: 2rem;
  font-weight: 700;
}

.app-nav {
  display: flex;
  gap: 1.5rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: background-color 0.3s;
  font-weight: 500;
}

.nav-link:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.nav-link.router-link-active {
  background-color: rgba(255, 255, 255, 0.3);
}

.app-main {
  flex: 1;
  padding: 2rem 0;
  background-color: #f5f7fa;
}

.app-footer {
  background-color: #2c3e50;
  color: white;
  padding: 1.5rem 0;
  text-align: center;
}

.app-footer p {
  margin: 0;
  font-size: 0.9rem;
}
</style>
