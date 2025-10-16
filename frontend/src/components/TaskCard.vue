<template>
  <div class="task-card" :class="`status-${task.status}`">
    <div class="task-header">
      <h3 class="task-title">{{ task.title }}</h3>
      <span class="task-priority" :class="`priority-${task.priority}`">
        {{ priorityLabel }}
      </span>
    </div>

    <p class="task-description" v-if="task.description">
      {{ task.description }}
    </p>

    <div class="task-meta">
      <span class="task-status" :class="`status-badge-${task.status}`">
        {{ statusLabel }}
      </span>
      <span class="task-date" v-if="task.due_date">
        📅 {{ formatDate(task.due_date) }}
      </span>
    </div>

    <div class="task-actions">
      <button @click="$emit('edit', task)" class="btn-icon btn-edit" title="Редагувати">
        ✏️
      </button>
      <button @click="$emit('delete', task)" class="btn-icon btn-delete" title="Видалити">
        🗑️
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TaskCard',
  props: {
    task: {
      type: Object,
      required: true
    }
  },
  emits: ['edit', 'delete'],
  computed: {
    statusLabel() {
      const labels = {
        'pending': 'Очікує',
        'in-progress': 'В роботі',
        'completed': 'Завершено',
        'cancelled': 'Скасовано'
      }
      return labels[this.task.status] || this.task.status
    },
    priorityLabel() {
      const labels = {
        'low': 'Низький',
        'medium': 'Середній',
        'high': 'Високий',
        'urgent': 'Терміновий'
      }
      return labels[this.task.priority] || this.task.priority
    }
  },
  methods: {
    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('uk-UA', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }
  }
}
</script>

<style scoped>
.task-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s, box-shadow 0.3s;
  border-left: 4px solid #3498db;
}

.task-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.task-card.status-completed {
  border-left-color: #2ecc71;
  opacity: 0.8;
}

.task-card.status-cancelled {
  border-left-color: #95a5a6;
  opacity: 0.7;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.task-title {
  margin: 0;
  font-size: 1.25rem;
  color: #2c3e50;
  flex: 1;
}

.task-priority {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.priority-low {
  background-color: #d4edda;
  color: #155724;
}

.priority-medium {
  background-color: #fff3cd;
  color: #856404;
}

.priority-high {
  background-color: #f8d7da;
  color: #721c24;
}

.priority-urgent {
  background-color: #f5c6cb;
  color: #721c24;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.task-description {
  color: #7f8c8d;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.task-meta {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}

.task-status {
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 600;
}

.status-badge-pending {
  background-color: #fff3cd;
  color: #856404;
}

.status-badge-in-progress {
  background-color: #cfe2ff;
  color: #084298;
}

.status-badge-completed {
  background-color: #d1e7dd;
  color: #0f5132;
}

.status-badge-cancelled {
  background-color: #e2e3e5;
  color: #41464b;
}

.task-date {
  font-size: 0.85rem;
  color: #7f8c8d;
}

.task-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-icon {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s;
}

.btn-edit {
  background-color: #3498db;
}

.btn-edit:hover {
  background-color: #2980b9;
  transform: scale(1.1);
}

.btn-delete {
  background-color: #e74c3c;
}

.btn-delete:hover {
  background-color: #c0392b;
  transform: scale(1.1);
}
</style>
