import { QueueEntryStatus } from '@prisma/client';
import { queueRepository } from './queue.repository';
import {
  JoinQueueInput,
  QueueStatusResponse,
  QueueStats,
  QueueSettingsInput,
  QueueFilters,
} from './queue.types';
import { buildPaginatedResponse, getPaginationParams } from '../../shared/utils/pagination';
import {
  BadRequestError,
  NotFoundError,
  ForbiddenError,
  ConflictError,
} from '../../shared/errors/AppError';
import { prisma } from '../../config/database';

/**
 * Queue service — encapsulates all business logic for the queue module.
 */
export const queueService = {
  /**
   * Add a customer to a shop's queue.
   * Validates shop capacity and prevents duplicate active entries.
   */
  async joinQueue(userId: string, data: JoinQueueInput): Promise<QueueStatusResponse> {
    const shop = await prisma.shop.findFirst({ where: { id: data.shopId, isActive: true } });
    if (!shop) throw new NotFoundError('Shop not found');

    const settings = await queueRepository.getSettings(data.shopId);
    if (settings && !settings.isActive) {
      throw new BadRequestError('The queue for this shop is currently closed');
    }

    // Prevent duplicate active entries
    const existing = await queueRepository.findActiveByUser(userId, data.shopId);
    if (existing) {
      throw new ConflictError('You are already in the queue for this shop');
    }

    // Check capacity
    if (settings) {
      const activeCount = await queueRepository.countActive(data.shopId);
      if (activeCount >= settings.maxCapacity) {
        throw new BadRequestError('The queue is full. Please try again later.');
      }
    }

    if (data.serviceId) {
      const service = await prisma.service.findFirst({
        where: { id: data.serviceId, shopId: data.shopId, isActive: true },
      });
      if (!service) throw new NotFoundError('Service not found in this shop');
    }

    const position = await queueRepository.getNextPosition(data.shopId);

    const entry = await queueRepository.create({
      shop: { connect: { id: data.shopId } },
      user: { connect: { id: userId } },
      ...(data.serviceId ? { service: { connect: { id: data.serviceId } } } : {}),
      position,
      status: QueueEntryStatus.WAITING,
    });

    const aheadCount = await queueRepository.countAhead(data.shopId, position);
    const estimatedServiceTime = settings?.estimatedServiceTime ?? 15;

    // TODO: Emit queue.joined WebSocket event to shop dashboard
    // TODO: Send SMS/push notification with queue position

    return {
      entryId: entry.id,
      position,
      estimatedWaitMinutes: aheadCount * estimatedServiceTime,
      status: entry.status,
      aheadCount,
      shopName: shop.name,
      joinedAt: entry.joinedAt,
    };
  },

  /** Get the current queue status for a specific entry. */
  async getQueueStatus(entryId: string, userId: string): Promise<QueueStatusResponse> {
    const entry = await queueRepository.findById(entryId);
    if (!entry) throw new NotFoundError('Queue entry not found');
    if (entry.userId !== userId) throw new ForbiddenError('Access denied');

    const settings = await queueRepository.getSettings(entry.shopId);
    const estimatedServiceTime = settings?.estimatedServiceTime ?? 15;
    const aheadCount = await queueRepository.countAhead(entry.shopId, entry.position);

    return {
      entryId: entry.id,
      position: entry.position,
      estimatedWaitMinutes: aheadCount * estimatedServiceTime,
      status: entry.status,
      aheadCount,
      shopName: entry.shop.name,
      serviceName: entry.service?.name,
      joinedAt: entry.joinedAt,
    };
  },

  /** Allow a customer to voluntarily leave the queue. */
  async leaveQueue(entryId: string, userId: string): Promise<void> {
    const entry = await queueRepository.findById(entryId);
    if (!entry) throw new NotFoundError('Queue entry not found');
    if (entry.userId !== userId) throw new ForbiddenError('Access denied');

    const leavable: QueueEntryStatus[] = [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED];
    if (!leavable.includes(entry.status)) {
      throw new BadRequestError(`Cannot leave queue with status: ${entry.status}`);
    }

    await queueRepository.updateStatus(entryId, QueueEntryStatus.LEFT);
    await queueRepository.repackPositions(entry.shopId, entry.position);

    // TODO: Emit queue.left event to shop dashboard
  },

  /** Get all active queue entries for a user. */
  async getUserQueueEntries(userId: string) {
    return queueRepository.findAllActiveByUser(userId);
  },

  // ─── Shop Owner Methods ───────────────────────────────────────────────

  /** Get the live queue for a shop (paginated). */
  async getShopQueue(shopId: string, ownerId: string, filters: QueueFilters) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Shop not found or access denied');

    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await queueRepository.findByShop(shopId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Call the next customer in line (transitions WAITING → CALLED). */
  async callNext(shopId: string, ownerId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const next = await queueRepository.findNextWaiting(shopId);
    if (!next) throw new NotFoundError('No customers waiting in queue');

    const updated = await queueRepository.updateStatus(next.id, QueueEntryStatus.CALLED, {
      calledAt: new Date(),
    });

    // TODO: Send push/SMS notification to customer that they are being called
    // TODO: Emit queue.called WebSocket event

    return updated;
  },

  /** Mark a called entry as currently being served (CALLED → SERVING). */
  async startServing(shopId: string, ownerId: string, entryId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const entry = await queueRepository.findById(entryId);
    if (!entry) throw new NotFoundError('Queue entry not found');
    if (entry.shopId !== shopId) throw new ForbiddenError('Access denied');
    if (entry.status !== QueueEntryStatus.CALLED) {
      throw new BadRequestError(`Cannot serve entry with status: ${entry.status}`);
    }

    return queueRepository.updateStatus(entryId, QueueEntryStatus.SERVING, {
      servedAt: new Date(),
    });
  },

  /** Mark a serving entry as completed. */
  async completeEntry(shopId: string, ownerId: string, entryId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const entry = await queueRepository.findById(entryId);
    if (!entry) throw new NotFoundError('Queue entry not found');
    if (entry.shopId !== shopId) throw new ForbiddenError('Access denied');
    if (entry.status !== QueueEntryStatus.SERVING) {
      throw new BadRequestError(`Cannot complete entry with status: ${entry.status}`);
    }

    const updated = await queueRepository.updateStatus(entryId, QueueEntryStatus.COMPLETED, {
      completedAt: new Date(),
    });

    // TODO: Emit queue.completed event
    return updated;
  },

  /** Skip a customer (WAITING/CALLED → SKIPPED) and repack positions. */
  async skipEntry(shopId: string, ownerId: string, entryId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const entry = await queueRepository.findById(entryId);
    if (!entry) throw new NotFoundError('Queue entry not found');
    if (entry.shopId !== shopId) throw new ForbiddenError('Access denied');

    const skippable: QueueEntryStatus[] = [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED];
    if (!skippable.includes(entry.status)) {
      throw new BadRequestError(`Cannot skip entry with status: ${entry.status}`);
    }

    await queueRepository.updateStatus(entryId, QueueEntryStatus.SKIPPED);
    await queueRepository.repackPositions(shopId, entry.position);

    // TODO: Notify customer that they were skipped
  },

  /**
   * Reorder queue entries for a shop using a Prisma transaction.
   * Validates that all provided entry IDs belong to the shop.
   */
  async reorderQueue(
    shopId: string,
    ownerId: string,
    entries: Array<{ id: string; position: number }>,
  ) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    // Validate all entries belong to this shop
    const ids = entries.map((e) => e.id);
    const dbEntries = await prisma.queueEntry.findMany({
      where: { id: { in: ids }, shopId },
      select: { id: true },
    });
    if (dbEntries.length !== ids.length) {
      throw new BadRequestError('One or more queue entries not found in this shop');
    }

    await queueRepository.reorder(shopId, entries);

    // TODO: Emit queue.reordered WebSocket event to all connected clients
  },

  /** Get or create queue settings for a shop. */
  async getQueueSettings(shopId: string, ownerId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const settings = await queueRepository.getSettings(shopId);
    if (!settings) {
      return queueRepository.upsertSettings(shopId, {});
    }
    return settings;
  },

  /** Update queue settings for a shop. */
  async updateQueueSettings(shopId: string, ownerId: string, data: QueueSettingsInput) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    return queueRepository.upsertSettings(shopId, data);
  },

  /** Get queue statistics for a shop. */
  async getQueueStats(
    shopId: string,
    ownerId: string,
    startDate?: string,
    endDate?: string,
  ): Promise<QueueStats> {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const settings = await queueRepository.getSettings(shopId);
    const estimatedServiceTime = settings?.estimatedServiceTime ?? 15;

    const counts = await queueRepository.getStats(
      shopId,
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );

    const waiting = counts[QueueEntryStatus.WAITING] ?? 0;
    const serving = counts[QueueEntryStatus.SERVING] ?? 0;
    const completed = counts[QueueEntryStatus.COMPLETED] ?? 0;
    const skipped = counts[QueueEntryStatus.SKIPPED] ?? 0;

    return {
      totalWaiting: waiting,
      totalServing: serving,
      totalCompleted: completed,
      totalSkipped: skipped,
      avgWaitMinutes: estimatedServiceTime,
      currentPosition: waiting + serving,
      estimatedClearMinutes: waiting * estimatedServiceTime,
    };
  },

  /** Clear the entire queue for a shop (mark all WAITING/CALLED as LEFT). */
  async clearQueue(shopId: string, ownerId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const result = await prisma.queueEntry.updateMany({
      where: {
        shopId,
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED] },
      },
      data: { status: QueueEntryStatus.LEFT },
    });

    // TODO: Notify all waiting customers that queue was cleared
    return { clearedCount: result.count };
  },
};
