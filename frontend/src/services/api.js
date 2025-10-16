import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  },
  timeout: 10000
})

// Request interceptor
apiClient.interceptors.request.use(
  config => {
    console.log(`[API Request] ${config.method.toUpperCase()} ${config.url}`)
    return config
  },
  error => {
    console.error('[API Request Error]', error)
    return Promise.reject(error)
  }
)

// Response interceptor
apiClient.interceptors.response.use(
  response => {
    console.log(`[API Response] ${response.config.url}`, response.data)
    return response
  },
  error => {
    console.error('[API Response Error]', error.response || error)
    return Promise.reject(error)
  }
)

export const taskAPI = {
  // Get all tasks
  getTasks(params = {}) {
    return apiClient.get('/api/tasks', { params })
  },

  // Get single task
  getTask(id) {
    return apiClient.get(`/api/tasks/${id}`)
  },

  // Create new task
  createTask(taskData) {
    return apiClient.post('/api/tasks', taskData)
  },

  // Update task
  updateTask(id, taskData) {
    return apiClient.put(`/api/tasks/${id}`, taskData)
  },

  // Delete task
  deleteTask(id) {
    return apiClient.delete(`/api/tasks/${id}`)
  },

  // Get statistics
  getStatistics() {
    return apiClient.get('/api/tasks/stats/summary')
  }
}

export default apiClient
