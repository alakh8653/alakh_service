import { Router } from 'express';

const router = Router();

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check
 *     tags: [Health]
 *     security: []
 *     responses:
 *       200:
 *         description: Service is healthy
 */
router.get('/', (_req, res) => {
  res.json({
    success: true,
    message: 'Alakh Service API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

export default router;
