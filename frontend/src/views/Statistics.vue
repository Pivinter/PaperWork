<template>
  <div class="container statistics-view">
    <h2 class="page-title">📊 Статистика завдань</h2>

    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <p>Завантаження статистики...</p>
    </div>

    <div v-else-if="error" class="error">
      ❌ Помилка: {{ error }}
    </div>

    <div v-else class="stats-grid">
      <div class="stat-card total">
        <div class="stat-icon">📋</div>
        <div class="stat-content">
          <h3>Всього завдань</h3>
          <p class="stat-value">{{ stats.total || 0 }}</p>
        </div>
      </div>

      <div class="stat-card pending">
        <div class="stat-icon">⏳</div>
        <div class="stat-content">
          <h3>Очікує виконання</h3>
          <p class="stat-value">{{ stats.pending || 0 }}</p>
        </div>
      </div>

      <div class="stat-card in-progress">
        <div class="stat-icon">🔄</div>
        <div class="stat-content">
          <h3>В роботі</h3>
          <p class="stat-value">{{ stats.in_progress || 0 }}</p>
        </div>
      </div>

      <div class="stat-card completed">
        <div class="stat-icon">✅</div>
        <div class="stat-content">
          <h3>Завершено</h3>
          <p class="stat-value">{{ stats.completed || 0 }}</p>
        </div>
      </div>

      <div class="stat-card cancelled">
        <div class="stat-icon">❌</div>
        <div class="stat-content">
          <h3>Скасовано</h3>
          <p class="stat-value">{{ stats.cancelled || 0 }}</p>
        </div>
      </div>

      <div class="stat-card urgent">
        <div class="stat-icon">🔥</div>
        <div class="stat-content">
          <h3>Термінових</h3>
          <p class="stat-value">{{ stats.urgent || 0 }}</p>
        </div>
      </div>

      <div class="stat-card overdue">
        <div class="stat-icon">⚠️</div>
        <div class="stat-content">
          <h3>Прострочено</h3>
          <p class="stat-value">{{ stats.overdue || 0 }}</p>
        </div>
      </div>
    </div>

    <button @click="refreshStats" class="btn btn-primary refresh-btn">
      🔄 Оновити статистику
    </button>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { taskAPI } from '../services/api'

export default {
  name: 'Statistics',
  setup() {
    const stats = ref({})
    const loading = ref(false)
    const error = ref(null)

    const fetchStats = async () => {
      loading.value = true
      error.value = null
      try {
        const response = await taskAPI.getStatistics()
        stats.value = response.data.data
      } catch (err) {
        error.value = err.message
        console.error('Error fetching statistics:', err)
      } finally {
        loading.value = false
      }
    }

    const refreshStats = () => {
      fetchStats()
    }

    onMounted(() => {
      fetchStats()
    })

    return {
      stats,
      loading,
      error,
      refreshStats
    }
  }
}
</script>

<style scoped>
.statistics-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-title {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 2rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 1.5rem;
  transition: transform 0.3s, box-shadow 0.3s;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  font-size: 3rem;
}

.stat-content h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  color: #7f8c8d;
  font-weight: 600;
}

.stat-value {
  margin: 0;
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
}

.stat-card.total { border-left: 5px solid #3498db; }
.stat-card.pending { border-left: 5px solid #f39c12; }
.stat-card.in-progress { border-left: 5px solid #9b59b6; }
.stat-card.completed { border-left: 5px solid #2ecc71; }
.stat-card.cancelled { border-left: 5px solid #95a5a6; }
.stat-card.urgent { border-left: 5px solid #e74c3c; }
.stat-card.overdue { border-left: 5px solid #e67e22; }

.refresh-btn {
  display: block;
  margin: 0 auto;
}

.loading, .error {
  text-align: center;
  padding: 3rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
