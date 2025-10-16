const express = require('express');
const { body, validationResult } = require('express-validator');
const router = express.Router();
const db = require('../config/database');

// Validation middleware
const validateTask = [
  body('title').trim().notEmpty().withMessage('Title is required')
    .isLength({ max: 255 }).withMessage('Title must be less than 255 characters'),
  body('description').optional().trim(),
  body('status').optional().isIn(['pending', 'in-progress', 'completed', 'cancelled'])
    .withMessage('Invalid status'),
  body('priority').optional().isIn(['low', 'medium', 'high', 'urgent'])
    .withMessage('Invalid priority'),
  body('due_date').optional().isISO8601().withMessage('Invalid date format')
];

// Helper function to check validation errors
const checkValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// GET /api/tasks - Get all tasks
router.get('/', async (req, res) => {
  try {
    const { status, priority, sort = 'created_at', order = 'DESC' } = req.query;
    
    let query = 'SELECT * FROM tasks WHERE 1=1';
    const params = [];
    let paramCount = 1;

    if (status) {
      query += ` AND status = $${paramCount}`;
      params.push(status);
      paramCount++;
    }

    if (priority) {
      query += ` AND priority = $${paramCount}`;
      params.push(priority);
      paramCount++;
    }

    const validSortFields = ['id', 'title', 'status', 'priority', 'created_at', 'due_date'];
    const sortField = validSortFields.includes(sort) ? sort : 'created_at';
    const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    
    query += ` ORDER BY ${sortField} ${sortOrder}`;

    const result = await db.query(query, params);
    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// GET /api/tasks/:id - Get single task
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('SELECT * FROM tasks WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error fetching task:', error);
    res.status(500).json({ error: 'Failed to fetch task' });
  }
});

// POST /api/tasks - Create new task
router.post('/', validateTask, checkValidation, async (req, res) => {
  try {
    const { title, description, status, priority, due_date } = req.body;
    
    const result = await db.query(
      `INSERT INTO tasks (title, description, status, priority, due_date) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING *`,
      [
        title, 
        description || null, 
        status || 'pending', 
        priority || 'medium',
        due_date || null
      ]
    );
    
    res.status(201).json({
      success: true,
      message: 'Task created successfully',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// PUT /api/tasks/:id - Update task
router.put('/:id', validateTask, checkValidation, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, status, priority, due_date } = req.body;
    
    // Check if task exists
    const checkResult = await db.query('SELECT * FROM tasks WHERE id = $1', [id]);
    if (checkResult.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    // Update completed_at if status changed to completed
    let completedAt = checkResult.rows[0].completed_at;
    if (status === 'completed' && checkResult.rows[0].status !== 'completed') {
      completedAt = new Date();
    } else if (status !== 'completed') {
      completedAt = null;
    }
    
    const result = await db.query(
      `UPDATE tasks 
       SET title = $1, description = $2, status = $3, priority = $4, 
           due_date = $5, updated_at = CURRENT_TIMESTAMP, completed_at = $6
       WHERE id = $7 
       RETURNING *`,
      [title, description, status, priority, due_date, completedAt, id]
    );
    
    res.json({
      success: true,
      message: 'Task updated successfully',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// DELETE /api/tasks/:id - Delete task
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query('DELETE FROM tasks WHERE id = $1 RETURNING *', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    res.json({
      success: true,
      message: 'Task deleted successfully',
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

// GET /api/tasks/stats/summary - Get tasks statistics
router.get('/stats/summary', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'pending') as pending,
        COUNT(*) FILTER (WHERE status = 'in-progress') as in_progress,
        COUNT(*) FILTER (WHERE status = 'completed') as completed,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled,
        COUNT(*) FILTER (WHERE priority = 'urgent') as urgent,
        COUNT(*) FILTER (WHERE due_date < CURRENT_TIMESTAMP AND status != 'completed') as overdue
      FROM tasks
    `);
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

module.exports = router;
