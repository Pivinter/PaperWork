import { createRouter, createWebHistory } from 'vue-router'
import TaskList from '../views/TaskList.vue'
import Statistics from '../views/Statistics.vue'

const routes = [
  {
    path: '/',
    name: 'TaskList',
    component: TaskList,
    meta: { title: 'Список завдань' }
  },
  {
    path: '/statistics',
    name: 'Statistics',
    component: Statistics,
    meta: { title: 'Статистика' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = to.meta.title ? `${to.meta.title} | Task Management` : 'Task Management System'
  next()
})

export default router
