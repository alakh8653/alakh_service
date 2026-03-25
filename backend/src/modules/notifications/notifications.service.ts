import { Server as SocketServer } from 'socket.io';
import nodemailer from 'nodemailer';
import redis from '../../config/redis';
import { NotificationsRepository } from './notifications.repository';
import {
  SendNotificationInput,
  BroadcastInput,
  FCMTokenInput,
  NotificationPreferences,
  NotificationDeliveryStats,
  NotificationFilters,
  NotificationWithMeta,
} from './notifications.types';
import {
  ForbiddenError,
  NotFoundError,
} from '../../shared/errors/AppError';
import { getFirebaseApp, admin } from '../../config/firebase';
import { NotificationCategory } from '@prisma/client';

/** Redis key for unread notification count */
const NOTIF_UNREAD_KEY = (userId: string) => `notif:unread:${userId}`;

/**
 * Business logic for the notifications module.
 */
export class NotificationsService {
  private readonly repo: NotificationsRepository;
  private io?: SocketServer;

  constructor(io?: SocketServer) {
    this.repo = new NotificationsRepository();
    this.io = io;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /**
   * Send a FCM push notification to a list of device tokens.
   *
   * @param tokens - FCM device tokens
   * @param title  - Notification title
   * @param body   - Notification body
   * @param data   - Optional extra data payload
   */
  async sendPushNotification(
    tokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    if (tokens.length === 0) return;

    try {
      const messaging = getFirebaseApp().messaging();
      await messaging.sendEachForMulticast({
        tokens,
        notification: { title, body },
        data,
      });
    } catch (err) {
      // TODO: handle invalid tokens (remove from DB)
      console.error('[FCM] Push notification failed:', err);
    }
  }

  /**
   * Send an email notification via nodemailer.
   *
   * @param email   - Recipient email address
   * @param subject - Email subject
   * @param html    - HTML body
   */
  async sendEmailNotification(
    email: string,
    subject: string,
    html: string,
  ): Promise<void> {
    try {
      const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT ?? '587', 10),
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
      });

      await transporter.sendMail({
        from: process.env.EMAIL_FROM ?? 'noreply@alakhservice.com',
        to: email,
        subject,
        html,
      });
    } catch (err) {
      console.error('[Email] Failed to send email:', err);
    }
  }

  /**
   * Send an SMS notification.
   * TODO: Integrate Twilio/MSG91 SDK.
   *
   * @param phone   - Recipient phone number (E.164 format)
   * @param message - SMS text
   */
  async sendSMSNotification(phone: string, message: string): Promise<void> {
    // TODO: Integrate Twilio/MSG91
    console.info(`[SMS] Sending to ${phone}: ${message}`);
  }

  /**
   * Map a system event to a notification payload.
   * Called internally when events are emitted (booking confirmed, etc.)
   */
  createNotificationFromEvent(event: {
    type: string;
    userId: string;
    data?: Record<string, unknown>;
  }): Omit<SendNotificationInput, 'userId'> {
    const eventMap: Record<
      string,
      {
        category: NotificationCategory;
        title: string;
        body: string;
      }
    > = {
      BOOKING_CONFIRMED: {
        category: 'TRANSACTIONAL',
        title: 'Booking Confirmed!',
        body: 'Your booking has been confirmed.',
      },
      PAYMENT_RECEIVED: {
        category: 'TRANSACTIONAL',
        title: 'Payment Received',
        body: 'We have received your payment.',
      },
      REVIEW_RECEIVED: {
        category: 'SOCIAL',
        title: 'New Review',
        body: 'You have received a new review.',
      },
      REFUND_PROCESSED: {
        category: 'TRANSACTIONAL',
        title: 'Refund Processed',
        body: 'Your refund has been processed.',
      },
    };

    const mapped = eventMap[event.type] ?? {
      category: 'SYSTEM' as NotificationCategory,
      title: 'Notification',
      body: 'You have a new notification.',
    };

    return {
      type: event.type,
      ...mapped,
      data: event.data,
    };
  }

  // ─── User notification management ─────────────────────────────────────────

  /** List user's notifications with optional filters */
  async getUserNotifications(
    userId: string,
    filters: NotificationFilters,
  ) {
    return this.repo.listUserNotifications(
      userId,
      { category: filters.category, isRead: filters.isRead },
      filters.page,
      filters.perPage,
    );
  }

  /**
   * Get unread notification count.
   * Primary: Redis; fallback: DB.
   */
  async getUnreadCount(userId: string): Promise<number> {
    try {
      const cached = await redis.get(NOTIF_UNREAD_KEY(userId));
      if (cached !== null) return parseInt(cached, 10);
    } catch {
      // Redis unavailable
    }

    // Fallback: count from DB
    const count = await this.repo.countUnread(userId);

    // Cache the result
    try {
      await redis.set(NOTIF_UNREAD_KEY(userId), count, 'EX', 300); // 5 min TTL
    } catch {
      // ignore
    }

    return count;
  }

  /** Mark a single notification as read */
  async markAsRead(userId: string, notificationId: string) {
    const notification = await this.repo.findNotificationById(notificationId);
    if (!notification) throw new NotFoundError('Notification not found');
    if (notification.userId !== userId)
      throw new ForbiddenError('Access denied');

    if (notification.isRead) return notification;

    const updated = await this.repo.updateNotification(notificationId, {
      isRead: true,
      readAt: new Date(),
    });

    // Decrement Redis counter
    try {
      await redis.decr(NOTIF_UNREAD_KEY(userId));
    } catch {
      // ignore
    }

    return updated;
  }

  /** Mark all notifications as read */
  async markAllRead(userId: string): Promise<{ count: number }> {
    const result = await this.repo.markAllRead(userId);

    // Reset Redis counter
    try {
      await redis.set(NOTIF_UNREAD_KEY(userId), 0);
    } catch {
      // ignore
    }

    return result;
  }

  /** Delete a notification */
  async deleteNotification(userId: string, notificationId: string): Promise<void> {
    const notification = await this.repo.findNotificationById(notificationId);
    if (!notification) throw new NotFoundError('Notification not found');
    if (notification.userId !== userId)
      throw new ForbiddenError('Access denied');

    await this.repo.deleteNotification(notificationId);

    // Adjust Redis counter if unread
    if (!notification.isRead) {
      try {
        await redis.decr(NOTIF_UNREAD_KEY(userId));
      } catch {
        // ignore
      }
    }
  }

  /** Clear all read notifications for a user */
  async clearReadNotifications(userId: string): Promise<{ count: number }> {
    return this.repo.clearReadNotifications(userId);
  }

  // ─── Preferences ──────────────────────────────────────────────────────────

  /** Get notification preferences (create defaults if none exist) */
  async getPreferences(userId: string): Promise<NotificationPreferences> {
    const prefs = await this.repo.getOrCreatePreferences(userId);
    return {
      userId,
      preferences: prefs.map((p) => ({
        category: p.category,
        pushEnabled: p.pushEnabled,
        emailEnabled: p.emailEnabled,
        smsEnabled: p.smsEnabled,
        inAppEnabled: p.inAppEnabled,
      })),
    };
  }

  /** Update notification preferences */
  async updatePreferences(
    userId: string,
    preferences: Array<{
      category: NotificationCategory;
      pushEnabled: boolean;
      emailEnabled: boolean;
      smsEnabled: boolean;
      inAppEnabled: boolean;
    }>,
  ): Promise<NotificationPreferences> {
    await Promise.all(
      preferences.map((pref) =>
        this.repo.upsertPreference(userId, pref.category, {
          pushEnabled: pref.pushEnabled,
          emailEnabled: pref.emailEnabled,
          smsEnabled: pref.smsEnabled,
          inAppEnabled: pref.inAppEnabled,
        }),
      ),
    );

    return this.getPreferences(userId);
  }

  // ─── FCM Tokens ────────────────────────────────────────────────────────────

  /** Register or update a device FCM token */
  async registerFCMToken(
    userId: string,
    data: FCMTokenInput,
  ) {
    return this.repo.upsertFCMToken(userId, data.token, data.deviceType);
  }

  /** Remove FCM token on logout */
  async removeFCMToken(userId: string, token: string): Promise<void> {
    await this.repo.deleteFCMToken(userId, token);
  }

  // ─── Core notification sending ────────────────────────────────────────────

  /**
   * Send a notification to a single user.
   * Respects the user's channel preferences (push/email/sms/inApp).
   * Emits a WebSocket event for real-time in-app delivery.
   */
  async sendNotification(notification: SendNotificationInput): Promise<NotificationWithMeta> {
    // Fetch preference for this category
    const pref = await this.repo.findPreference(
      notification.userId,
      notification.category,
    );

    // Default: all channels enabled if no preference set
    const pushEnabled = pref?.pushEnabled ?? true;
    const emailEnabled = pref?.emailEnabled ?? true;
    const smsEnabled = pref?.smsEnabled ?? false;
    const inAppEnabled = pref?.inAppEnabled ?? true;

    // Persist notification in DB
    const created = await this.repo.createNotification({
      user: { connect: { id: notification.userId } },
      type: notification.type,
      category: notification.category,
      title: notification.title,
      body: notification.body,
      data: notification.data as never,
      imageUrl: notification.imageUrl,
      actionUrl: notification.actionUrl,
    });

    // In-app: emit via WebSocket
    if (inAppEnabled) {
      this.io?.to(`user:${notification.userId}`).emit('notification', created);
    }

    // Push notification via FCM
    if (pushEnabled) {
      const tokens = await this.repo.getUserFCMTokens(notification.userId);
      await this.sendPushNotification(
        tokens.map((t) => t.token),
        notification.title,
        notification.body,
        notification.data as Record<string, string> | undefined,
      );
    }

    // Email notification
    if (emailEnabled) {
      // TODO: Fetch user email from DB and send
      // const user = await prisma.user.findUnique({ where: { id: notification.userId } });
      // await this.sendEmailNotification(user.email, notification.title, `<p>${notification.body}</p>`);
    }

    // SMS notification
    if (smsEnabled) {
      // TODO: Fetch user phone from DB and send
      // await this.sendSMSNotification(user.phone, notification.body);
    }

    // Increment Redis unread counter
    try {
      await redis.incr(NOTIF_UNREAD_KEY(notification.userId));
    } catch {
      // ignore
    }

    return created as NotificationWithMeta;
  }

  /**
   * Send a notification to multiple users.
   * Enqueued via Bull for background processing.
   */
  async sendBulkNotification(
    userIds: string[],
    notification: Omit<SendNotificationInput, 'userId'>,
  ): Promise<{ queued: number }> {
    // TODO: Enqueue via Bull notification queue
    // await notificationQueue.addBulk(userIds.map(userId => ({ data: { ...notification, userId } })));

    // Fallback: process synchronously (not for production scale)
    await Promise.allSettled(
      userIds.map((userId) =>
        this.sendNotification({ ...notification, userId }),
      ),
    );

    return { queued: userIds.length };
  }

  /**
   * Broadcast a notification to a user segment
   * (all users, customers, shop owners, or a specific city).
   */
  async broadcastNotification(
    input: BroadcastInput,
  ): Promise<{ queued: number }> {
    let userIds: string[];

    if (input.segment === 'city' && input.cityId) {
      // TODO: Fetch users by city from the users/shops table
      userIds = [];
    } else {
      userIds = await this.repo.getUserIdsBySegment(
        input.segment as 'all' | 'customers' | 'shopOwners',
      );
    }

    return this.sendBulkNotification(userIds, {
      type: input.type,
      category: input.category,
      title: input.title,
      body: input.body,
      data: input.data,
      imageUrl: input.imageUrl,
    });
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  /** Delivery stats for admin dashboard */
  async getDeliveryStats(period = 30): Promise<NotificationDeliveryStats> {
    const now = new Date();
    const from = new Date(now.getTime() - period * 24 * 60 * 60 * 1000);

    const [total, readCount, byCategory] = await Promise.all([
      this.repo.countTotal(from, now),
      this.repo.countRead(from, now),
      this.repo.countByCategory(from, now),
    ]);

    const byCategoryMap = Object.fromEntries(
      byCategory.map((r) => [r.category, r._count]),
    );

    return {
      period: { from, to: now },
      totalSent: total,
      deliveryRate: total > 0 ? 100 : 0, // TODO: track actual delivery failures
      openRate: total > 0 ? parseFloat(((readCount / total) * 100).toFixed(2)) : 0,
      byChannel: {
        push: byCategoryMap['TRANSACTIONAL'] ?? 0,
        email: byCategoryMap['PROMOTIONAL'] ?? 0,
        sms: 0, // TODO: track SMS delivery separately
        inApp: total,
      },
    };
  }
}
