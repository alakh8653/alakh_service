import { Prisma, Dispatch, DispatchStatus } from '@prisma/client';
import { prisma } from '../../config/database';
import { DispatchFilters } from './dispatch.types';
import { getSkip, getPaginationParams } from '../../shared/utils/pagination';

/**
 * Dispatch repository — all Prisma data access for the dispatch module.
 */
export const dispatchRepository = {
  /** Create a new dispatch record. */
  async create(data: Prisma.DispatchCreateInput): Promise<Dispatch> {
    return prisma.dispatch.create({ data });
  },

  /** Find a dispatch by ID with full relations. */
  async findById(id: string) {
    return prisma.dispatch.findUnique({
      where: { id },
      include: {
        booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
        staff: { select: { id: true, name: true, phone: true } },
        customer: { select: { id: true, name: true, phone: true } },
        shop: { select: { id: true, name: true, address: true } },
        locationHistory: {
          orderBy: { recordedAt: 'desc' },
          take: 1,
        },
      },
    });
  },

  /** Find a dispatch by booking ID. */
  async findByBookingId(bookingId: string) {
    return prisma.dispatch.findUnique({
      where: { bookingId },
      include: {
        booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
        staff: { select: { id: true, name: true, phone: true } },
        customer: { select: { id: true, name: true, phone: true } },
        shop: { select: { id: true, name: true, address: true } },
      },
    });
  },

  /** Find dispatches for a shop with optional filters. */
  async findByShop(shopId: string, filters: DispatchFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.DispatchWhereInput = {
      shopId,
      ...(filters.status && { status: filters.status }),
      ...(filters.staffId && { staffId: filters.staffId }),
      ...(filters.startDate || filters.endDate
        ? {
            assignedAt: {
              ...(filters.startDate && { gte: new Date(filters.startDate) }),
              ...(filters.endDate && { lte: new Date(filters.endDate) }),
            },
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      prisma.dispatch.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { assignedAt: 'desc' },
        include: {
          booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
          staff: { select: { id: true, name: true, phone: true } },
          customer: { select: { id: true, name: true, phone: true } },
          shop: { select: { id: true, name: true, address: true } },
        },
      }),
      prisma.dispatch.count({ where }),
    ]);

    return { items, total };
  },

  /** Find dispatches assigned to a staff member. */
  async findByStaff(staffId: string, filters: DispatchFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.DispatchWhereInput = {
      staffId,
      ...(filters.status && { status: filters.status }),
    };

    const [items, total] = await Promise.all([
      prisma.dispatch.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { assignedAt: 'desc' },
        include: {
          booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
          customer: { select: { id: true, name: true, phone: true } },
          shop: { select: { id: true, name: true, address: true } },
        },
      }),
      prisma.dispatch.count({ where }),
    ]);

    return { items, total };
  },

  /** Find dispatches for a customer. */
  async findByCustomer(customerId: string, filters: DispatchFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.DispatchWhereInput = {
      customerId,
      ...(filters.status && { status: filters.status }),
    };

    const [items, total] = await Promise.all([
      prisma.dispatch.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { assignedAt: 'desc' },
        include: {
          booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
          staff: { select: { id: true, name: true } },
          shop: { select: { id: true, name: true, address: true } },
        },
      }),
      prisma.dispatch.count({ where }),
    ]);

    return { items, total };
  },

  /** Update dispatch status and optional extra fields. */
  async updateStatus(
    id: string,
    status: DispatchStatus,
    extra?: Partial<Prisma.DispatchUpdateInput>,
  ): Promise<Dispatch> {
    return prisma.dispatch.update({
      where: { id },
      data: { status, ...extra },
    });
  },

  /** Update dispatch record. */
  async update(id: string, data: Partial<Prisma.DispatchUpdateInput>): Promise<Dispatch> {
    return prisma.dispatch.update({ where: { id }, data });
  },

  /** Append a location point to the history for a dispatch. */
  async addLocationHistory(
    dispatchId: string,
    location: {
      latitude: number;
      longitude: number;
      heading?: number;
      speed?: number;
      accuracy?: number;
    },
  ) {
    return prisma.locationHistory.create({
      data: { dispatchId, ...location },
    });
  },

  /** Aggregate dispatch stats for a shop over a date range. */
  async getStats(shopId: string, startDate: Date, endDate: Date) {
    const [grouped, durationResult] = await Promise.all([
      prisma.dispatch.groupBy({
        by: ['status'],
        where: { shopId, assignedAt: { gte: startDate, lte: endDate } },
        _count: { id: true },
      }),
      prisma.dispatch.aggregate({
        where: {
          shopId,
          status: DispatchStatus.COMPLETED,
          assignedAt: { gte: startDate, lte: endDate },
          actualDuration: { not: null },
        },
        _avg: { actualDuration: true },
      }),
    ]);

    const counts: Record<string, number> = {};
    grouped.forEach((g) => {
      counts[g.status] = g._count.id;
    });

    return {
      counts,
      avgDurationMinutes: durationResult._avg.actualDuration ?? 0,
    };
  },

  /** Find all dispatches (admin). */
  async findAll(filters: DispatchFilters & { shopId?: string }) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.DispatchWhereInput = {
      ...(filters.status && { status: filters.status }),
      ...(filters.shopId && { shopId: filters.shopId }),
    };

    const [items, total] = await Promise.all([
      prisma.dispatch.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { assignedAt: 'desc' },
        include: {
          booking: { select: { id: true, scheduledDate: true, scheduledTime: true } },
          staff: { select: { id: true, name: true } },
          customer: { select: { id: true, name: true } },
          shop: { select: { id: true, name: true } },
        },
      }),
      prisma.dispatch.count({ where }),
    ]);

    return { items, total };
  },
};
