import { Prisma, BookingStatus, Booking } from '@prisma/client';
import { prisma } from '../../config/database';
import { BookingFilters } from './bookings.types';
import { getSkip, getPaginationParams } from '../../shared/utils/pagination';

/**
 * Bookings repository — all Prisma data access for the bookings module.
 */
export const bookingsRepository = {
  /** Create a new booking record. */
  async create(data: Prisma.BookingCreateInput): Promise<Booking> {
    return prisma.booking.create({ data });
  },

  /** Find a booking by ID with all relations. */
  async findById(id: string) {
    return prisma.booking.findUnique({
      where: { id },
      include: {
        customer: { select: { id: true, name: true, email: true, phone: true } },
        shop: { select: { id: true, name: true, address: true, phone: true, email: true } },
        service: { select: { id: true, name: true, duration: true, price: true } },
        staff: { select: { id: true, name: true } },
      },
    });
  },

  /** Find bookings for a customer with optional filters and pagination. */
  async findByCustomer(customerId: string, filters: BookingFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.BookingWhereInput = {
      customerId,
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate || filters.endDate
        ? {
            scheduledDate: {
              ...(filters.startDate && { gte: new Date(filters.startDate) }),
              ...(filters.endDate && { lte: new Date(filters.endDate) }),
            },
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { [filters.sortBy ?? 'scheduledDate']: filters.sortOrder ?? 'desc' },
        include: {
          shop: { select: { id: true, name: true, address: true } },
          service: { select: { id: true, name: true, duration: true, price: true } },
          staff: { select: { id: true, name: true } },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return { items, total };
  },

  /** Find bookings for a shop with optional filters and pagination. */
  async findByShop(shopId: string, filters: BookingFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.BookingWhereInput = {
      shopId,
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate || filters.endDate
        ? {
            scheduledDate: {
              ...(filters.startDate && { gte: new Date(filters.startDate) }),
              ...(filters.endDate && { lte: new Date(filters.endDate) }),
            },
          }
        : {}),
      ...(filters.search
        ? {
            OR: [
              { customer: { name: { contains: filters.search, mode: 'insensitive' } } },
              { service: { name: { contains: filters.search, mode: 'insensitive' } } },
            ],
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { [filters.sortBy ?? 'scheduledDate']: filters.sortOrder ?? 'desc' },
        include: {
          customer: { select: { id: true, name: true, email: true, phone: true } },
          service: { select: { id: true, name: true, duration: true, price: true } },
          staff: { select: { id: true, name: true } },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return { items, total };
  },

  /** Update a booking's status and optional extra fields. */
  async updateStatus(
    id: string,
    status: BookingStatus,
    extra?: Partial<Prisma.BookingUpdateInput>,
  ): Promise<Booking> {
    return prisma.booking.update({
      where: { id },
      data: { status, ...extra },
    });
  },

  /** Update a booking record with arbitrary fields. */
  async update(id: string, data: Partial<Prisma.BookingUpdateInput>): Promise<Booking> {
    return prisma.booking.update({ where: { id }, data });
  },

  /** Find bookings within a date range for calendar view. */
  async findByDateRange(shopId: string, startDate: Date, endDate: Date) {
    return prisma.booking.findMany({
      where: {
        shopId,
        scheduledDate: { gte: startDate, lte: endDate },
        status: { notIn: [BookingStatus.CANCELLED] },
      },
      include: {
        customer: { select: { id: true, name: true } },
        service: { select: { id: true, name: true, duration: true } },
        staff: { select: { id: true, name: true } },
      },
      orderBy: [{ scheduledDate: 'asc' }, { scheduledTime: 'asc' }],
    });
  },

  /** Check for bookings that would overlap the given slot (used for availability). */
  async findOverlapping(
    shopId: string,
    serviceId: string,
    scheduledDate: Date,
    scheduledTime: string,
    durationMinutes: number,
    excludeBookingId?: string,
  ) {
    const [hours, minutes] = scheduledTime.split(':').map(Number);
    const slotStart = new Date(scheduledDate);
    slotStart.setHours(hours, minutes, 0, 0);
    const slotEnd = new Date(slotStart.getTime() + durationMinutes * 60 * 1000);

    const dayStart = new Date(scheduledDate);
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd = new Date(scheduledDate);
    dayEnd.setHours(23, 59, 59, 999);

    const existingBookings = await prisma.booking.findMany({
      where: {
        shopId,
        scheduledDate: { gte: dayStart, lte: dayEnd },
        status: { notIn: [BookingStatus.CANCELLED, BookingStatus.NO_SHOW] },
        ...(excludeBookingId ? { id: { not: excludeBookingId } } : {}),
      },
      include: { service: { select: { duration: true } } },
    });

    return existingBookings.filter((b) => {
      const [bHours, bMinutes] = b.scheduledTime.split(':').map(Number);
      const bStart = new Date(b.scheduledDate);
      bStart.setHours(bHours, bMinutes, 0, 0);
      const bEnd = new Date(bStart.getTime() + b.service.duration * 60 * 1000);

      const bufferMs = 10 * 60 * 1000;
      return (
        slotStart < new Date(bEnd.getTime() + bufferMs) &&
        slotEnd > new Date(bStart.getTime() - bufferMs)
      );
    });
  },

  /** Aggregate booking status counts and revenue for a shop over a date range. */
  async getStats(shopId: string, startDate: Date, endDate: Date) {
    const [grouped, revenueResult] = await Promise.all([
      prisma.booking.groupBy({
        by: ['status'],
        where: { shopId, createdAt: { gte: startDate, lte: endDate } },
        _count: { id: true },
      }),
      prisma.booking.aggregate({
        where: {
          shopId,
          status: BookingStatus.COMPLETED,
          createdAt: { gte: startDate, lte: endDate },
        },
        _sum: { totalPrice: true },
      }),
    ]);

    const counts: Record<string, number> = {};
    grouped.forEach((g) => {
      counts[g.status] = g._count.id;
    });

    return { counts, revenue: revenueResult._sum.totalPrice ?? 0 };
  },

  /** Find all bookings platform-wide (admin). */
  async findAll(filters: BookingFilters & { shopId?: string }) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const where: Prisma.BookingWhereInput = {
      ...(filters.status && { status: filters.status }),
      ...(filters.shopId && { shopId: filters.shopId }),
      ...(filters.startDate || filters.endDate
        ? {
            scheduledDate: {
              ...(filters.startDate && { gte: new Date(filters.startDate) }),
              ...(filters.endDate && { lte: new Date(filters.endDate) }),
            },
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: {
          customer: { select: { id: true, name: true, email: true } },
          shop: { select: { id: true, name: true } },
          service: { select: { id: true, name: true } },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return { items, total };
  },

  /** Get upcoming bookings for a user (future date, pending/confirmed). */
  async findUpcoming(customerId: string) {
    const now = new Date();
    return prisma.booking.findMany({
      where: {
        customerId,
        scheduledDate: { gte: now },
        status: { in: [BookingStatus.PENDING, BookingStatus.CONFIRMED] },
      },
      orderBy: [{ scheduledDate: 'asc' }, { scheduledTime: 'asc' }],
      include: {
        shop: { select: { id: true, name: true, address: true } },
        service: { select: { id: true, name: true, duration: true } },
        staff: { select: { id: true, name: true } },
      },
    });
  },

  /** Get past bookings for a user (paginated). */
  async findHistory(customerId: string, filters: BookingFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const now = new Date();
    const where: Prisma.BookingWhereInput = {
      customerId,
      OR: [
        { scheduledDate: { lt: now } },
        {
          status: {
            in: [BookingStatus.COMPLETED, BookingStatus.CANCELLED, BookingStatus.NO_SHOW],
          },
        },
      ],
    };

    const [items, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { scheduledDate: 'desc' },
        include: {
          shop: { select: { id: true, name: true, address: true } },
          service: { select: { id: true, name: true, duration: true, price: true } },
          staff: { select: { id: true, name: true } },
        },
      }),
      prisma.booking.count({ where }),
    ]);

    return { items, total };
  },
};
