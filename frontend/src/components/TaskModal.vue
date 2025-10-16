<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h2>{{ isEdit ? 'Редагувати завдання' : 'Нове завдання' }}</h2>
        <button @click="$emit('close')" class="btn-close">✕</button>
      </div>

      <form @submit.prevent="handleSubmit" class="task-form">
        <div class="form-group">
          <label for="title">Назва завдання *</label>
          <input
            id="title"
            v-model="formData.title"
            type="text"
            required
            maxlength="255"
            placeholder="Введіть назву завдання"
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="description">Опис</label>
          <textarea
            id="description"
            v-model="formData.description"
            rows="4"
            placeholder="Введіть опис завдання"
            class="form-input"
          ></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="status">Статус</label>
            <select id="status" v-model="formData.status" class="form-input">
              <option value="pending">Очікує</option>
              <option value="in-progress">В роботі</option>
              <option value="completed">Завершено</option>
              <option value="cancelled">Скасовано</option>
            </select>
          </div>

          <div class="form-group">
            <label for="priority">Пріоритет</label>
            <select id="priority" v-model="formData.priority" class="form-input">
              <option value="low">Низький</option>
              <option value="medium">Середній</option>
              <option value="high">Високий</option>
              <option value="urgent">Терміновий</option>
            </select>
          </div>
        </div>

        <div class="form-group">
          <label for="due_date">Термін виконання</label>
          <input
            id="due_date"
            v-model="formData.due_date"
            type="datetime-local"
            class="form-input"
          />
        </div>

        <div class="form-actions">
          <button type="button" @click="$emit('close')" class="btn btn-secondary">
            Скасувати
          </button>
          <button type="submit" class="btn btn-primary">
            {{ isEdit ? 'Зберегти зміни' : 'Створити завдання' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import { reactive, watch } from 'vue'

export default {
  name: 'TaskModal',
  props: {
    task: {
      type: Object,
      default: null
    },
    isEdit: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'save'],
  setup(props, { emit }) {
    const formData = reactive({
      title: '',
      description: '',
      status: 'pending',
      priority: 'medium',
      due_date: ''
    })

    // Populate form if editing
    watch(() => props.task, (newTask) => {
      if (newTask) {
        formData.title = newTask.title || ''
        formData.description = newTask.description || ''
        formData.status = newTask.status || 'pending'
        formData.priority = newTask.priority || 'medium'
        formData.due_date = newTask.due_date 
          ? new Date(newTask.due_date).toISOString().slice(0, 16)
          : ''
      }
    }, { immediate: true })

    const handleSubmit = () => {
      const submitData = {
        title: formData.title.trim(),
        description: formData.description.trim(),
        status: formData.status,
        priority: formData.priority
      }
      
      // Only include due_date if it has a value
      if (formData.due_date && formData.due_date.trim()) {
        submitData.due_date = formData.due_date
      }
      
      emit('save', submitData)
    }

    return {
      formData,
      handleSubmit
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 2px solid #e0e6ed;
}

.modal-header h2 {
  margin: 0;
  color: #2c3e50;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #7f8c8d;
  transition: color 0.3s;
  padding: 0.25rem 0.5rem;
}

.btn-close:hover {
  color: #e74c3c;
}

.task-form {
  padding: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #2c3e50;
}

.form-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #e0e6ed;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

textarea.form-input {
  resize: vertical;
  font-family: inherit;
}
</style>
