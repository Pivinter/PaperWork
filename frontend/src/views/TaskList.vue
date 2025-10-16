<template>
  <div class="container task-list-view">
    <div class="header-section">
      <h2 class="page-title">Список завдань</h2>
      <button @click="showCreateModal = true" class="btn btn-primary">
        ➕ Створити завдання
      </button>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filter-group">
        <label>Статус:</label>
        <select v-model="filters.status" @change="applyFilters" class="filter-select">
          <option value="">Всі</option>
          <option value="pending">Очікує</option>
          <option value="in-progress">В роботі</option>
          <option value="completed">Завершено</option>
          <option value="cancelled">Скасовано</option>
        </select>
      </div>

      <div class="filter-group">
        <label>Пріоритет:</label>
        <select v-model="filters.priority" @change="applyFilters" class="filter-select">
          <option value="">Всі</option>
          <option value="low">Низький</option>
          <option value="medium">Середній</option>
          <option value="high">Високий</option>
          <option value="urgent">Терміновий</option>
        </select>
      </div>

      <button @click="clearFilters" class="btn btn-secondary">Очистити фільтри</button>
    </div>

    <!-- Loading state -->
    <div v-if="taskStore.loading" class="loading">
      <div class="spinner"></div>
      <p>Завантаження завдань...</p>
    </div>

    <!-- Error state -->
    <div v-else-if="taskStore.error" class="error">
      ❌ Помилка: {{ taskStore.error }}
    </div>

    <!-- Tasks list -->
    <div v-else-if="taskStore.tasks.length > 0" class="tasks-grid">
      <TaskCard
        v-for="task in taskStore.tasks"
        :key="task.id"
        :task="task"
        @edit="editTask"
        @delete="deleteTask"
      />
    </div>

    <!-- Empty state -->
    <div v-else class="empty-state">
      <p>📝 Немає завдань. Створіть нове завдання!</p>
    </div>

    <!-- Create/Edit Modal -->
    <TaskModal
      v-if="showCreateModal || showEditModal"
      :task="selectedTask"
      :isEdit="showEditModal"
      @close="closeModal"
      @save="saveTask"
    />
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { useTaskStore } from '../stores/taskStore'
import TaskCard from '../components/TaskCard.vue'
import TaskModal from '../components/TaskModal.vue'

export default {
  name: 'TaskList',
  components: {
    TaskCard,
    TaskModal
  },
  setup() {
    const taskStore = useTaskStore()
    const showCreateModal = ref(false)
    const showEditModal = ref(false)
    const selectedTask = ref(null)
    const filters = reactive({
      status: '',
      priority: ''
    })

    const applyFilters = () => {
      taskStore.setFilters(filters)
    }

    const clearFilters = () => {
      filters.status = ''
      filters.priority = ''
      taskStore.clearFilters()
    }

    const editTask = (task) => {
      selectedTask.value = { ...task }
      showEditModal.value = true
    }

    const deleteTask = async (task) => {
      if (confirm(`Видалити завдання "${task.title}"?`)) {
        try {
          await taskStore.deleteTask(task.id)
        } catch (error) {
          alert('Помилка видалення завдання')
        }
      }
    }

    const closeModal = () => {
      showCreateModal.value = false
      showEditModal.value = false
      selectedTask.value = null
    }

    const saveTask = async (taskData) => {
      try {
        if (showEditModal.value) {
          await taskStore.updateTask(selectedTask.value.id, taskData)
        } else {
          await taskStore.createTask(taskData)
        }
        closeModal()
      } catch (error) {
        alert('Помилка збереження завдання')
      }
    }

    onMounted(() => {
      taskStore.fetchTasks()
    })

    return {
      taskStore,
      showCreateModal,
      showEditModal,
      selectedTask,
      filters,
      applyFilters,
      clearFilters,
      editTask,
      deleteTask,
      closeModal,
      saveTask
    }
  }
}
</script>

<style scoped>
.task-list-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.header-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.page-title {
  font-size: 2rem;
  color: #2c3e50;
  margin: 0;
}

.filters-section {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.filter-group label {
  font-weight: 600;
  color: #2c3e50;
}

.filter-select {
  padding: 0.5rem 1rem;
  border: 2px solid #e0e6ed;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: border-color 0.3s;
}

.filter-select:focus {
  outline: none;
  border-color: #667eea;
}

.tasks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
}

.loading, .error, .empty-state {
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

.error {
  color: #e74c3c;
}

.empty-state {
  font-size: 1.2rem;
  color: #7f8c8d;
}
</style>
