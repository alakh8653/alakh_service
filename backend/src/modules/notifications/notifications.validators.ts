import { z } from 'zod';
import { NotificationCategory, DeviceType } from '@prisma/client';

/** List notifications with filters */
export const notificationFiltersSchema = z.object({
  category: z.nativeEnum(NotificationCategory).optional(),
  isRead: z.coerce.boolean().optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

/** Update notification preferences */
export const updatePreferencesSchema = z.object({
  preferences: z
    .array(
      z.object({
        category: z.nativeEnum(NotificationCategory),
        pushEnabled: z.boolean(),
        emailEnabled: z.boolean(),
        smsEnabled: z.boolean(),
        inAppEnabled: z.boolean(),
      }),
    )
    .min(1, 'At least one preference must be provided'),
});

/** Register / update an FCM token */
export const registerFCMTokenSchema = z.object({
  token: z.string().min(1, 'FCM token is required'),
  deviceType: z.nativeEnum(DeviceType),
});

/** Admin: send a notification to one or more users */
export const sendNotificationSchema = z.object({
  userId: z.string().uuid(),
  type: z.string().min(1),
  category: z.nativeEnum(NotificationCategory),
  title: z.string().min(1).max(200),
  body: z.string().min(1).max(1000),
  data: z.record(z.unknown()).optional(),
  imageUrl: z.string().url().optional(),
  actionUrl: z.string().url().optional(),
});

/** Admin: broadcast to a user segment */
export const broadcastSchema = z.object({
  segment: z.enum(['all', 'customers', 'shopOwners', 'city']),
  cityId: z.string().uuid().optional(),
  type: z.string().min(1),
  category: z.nativeEnum(NotificationCategory),
  title: z.string().min(1).max(200),
  body: z.string().min(1).max(1000),
  data: z.record(z.unknown()).optional(),
  imageUrl: z.string().url().optional(),
});

export type NotificationFiltersDto = z.infer<typeof notificationFiltersSchema>;
export type UpdatePreferencesDto = z.infer<typeof updatePreferencesSchema>;
export type RegisterFCMTokenDto = z.infer<typeof registerFCMTokenSchema>;
export type SendNotificationDto = z.infer<typeof sendNotificationSchema>;
export type BroadcastDto = z.infer<typeof broadcastSchema>;
