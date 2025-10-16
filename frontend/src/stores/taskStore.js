import { defineStore } from 'pinia'
import { taskAPI } from '../services/api'

export const useTaskStore = defineStore('tasks', {
  state: () => ({
    tasks: [],
    currentTask: null,
    loading: false,
    error: null,
    filters: {
      status: '',
      priority: '',
      sort: 'created_at',
      order: 'DESC'
    }
  }),

  getters: {
    pendingTasks: (state) => state.tasks.filter(task => task.status === 'pending'),
    inProgressTasks: (state) => state.tasks.filter(task => task.status === 'in-progress'),
    completedTasks: (state) => state.tasks.filter(task => task.status === 'completed'),
    taskCount: (state) => state.tasks.length
  },

  actions: {
    async fetchTasks() {
      this.loading = true
      this.error = null
      try {
        const response = await taskAPI.getTasks(this.filters)
        this.tasks = response.data.data
      } catch (error) {
        this.error = error.message
        console.error('Error fetching tasks:', error)
      } finally {
        this.loading = false
      }
    },

    async createTask(taskData) {
      this.loading = true
      this.error = null
      try {
        const response = await taskAPI.createTask(taskData)
        this.tasks.unshift(response.data.data)
        return response.data.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async updateTask(id, taskData) {
      this.loading = true
      this.error = null
      try {
        const response = await taskAPI.updateTask(id, taskData)
        const index = this.tasks.findIndex(task => task.id === id)
        if (index !== -1) {
          this.tasks[index] = response.data.data
        }
        return response.data.data
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    async deleteTask(id) {
      this.loading = true
      this.error = null
      try {
        await taskAPI.deleteTask(id)
        this.tasks = this.tasks.filter(task => task.id !== id)
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    },

    setFilters(newFilters) {
      this.filters = { ...this.filters, ...newFilters }
      this.fetchTasks()
    },

    clearFilters() {
      this.filters = {
        status: '',
        priority: '',
        sort: 'created_at',
        order: 'DESC'
      }
      this.fetchTasks()
    }
  }
})
