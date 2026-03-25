import { Router } from 'express';

import { bookingsRouter, shopBookingsRouter, adminBookingsRouter } from '../modules/bookings/bookings.routes';
import { queueRouter, shopQueueRouter } from '../modules/queue/queue.routes';
import { dispatchRouter, shopDispatchRouter, adminDispatchRouter } from '../modules/dispatch/dispatch.routes';
import { trackingRouter } from '../modules/tracking/tracking.routes';

const router = Router();

// ─── Bookings ─────────────────────────────────────────────────────────────────
router.use('/bookings', bookingsRouter);
router.use('/shops/:shopId/bookings', shopBookingsRouter);
router.use('/admin/bookings', adminBookingsRouter);

// ─── Queue ────────────────────────────────────────────────────────────────────
router.use('/queue', queueRouter);
router.use('/shops/:shopId/queue', shopQueueRouter);

// ─── Dispatch ─────────────────────────────────────────────────────────────────
router.use('/dispatch', dispatchRouter);
router.use('/shops/:shopId/dispatch', shopDispatchRouter);
router.use('/admin/dispatch', adminDispatchRouter);

// ─── Tracking ─────────────────────────────────────────────────────────────────
router.use('/tracking', trackingRouter);


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
