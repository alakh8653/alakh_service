import prisma from '../../config/database';
import {
  Notification,
  NotificationPreference,
  FCMToken,
  Prisma,
  NotificationCategory,
} from '@prisma/client';

/**
 * Data-access layer for the notifications module.
 */
export class NotificationsRepository {
  // ─── Notifications ──────────────────────────────────────────────────────────

  async createNotification(
    data: Prisma.NotificationCreateInput,
  ): Promise<Notification> {
    return prisma.notification.create({ data });
  }

  async bulkCreateNotifications(
    items: Prisma.NotificationCreateManyInput[],
  ): Promise<{ count: number }> {
    return prisma.notification.createMany({ data: items });
  }

  async findNotificationById(id: string): Promise<Notification | null> {
    return prisma.notification.findUnique({ where: { id } });
  }

  async updateNotification(
    id: string,
    data: Prisma.NotificationUpdateInput,
  ): Promise<Notification> {
    return prisma.notification.update({ where: { id }, data });
  }

  async deleteNotification(id: string): Promise<void> {
    await prisma.notification.delete({ where: { id } });
  }

  async listUserNotifications(
    userId: string,
    filters: { category?: NotificationCategory; isRead?: boolean },
    page: number,
    perPage: number,
  ) {
    const where: Prisma.NotificationWhereInput = {
      userId,
      ...(filters.category && { category: filters.category }),
      ...(filters.isRead !== undefined && { isRead: filters.isRead }),
    };

    const [data, total] = await prisma.$transaction([
      prisma.notification.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.notification.count({ where }),
    ]);

    return {
      data,
      total,
      page,
      perPage,
      totalPages: Math.ceil(total / perPage),
    };
  }

  async countUnread(userId: string): Promise<number> {
    return prisma.notification.count({ where: { userId, isRead: false } });
  }

  async markAllRead(userId: string): Promise<{ count: number }> {
    return prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true, readAt: new Date() },
    });
  }

  async clearReadNotifications(userId: string): Promise<{ count: number }> {
    return prisma.notification.deleteMany({
      where: { userId, isRead: true },
    });
  }

  // ─── Preferences ────────────────────────────────────────────────────────────

  async findPreferences(userId: string): Promise<NotificationPreference[]> {
    return prisma.notificationPreference.findMany({ where: { userId } });
  }

  async findPreference(
    userId: string,
    category: NotificationCategory,
  ): Promise<NotificationPreference | null> {
    return prisma.notificationPreference.findUnique({
      where: { userId_category: { userId, category } },
    });
  }

  /** Get preferences, creating defaults for missing categories */
  async getOrCreatePreferences(
    userId: string,
  ): Promise<NotificationPreference[]> {
    const existing = await this.findPreferences(userId);
    const existingCategories = new Set(existing.map((p) => p.category));

    const allCategories = Object.values(NotificationCategory);
    const missing = allCategories.filter((c) => !existingCategories.has(c));

    if (missing.length > 0) {
      await prisma.notificationPreference.createMany({
        data: missing.map((category) => ({
          userId,
          category,
          pushEnabled: true,
          emailEnabled: true,
          smsEnabled: false,
          inAppEnabled: true,
        })),
        skipDuplicates: true,
      });
    }

    return prisma.notificationPreference.findMany({ where: { userId } });
  }

  async upsertPreference(
    userId: string,
    category: NotificationCategory,
    data: Omit<Prisma.NotificationPreferenceCreateInput, 'user' | 'category'>,
  ): Promise<NotificationPreference> {
    return prisma.notificationPreference.upsert({
      where: { userId_category: { userId, category } },
      create: {
        user: { connect: { id: userId } },
        category,
        ...data,
      },
      update: data,
    });
  }

  // ─── FCM Tokens ─────────────────────────────────────────────────────────────

  async upsertFCMToken(
    userId: string,
    token: string,
    deviceType: string,
  ): Promise<FCMToken> {
    return prisma.fCMToken.upsert({
      where: { token },
      create: {
        user: { connect: { id: userId } },
        token,
        deviceType: deviceType as never,
      },
      update: { userId, deviceType: deviceType as never },
    });
  }

  async deleteFCMToken(userId: string, token: string): Promise<void> {
    await prisma.fCMToken.deleteMany({ where: { userId, token } });
  }

  async getUserFCMTokens(userId: string): Promise<FCMToken[]> {
    return prisma.fCMToken.findMany({ where: { userId } });
  }

  // ─── Stats (admin) ──────────────────────────────────────────────────────────

  async countByCategory(from: Date, to: Date) {
    return prisma.notification.groupBy({
      by: ['category'],
      where: { createdAt: { gte: from, lte: to } },
      _count: true,
    });
  }

  async countTotal(from: Date, to: Date): Promise<number> {
    return prisma.notification.count({
      where: { createdAt: { gte: from, lte: to } },
    });
  }

  async countRead(from: Date, to: Date): Promise<number> {
    return prisma.notification.count({
      where: { createdAt: { gte: from, lte: to }, isRead: true },
    });
  }

  // ─── Broadcast helpers ───────────────────────────────────────────────────────

  /** Fetch user IDs for a given segment (all / customers / shopOwners) */
  async getUserIdsBySegment(
    segment: 'all' | 'customers' | 'shopOwners',
  ): Promise<string[]> {
    const roleMap = {
      all: undefined,
      customers: 'CUSTOMER' as const,
      shopOwners: 'SHOP_OWNER' as const,
    };

    const users = await prisma.user.findMany({
      where: roleMap[segment] ? { role: roleMap[segment] } : {},
      select: { id: true },
    });

    return users.map((u) => u.id);
  }
}
