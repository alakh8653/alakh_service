/**
 * @module disputes/repository
 * @description Data-access layer for the Disputes module.
 *
 * NOTE: The `Dispute`, `DisputeEvidence`, and `DisputeMessage` Prisma models
 * do not yet exist in schema.prisma. All access therefore uses `(prisma as any)`
 * so that this file compiles without changes to the generated client.
 * Once the schema migration is applied the casts should be removed.
 */

import { prisma } from '../../config/database';
import { DisputeStatus, DisputeType, DisputePriority, DisputeOutcome, PenaltyAction, EvidenceType, MessageSenderRole } from './disputes.types';

// ─── Shared includes ─────────────────────────────────────────────────────────

/** Minimal relation set for list views. */
const DISPUTE_LIST_INCLUDE = {
  booking: {
    select: { id: true, bookingNumber: true, totalAmount: true, scheduledAt: true, status: true },
  },
  customer: {
    select: { id: true, name: true, email: true, phone: true },
  },
  provider: {
    select: {
      id: true,
      businessName: true,
      user: { select: { id: true, name: true, email: true } },
    },
  },
};

/** Full relation set for detail views. */
const DISPUTE_DETAIL_INCLUDE = {
  ...DISPUTE_LIST_INCLUDE,
  mediator: { select: { id: true, name: true, email: true } },
  evidence: {
    include: {
      uploader: { select: { id: true, name: true, role: true } },
    },
    orderBy: { createdAt: 'asc' as const },
  },
};

// ─── Priority sort order for queue ───────────────────────────────────────────

/**
 * Converts a DisputePriority to a numeric weight for manual sorting
 * when the DB does not have native enum ordering.
 */
const PRIORITY_WEIGHT: Record<DisputePriority, number> = {
  URGENT: 4,
  HIGH: 3,
  MEDIUM: 2,
  LOW: 1,
};

// ─── Repository ───────────────────────────────────────────────────────────────

export const disputeRepository = {
  // ── Create ────────────────────────────────────────────────────────────────

  /**
   * Persists a new dispute record.
   *
   * @param data - Fields required to create the dispute.
   * @returns The created dispute with its minimal relations.
   */
  async create(data: {
    bookingId: string;
    customerId: string;
    providerId: string;
    type: DisputeType;
    reason: string;
    description: string;
    status: DisputeStatus;
    priority: DisputePriority;
  }): Promise<any> {
    return (prisma as any).dispute.create({
      data,
      include: DISPUTE_LIST_INCLUDE,
    });
  },

  // ── Find by ID ────────────────────────────────────────────────────────────

  /**
   * Fetches a dispute by its primary key with standard relations.
   *
   * @param id - UUID of the dispute.
   * @returns The dispute or `null` if not found.
   */
  async findById(id: string): Promise<any | null> {
    return (prisma as any).dispute.findUnique({
      where: { id },
      include: DISPUTE_DETAIL_INCLUDE,
    });
  },

  /**
   * Fetches a dispute with ALL relations for admin detail views,
   * including the full message thread.
   *
   * @param id - UUID of the dispute.
   * @returns The dispute with all nested data or `null` if not found.
   */
  async findByIdWithFullDetails(id: string): Promise<any | null> {
    return (prisma as any).dispute.findUnique({
      where: { id },
      include: {
        ...DISPUTE_DETAIL_INCLUDE,
        messages: {
          include: {
            sender: { select: { id: true, name: true, role: true } },
          },
          orderBy: { createdAt: 'asc' as const },
        },
      },
    });
  },

  // ── List by User ──────────────────────────────────────────────────────────

  /**
   * Paginates disputes filed by a specific customer.
   *
   * @param userId - UUID of the customer.
   * @param filters - Optional status / type filters.
   * @param pagination - Page & limit values.
   * @returns `{ data, total }` tuple.
   */
  async findByUserId(
    userId: string,
    filters: { status?: DisputeStatus; type?: DisputeType },
    pagination: { skip: number; limit: number; sortBy: string; sortOrder: 'asc' | 'desc' },
  ): Promise<{ data: any[]; total: number }> {
    const where: Record<string, unknown> = { customerId: userId };
    if (filters.status) where['status'] = filters.status;
    if (filters.type) where['type'] = filters.type;

    const [data, total] = await Promise.all([
      (prisma as any).dispute.findMany({
        where,
        include: DISPUTE_LIST_INCLUDE,
        orderBy: { [pagination.sortBy]: pagination.sortOrder },
        skip: pagination.skip,
        take: pagination.limit,
      }),
      (prisma as any).dispute.count({ where }),
    ]);

    return { data, total };
  },

  // ── List by Shop ──────────────────────────────────────────────────────────

  /**
   * Paginates disputes associated with a specific provider/shop.
   *
   * @param providerId - UUID of the provider.
   * @param filters - Optional status / type filters.
   * @param pagination - Page & limit values.
   * @returns `{ data, total }` tuple.
   */
  async findByShopId(
    providerId: string,
    filters: { status?: DisputeStatus; type?: DisputeType },
    pagination: { skip: number; limit: number; sortBy: string; sortOrder: 'asc' | 'desc' },
  ): Promise<{ data: any[]; total: number }> {
    const where: Record<string, unknown> = { providerId };
    if (filters.status) where['status'] = filters.status;
    if (filters.type) where['type'] = filters.type;

    const [data, total] = await Promise.all([
      (prisma as any).dispute.findMany({
        where,
        include: DISPUTE_LIST_INCLUDE,
        orderBy: { [pagination.sortBy]: pagination.sortOrder },
        skip: pagination.skip,
        take: pagination.limit,
      }),
      (prisma as any).dispute.count({ where }),
    ]);

    return { data, total };
  },

  // ── Admin Queue ───────────────────────────────────────────────────────────

  /**
   * Returns the admin moderation queue, optionally filtered and sorted.
   * Disputes are returned sorted by priority (URGENT first) then by
   * creation date ascending by default.
   *
   * @param filters - Full set of admin queue filters.
   * @param pagination - Page & limit values.
   * @returns `{ data, total }` tuple.
   */
  async findQueue(
    filters: {
      status?: DisputeStatus;
      type?: DisputeType;
      priority?: DisputePriority;
      assigneeId?: string;
      startDate?: Date;
      endDate?: Date;
    },
    pagination: { skip: number; limit: number; sortBy: string; sortOrder: 'asc' | 'desc' },
  ): Promise<{ data: any[]; total: number }> {
    const where: Record<string, unknown> = {};

    if (filters.status) {
      where['status'] = filters.status;
    } else {
      // Default: show actionable disputes
      where['status'] = { notIn: ['RESOLVED', 'CLOSED'] };
    }

    if (filters.type) where['type'] = filters.type;
    if (filters.priority) where['priority'] = filters.priority;
    if (filters.assigneeId) where['mediatorId'] = filters.assigneeId;

    if (filters.startDate || filters.endDate) {
      where['createdAt'] = {
        ...(filters.startDate ? { gte: filters.startDate } : {}),
        ...(filters.endDate ? { lte: filters.endDate } : {}),
      };
    }

    const [data, total] = await Promise.all([
      (prisma as any).dispute.findMany({
        where,
        include: DISPUTE_LIST_INCLUDE,
        orderBy: [
          // Sort by priority weight descending, then by the requested field
          { priority: 'asc' }, // Prisma enum order may not match weight; refined in-memory if needed
          { [pagination.sortBy]: pagination.sortOrder },
        ],
        skip: pagination.skip,
        take: pagination.limit,
      }),
      (prisma as any).dispute.count({ where }),
    ]);

    // Re-sort in memory to guarantee URGENT > HIGH > MEDIUM > LOW
    const sorted = (data as any[]).sort(
      (a, b) => (PRIORITY_WEIGHT[b.priority as DisputePriority] ?? 0) -
                (PRIORITY_WEIGHT[a.priority as DisputePriority] ?? 0),
    );

    return { data: sorted, total };
  },

  // ── Update ────────────────────────────────────────────────────────────────

  /**
   * Partially updates a dispute record.
   *
   * @param id - UUID of the dispute to update.
   * @param data - Partial fields to apply.
   * @returns The updated dispute with minimal relations.
   */
  async update(id: string, data: Record<string, unknown>): Promise<any> {
    return (prisma as any).dispute.update({
      where: { id },
      data,
      include: DISPUTE_LIST_INCLUDE,
    });
  },

  // ── Evidence ──────────────────────────────────────────────────────────────

  /**
   * Persists an evidence record.
   *
   * @param data - Evidence fields including the uploaded S3 URL.
   * @returns The created evidence record.
   */
  async createEvidence(data: {
    disputeId: string;
    uploadedBy: string;
    fileUrl: string;
    fileType: EvidenceType;
    description?: string;
  }): Promise<any> {
    return (prisma as any).disputeEvidence.create({
      data,
      include: {
        uploader: { select: { id: true, name: true, role: true } },
      },
    });
  },

  /**
   * Retrieves all evidence records for a given dispute, oldest first.
   *
   * @param disputeId - UUID of the dispute.
   * @returns Array of evidence records.
   */
  async findEvidenceByDisputeId(disputeId: string): Promise<any[]> {
    return (prisma as any).disputeEvidence.findMany({
      where: { disputeId },
      include: {
        uploader: { select: { id: true, name: true, role: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  },

  // ── Messages ──────────────────────────────────────────────────────────────

  /**
   * Appends a message to the dispute thread.
   *
   * @param data - Message payload.
   * @returns The created message with sender info.
   */
  async createMessage(data: {
    disputeId: string;
    senderId: string;
    senderRole: MessageSenderRole;
    content: string;
  }): Promise<any> {
    return (prisma as any).disputeMessage.create({
      data,
      include: {
        sender: { select: { id: true, name: true } },
      },
    });
  },

  /**
   * Paginates the message thread of a dispute (oldest-first).
   *
   * @param disputeId - UUID of the dispute.
   * @param pagination - Page & limit values.
   * @returns `{ data, total }` tuple.
   */
  async findMessages(
    disputeId: string,
    pagination: { skip: number; limit: number },
  ): Promise<{ data: any[]; total: number }> {
    const where = { disputeId };
    const [data, total] = await Promise.all([
      (prisma as any).disputeMessage.findMany({
        where,
        include: { sender: { select: { id: true, name: true } } },
        orderBy: { createdAt: 'asc' },
        skip: pagination.skip,
        take: pagination.limit,
      }),
      (prisma as any).disputeMessage.count({ where }),
    ]);
    return { data, total };
  },

  // ── Statistics ────────────────────────────────────────────────────────────

  /**
   * Computes aggregated dispute statistics for a given time window.
   * Falls back to all-time if no dates are provided.
   *
   * @param startDate - Optional lower bound for `createdAt`.
   * @param endDate - Optional upper bound for `createdAt`.
   * @returns Raw aggregation data (totals by status, type, and resolution timing).
   */
  async getStats(
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    total: number;
    openCount: number;
    resolvedCount: number;
    byType: Record<string, number>;
    byOutcome: Record<string, number>;
    escalatedCount: number;
    resolvedWithTimings: Array<{ createdAt: Date; resolvedAt: Date | null }>;
  }> {
    const dateFilter =
      startDate || endDate
        ? {
            createdAt: {
              ...(startDate ? { gte: startDate } : {}),
              ...(endDate ? { lte: endDate } : {}),
            },
          }
        : {};

    const [total, openCount, resolvedCount, escalatedCount, byTypeRaw, byOutcomeRaw, timedDisputes] =
      await Promise.all([
        (prisma as any).dispute.count({ where: dateFilter }),
        (prisma as any).dispute.count({
          where: { ...dateFilter, status: { notIn: ['RESOLVED', 'CLOSED'] } },
        }),
        (prisma as any).dispute.count({
          where: { ...dateFilter, status: { in: ['RESOLVED', 'CLOSED'] } },
        }),
        (prisma as any).dispute.count({
          where: { ...dateFilter, status: 'ESCALATED' },
        }),
        (prisma as any).dispute.groupBy({
          by: ['type'],
          where: dateFilter,
          _count: { id: true },
        }),
        (prisma as any).dispute.groupBy({
          by: ['outcome'],
          where: { ...dateFilter, outcome: { not: null } },
          _count: { id: true },
        }),
        (prisma as any).dispute.findMany({
          where: { ...dateFilter, status: { in: ['RESOLVED', 'CLOSED'] } },
          select: { createdAt: true, resolvedAt: true },
        }),
      ]);

    const byType: Record<string, number> = {};
    for (const row of byTypeRaw) {
      byType[row.type] = row._count.id;
    }

    const byOutcome: Record<string, number> = {};
    for (const row of byOutcomeRaw) {
      if (row.outcome) byOutcome[row.outcome] = row._count.id;
    }

    return {
      total,
      openCount,
      resolvedCount,
      escalatedCount,
      byType,
      byOutcome,
      resolvedWithTimings: timedDisputes,
    };
  },
};
