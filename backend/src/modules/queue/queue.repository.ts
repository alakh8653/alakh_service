import { Prisma, QueueEntry, QueueEntryStatus, QueueSettings } from '@prisma/client';
import { prisma } from '../../config/database';
import { QueueFilters } from './queue.types';
import { getSkip, getPaginationParams } from '../../shared/utils/pagination';

/**
 * Queue repository — all Prisma data access for the queue module.
 */
export const queueRepository = {
  /** Create a new queue entry. */
  async create(data: Prisma.QueueEntryCreateInput): Promise<QueueEntry> {
    return prisma.queueEntry.create({ data });
  },

  /** Find a queue entry by ID with relations. */
  async findById(id: string) {
    return prisma.queueEntry.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        shop: { select: { id: true, name: true } },
        service: { select: { id: true, name: true, duration: true } },
      },
    });
  },

  /** Get the next available position for a shop queue. */
  async getNextPosition(shopId: string): Promise<number> {
    const last = await prisma.queueEntry.findFirst({
      where: {
        shopId,
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED, QueueEntryStatus.SERVING] },
      },
      orderBy: { position: 'desc' },
      select: { position: true },
    });
    return (last?.position ?? 0) + 1;
  },

  /** Count how many entries are waiting/called ahead of a given position. */
  async countAhead(shopId: string, position: number): Promise<number> {
    return prisma.queueEntry.count({
      where: {
        shopId,
        position: { lt: position },
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED] },
      },
    });
  },

  /** Find active entries for a shop with pagination. */
  async findByShop(shopId: string, filters: QueueFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.QueueEntryWhereInput = {
      shopId,
      ...(filters.status ? { status: filters.status } : {}),
    };

    const [items, total] = await Promise.all([
      prisma.queueEntry.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { position: 'asc' },
        include: {
          user: { select: { id: true, name: true, phone: true } },
          service: { select: { id: true, name: true, duration: true } },
        },
      }),
      prisma.queueEntry.count({ where }),
    ]);

    return { items, total };
  },

  /** Find an active entry for a user in a given shop. */
  async findActiveByUser(userId: string, shopId: string) {
    return prisma.queueEntry.findFirst({
      where: {
        userId,
        shopId,
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED, QueueEntryStatus.SERVING] },
      },
      include: {
        shop: { select: { id: true, name: true } },
        service: { select: { id: true, name: true, duration: true } },
      },
    });
  },

  /** Find all active entries for a user across shops. */
  async findAllActiveByUser(userId: string) {
    return prisma.queueEntry.findMany({
      where: {
        userId,
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED, QueueEntryStatus.SERVING] },
      },
      include: {
        shop: { select: { id: true, name: true } },
        service: { select: { id: true, name: true, duration: true } },
      },
      orderBy: { joinedAt: 'asc' },
    });
  },

  /** Update a queue entry's status. */
  async updateStatus(
    id: string,
    status: QueueEntryStatus,
    extra?: Partial<Prisma.QueueEntryUpdateInput>,
  ): Promise<QueueEntry> {
    return prisma.queueEntry.update({
      where: { id },
      data: { status, ...extra },
    });
  },

  /**
   * Atomically recalculate positions after an entry is removed.
   * Decrements all WAITING/CALLED entries with position > removedPosition.
   */
  async repackPositions(shopId: string, removedPosition: number): Promise<void> {
    await prisma.$executeRaw`
      UPDATE queue_entries
      SET position = position - 1, "updatedAt" = NOW()
      WHERE "shopId" = ${shopId}
        AND position > ${removedPosition}
        AND status IN ('WAITING', 'CALLED')
    `;
  },

  /**
   * Atomically reorder entries using a Prisma transaction.
   * Accepts an array of { id, position } pairs.
   */
  async reorder(shopId: string, entries: Array<{ id: string; position: number }>): Promise<void> {
    await prisma.$transaction(
      entries.map(({ id, position }) =>
        prisma.queueEntry.update({
          where: { id, shopId },
          data: { position },
        }),
      ),
    );
  },

  /** Count entries currently in WAITING or SERVING state for a shop. */
  async countActive(shopId: string): Promise<number> {
    return prisma.queueEntry.count({
      where: {
        shopId,
        status: { in: [QueueEntryStatus.WAITING, QueueEntryStatus.CALLED, QueueEntryStatus.SERVING] },
      },
    });
  },

  /** Get queue settings for a shop. */
  async getSettings(shopId: string): Promise<QueueSettings | null> {
    return prisma.queueSettings.findUnique({ where: { shopId } });
  },

  /** Upsert queue settings for a shop. */
  async upsertSettings(
    shopId: string,
    data: Partial<Prisma.QueueSettingsUpdateInput>,
  ): Promise<QueueSettings> {
    return prisma.queueSettings.upsert({
      where: { shopId },
      create: { shopId, ...data } as Prisma.QueueSettingsCreateInput,
      update: data,
    });
  },

  /** Aggregate queue statistics for a shop over a date range. */
  async getStats(shopId: string, startDate?: Date, endDate?: Date) {
    const dateFilter =
      startDate || endDate
        ? {
            joinedAt: {
              ...(startDate && { gte: startDate }),
              ...(endDate && { lte: endDate }),
            },
          }
        : {};

    const grouped = await prisma.queueEntry.groupBy({
      by: ['status'],
      where: { shopId, ...dateFilter },
      _count: { id: true },
    });

    const counts: Record<string, number> = {};
    grouped.forEach((g) => {
      counts[g.status] = g._count.id;
    });

    return counts;
  },

  /** Find the first WAITING entry (next to be called). */
  async findNextWaiting(shopId: string) {
    return prisma.queueEntry.findFirst({
      where: { shopId, status: QueueEntryStatus.WAITING },
      orderBy: { position: 'asc' },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        service: { select: { id: true, name: true, duration: true } },
      },
    });
  },
};
