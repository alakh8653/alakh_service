import { NotificationCategory, DeviceType } from '@prisma/client';

// ─── Input types ──────────────────────────────────────────────────────────────

/** Input for sending a notification */
export interface SendNotificationInput {
  userId: string;
  type: string;
  category: NotificationCategory;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  imageUrl?: string;
  actionUrl?: string;
}

/** Input for broadcasting a notification to a user segment */
export interface BroadcastInput {
  segment: 'all' | 'customers' | 'shopOwners' | 'city';
  cityId?: string;
  type: string;
  category: NotificationCategory;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  imageUrl?: string;
}

/** FCM token registration input */
export interface FCMTokenInput {
  token: string;
  deviceType: DeviceType;
}

// ─── Output types ─────────────────────────────────────────────────────────────

/** Notification with metadata */
export interface NotificationWithMeta {
  id: string;
  userId: string;
  type: string;
  category: NotificationCategory;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  imageUrl?: string;
  actionUrl?: string;
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
}

/** User's notification preferences per category */
export interface NotificationPreferences {
  userId: string;
  preferences: Array<{
    category: NotificationCategory;
    pushEnabled: boolean;
    emailEnabled: boolean;
    smsEnabled: boolean;
    inAppEnabled: boolean;
  }>;
}

/** Delivery statistics for a period */
export interface NotificationDeliveryStats {
  period: { from: Date; to: Date };
  totalSent: number;
  deliveryRate: number;
  openRate: number;
  byChannel: {
    push: number;
    email: number;
    sms: number;
    inApp: number;
  };
}

/** Notification filter criteria */
export interface NotificationFilters {
  category?: NotificationCategory;
  isRead?: boolean;
  page: number;
  perPage: number;
}
