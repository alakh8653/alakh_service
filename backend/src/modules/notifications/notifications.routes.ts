import { Router } from 'express';
import { authenticate, authorize } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import {
  notificationFiltersSchema,
  updatePreferencesSchema,
  registerFCMTokenSchema,
  sendNotificationSchema,
  broadcastSchema,
} from './notifications.validators';
import * as ctrl from './notifications.controller';

const router = Router();

/** All notification routes require authentication */
router.use(authenticate);

// ─── User routes ──────────────────────────────────────────────────────────────

/** List user's notifications */
router.get(
  '/notifications',
  validate(notificationFiltersSchema, 'query'),
  ctrl.getUserNotifications,
);

/** Unread count */
router.get('/notifications/unread-count', ctrl.getUnreadCount);

/** Mark all as read */
router.put('/notifications/read-all', ctrl.markAllRead);

/** Clear all read notifications */
router.delete('/notifications/clear', ctrl.clearNotifications);

/** Get notification preferences */
router.get('/notifications/preferences', ctrl.getPreferences);

/** Update notification preferences */
router.put(
  '/notifications/preferences',
  validate(updatePreferencesSchema),
  ctrl.updatePreferences,
);

/** Register FCM token */
router.post(
  '/notifications/fcm-token',
  validate(registerFCMTokenSchema),
  ctrl.registerFCMToken,
);

/** Remove FCM token */
router.delete('/notifications/fcm-token', ctrl.removeFCMToken);

/** Mark single notification as read */
router.put('/notifications/:id/read', ctrl.markAsRead);

/** Delete a notification */
router.delete('/notifications/:id', ctrl.deleteNotification);

// ─── Admin routes ─────────────────────────────────────────────────────────────

/** Send notification to a user */
router.post(
  '/admin/notifications/send',
  authorize('ADMIN'),
  validate(sendNotificationSchema),
  ctrl.adminSendNotification,
);

/** Broadcast notification */
router.post(
  '/admin/notifications/broadcast',
  authorize('ADMIN'),
  validate(broadcastSchema),
  ctrl.adminBroadcast,
);

/** Delivery stats */
router.get(
  '/admin/notifications/stats',
  authorize('ADMIN'),
  ctrl.adminGetStats,
);

export default router;
