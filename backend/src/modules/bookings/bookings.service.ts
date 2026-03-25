import { BookingStatus } from '@prisma/client';
import { bookingsRepository } from './bookings.repository';
import {
  CreateBookingInput,
  BookingFilters,
  BookingStats,
  AvailabilitySlot,
  BookingReceipt,
  BookingCalendarView,
} from './bookings.types';
import { buildPaginatedResponse, getPaginationParams } from '../../shared/utils/pagination';
import {
  BadRequestError,
  NotFoundError,
  ForbiddenError,
  ConflictError,
} from '../../shared/errors/AppError';
import { prisma } from '../../config/database';

/** Business hours for slot generation (09:00–18:00 by default). */
const DEFAULT_BUSINESS_HOURS = { start: 9, end: 18 };

/**
 * Bookings service — encapsulates all business logic for the bookings module.
 */
export const bookingsService = {
  /**
   * Create a new booking.
   * Validates service existence, checks slot availability, then persists the record.
   */
  async createBooking(userId: string, data: CreateBookingInput) {
    const service = await prisma.service.findFirst({
      where: { id: data.serviceId, shopId: data.shopId, isActive: true },
    });
    if (!service) throw new NotFoundError('Service not found in this shop');

    const shop = await prisma.shop.findFirst({ where: { id: data.shopId, isActive: true } });
    if (!shop) throw new NotFoundError('Shop not found');

    const scheduledDate = new Date(data.scheduledDate);
    const today = new Date(new Date().toDateString());
    if (scheduledDate < today) {
      throw new BadRequestError('Scheduled date must be today or in the future');
    }

    const overlapping = await bookingsRepository.findOverlapping(
      data.shopId,
      data.serviceId,
      scheduledDate,
      data.scheduledTime,
      service.duration,
    );
    if (overlapping.length > 0) {
      throw new ConflictError('The selected time slot is not available');
    }

    if (data.staffId) {
      const staff = await prisma.user.findFirst({
        where: { id: data.staffId, role: 'STAFF', isActive: true },
      });
      if (!staff) throw new NotFoundError('Staff member not found');
    }

    const booking = await bookingsRepository.create({
      customer: { connect: { id: userId } },
      shop: { connect: { id: data.shopId } },
      service: { connect: { id: data.serviceId } },
      ...(data.staffId ? { staff: { connect: { id: data.staffId } } } : {}),
      scheduledDate,
      scheduledTime: data.scheduledTime,
      notes: data.notes,
      totalPrice: service.price,
      status: BookingStatus.PENDING,
    });

    // TODO: Send notification to shop (push/email/SMS)
    // TODO: Emit booking.created event

    return booking;
  },

  /** Get paginated list of user bookings with optional filters. */
  async getUserBookings(userId: string, filters: BookingFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await bookingsRepository.findByCustomer(userId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /**
   * Get full booking details by ID.
   * Verifies the requesting user has access (customer, assigned staff, shop owner, or admin).
   */
  async getBookingById(bookingId: string, userId: string, role?: string) {
    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');

    const isAdmin = role === 'ADMIN';
    const isCustomer = booking.customerId === userId;
    const isStaff = booking.staffId === userId;
    const isShopOwner = await prisma.shop.findFirst({
      where: { id: booking.shopId, ownerId: userId },
    });

    if (!isAdmin && !isCustomer && !isStaff && !isShopOwner) {
      throw new ForbiddenError('You do not have access to this booking');
    }

    return booking;
  },

  /**
   * Cancel a booking (customer side).
   * Enforces 1-hour minimum notice before scheduled time.
   */
  async cancelBooking(bookingId: string, userId: string, reason?: string) {
    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.customerId !== userId) throw new ForbiddenError('Access denied');

    const nonCancellable: BookingStatus[] = [
      BookingStatus.COMPLETED,
      BookingStatus.CANCELLED,
      BookingStatus.NO_SHOW,
    ];
    if (nonCancellable.includes(booking.status)) {
      throw new BadRequestError(`Cannot cancel a booking with status: ${booking.status}`);
    }

    const now = new Date();
    const bookingDateTime = new Date(booking.scheduledDate);
    const [hours, minutes] = booking.scheduledTime.split(':').map(Number);
    bookingDateTime.setHours(hours, minutes, 0, 0);
    if (bookingDateTime.getTime() - now.getTime() < 60 * 60 * 1000) {
      throw new BadRequestError(
        'Cannot cancel a booking less than 1 hour before scheduled time',
      );
    }

    const updated = await bookingsRepository.updateStatus(bookingId, BookingStatus.CANCELLED, {
      cancellationReason: reason,
      cancelledAt: now,
    });

    // TODO: Initiate refund if payment was made
    // TODO: Notify shop about cancellation
    // TODO: Emit booking.cancelled event

    return updated;
  },

  /** Reschedule a booking to a new date/time after checking slot availability. */
  async rescheduleBooking(
    bookingId: string,
    userId: string,
    newDate: string,
    newTime: string,
  ) {
    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.customerId !== userId) throw new ForbiddenError('Access denied');

    const reschedulable: BookingStatus[] = [BookingStatus.PENDING, BookingStatus.CONFIRMED];
    if (!reschedulable.includes(booking.status)) {
      throw new BadRequestError(`Cannot reschedule a booking with status: ${booking.status}`);
    }

    const newScheduledDate = new Date(newDate);
    const today = new Date(new Date().toDateString());
    if (newScheduledDate < today) {
      throw new BadRequestError('New scheduled date must be today or in the future');
    }

    const service = await prisma.service.findUnique({ where: { id: booking.serviceId } });
    if (!service) throw new NotFoundError('Service not found');

    const overlapping = await bookingsRepository.findOverlapping(
      booking.shopId,
      booking.serviceId,
      newScheduledDate,
      newTime,
      service.duration,
      bookingId,
    );
    if (overlapping.length > 0) {
      throw new ConflictError('The selected time slot is not available');
    }

    const updated = await bookingsRepository.update(bookingId, {
      scheduledDate: newScheduledDate,
      scheduledTime: newTime,
    });

    // TODO: Notify shop about reschedule
    return updated;
  },

  /** Get upcoming bookings for a user (future date, pending/confirmed). */
  async getUpcomingBookings(userId: string) {
    return bookingsRepository.findUpcoming(userId);
  },

  /** Get booking history for a user (paginated). */
  async getBookingHistory(userId: string, filters: BookingFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await bookingsRepository.findHistory(userId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Generate a booking receipt with all details. */
  async getBookingReceipt(bookingId: string, userId: string): Promise<BookingReceipt> {
    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.customerId !== userId) throw new ForbiddenError('Access denied');

    return {
      bookingId: booking.id,
      bookingDate: booking.createdAt,
      service: {
        name: booking.service.name,
        duration: booking.service.duration,
        price: booking.service.price,
      },
      shop: {
        name: booking.shop.name,
        address: booking.shop.address,
        phone: booking.shop.phone ?? undefined,
      },
      customer: {
        name: booking.customer.name,
        email: booking.customer.email ?? undefined,
        phone: booking.customer.phone ?? undefined,
      },
      staff: booking.staff ? { name: booking.staff.name } : undefined,
      scheduledDate: booking.scheduledDate,
      scheduledTime: booking.scheduledTime,
      totalAmount: booking.totalPrice,
      paymentStatus: booking.paymentStatus,
      status: booking.status,
    };
  },

  /** Get shop bookings (shop owner access). */
  async getShopBookings(shopId: string, ownerId: string, filters: BookingFilters) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Shop not found or access denied');

    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await bookingsRepository.findByShop(shopId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Confirm a pending booking (shop owner). */
  async confirmBooking(shopId: string, ownerId: string, bookingId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Booking does not belong to this shop');
    if (booking.status !== BookingStatus.PENDING) {
      throw new BadRequestError(`Cannot confirm a booking with status: ${booking.status}`);
    }

    const updated = await bookingsRepository.updateStatus(bookingId, BookingStatus.CONFIRMED);
    // TODO: Notify customer of confirmation
    return updated;
  },

  /** Mark a confirmed booking as in-progress (shop owner). */
  async startBooking(shopId: string, ownerId: string, bookingId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Access denied');
    if (booking.status !== BookingStatus.CONFIRMED) {
      throw new BadRequestError(`Cannot start a booking with status: ${booking.status}`);
    }

    return bookingsRepository.updateStatus(bookingId, BookingStatus.IN_PROGRESS, {
      startedAt: new Date(),
    });
  },

  /** Mark an in-progress booking as completed (shop owner). */
  async completeBooking(shopId: string, ownerId: string, bookingId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Access denied');
    if (booking.status !== BookingStatus.IN_PROGRESS) {
      throw new BadRequestError(`Cannot complete a booking with status: ${booking.status}`);
    }

    const updated = await bookingsRepository.updateStatus(bookingId, BookingStatus.COMPLETED, {
      completedAt: new Date(),
    });

    // TODO: Trigger payment capture
    // TODO: Prompt customer to leave a review
    // TODO: Update queue if applicable
    return updated;
  },

  /** Cancel a booking from the shop side. */
  async shopCancelBooking(shopId: string, ownerId: string, bookingId: string, reason?: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Access denied');

    const nonCancellable: BookingStatus[] = [BookingStatus.COMPLETED, BookingStatus.CANCELLED];
    if (nonCancellable.includes(booking.status)) {
      throw new BadRequestError(`Cannot cancel a booking with status: ${booking.status}`);
    }

    const updated = await bookingsRepository.updateStatus(bookingId, BookingStatus.CANCELLED, {
      cancellationReason: reason,
      cancelledAt: new Date(),
    });

    // TODO: Initiate refund if payment was made
    // TODO: Notify customer of cancellation
    return updated;
  },

  /** Mark a customer as a no-show (shop owner). */
  async markNoShow(shopId: string, ownerId: string, bookingId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Access denied');

    const noShowAllowed: BookingStatus[] = [BookingStatus.CONFIRMED, BookingStatus.PENDING];
    if (!noShowAllowed.includes(booking.status)) {
      throw new BadRequestError(
        `Cannot mark no-show for booking with status: ${booking.status}`,
      );
    }

    const updated = await bookingsRepository.updateStatus(bookingId, BookingStatus.NO_SHOW, {
      noShowAt: new Date(),
    });

    // TODO: Apply no-show policy (fee, ban, etc.)
    return updated;
  },

  /** Assign or reassign a staff member to a booking (shop owner). */
  async assignStaff(shopId: string, ownerId: string, bookingId: string, staffId: string) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.shopId !== shopId) throw new ForbiddenError('Access denied');

    const staff = await prisma.user.findFirst({ where: { id: staffId, isActive: true } });
    if (!staff) throw new NotFoundError('Staff member not found');

    return bookingsRepository.update(bookingId, { staff: { connect: { id: staffId } } });
  },

  /** Get bookings in calendar view format grouped by day. */
  async getBookingCalendar(
    shopId: string,
    ownerId: string,
    startDate: string,
    endDate: string,
  ): Promise<BookingCalendarView> {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const start = new Date(startDate);
    const end = new Date(endDate);
    const bookings = await bookingsRepository.findByDateRange(shopId, start, end);

    const dayMap = new Map<string, typeof bookings>();
    bookings.forEach((booking) => {
      const dateKey = booking.scheduledDate.toISOString().split('T')[0];
      if (!dayMap.has(dateKey)) dayMap.set(dateKey, []);
      dayMap.get(dateKey)!.push(booking);
    });

    const days: BookingCalendarView['days'] = [];
    const cursor = new Date(start);
    while (cursor <= end) {
      const dateKey = cursor.toISOString().split('T')[0];
      days.push({
        date: dateKey,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        bookings: (dayMap.get(dateKey) ?? []) as any,
      });
      cursor.setDate(cursor.getDate() + 1);
    }

    return { view: 'week', startDate, endDate, days };
  },

  /** Get booking statistics for a shop over a configurable period. */
  async getBookingStats(shopId: string, ownerId: string, period = '30d'): Promise<BookingStats> {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const days = parseInt(period) || 30;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const { counts, revenue } = await bookingsRepository.getStats(shopId, startDate, endDate);

    const total = Object.values(counts).reduce((a, b) => a + b, 0);
    const completed = counts[BookingStatus.COMPLETED] ?? 0;
    const cancelled = counts[BookingStatus.CANCELLED] ?? 0;

    return {
      totalBookings: total,
      completedBookings: completed,
      cancelledBookings: cancelled,
      noShowBookings: counts[BookingStatus.NO_SHOW] ?? 0,
      completionRate: total > 0 ? (completed / total) * 100 : 0,
      cancellationRate: total > 0 ? (cancelled / total) * 100 : 0,
      revenue,
      avgBookingsPerDay: days > 0 ? total / days : 0,
      periodStart: startDate.toISOString(),
      periodEnd: endDate.toISOString(),
    };
  },

  /** Check available time slots for a service on a given date. */
  async checkAvailability(
    shopId: string,
    serviceId: string,
    date: string,
  ): Promise<AvailabilitySlot[]> {
    const service = await prisma.service.findFirst({
      where: { id: serviceId, shopId, isActive: true },
    });
    if (!service) throw new NotFoundError('Service not found');

    const scheduledDate = new Date(date);
    const slots: AvailabilitySlot[] = [];

    for (let hour = DEFAULT_BUSINESS_HOURS.start; hour < DEFAULT_BUSINESS_HOURS.end; hour++) {
      for (let minute = 0; minute < 60; minute += service.duration) {
        const slotEndMinute = hour * 60 + minute + service.duration;
        if (slotEndMinute > DEFAULT_BUSINESS_HOURS.end * 60) break;

        const timeStr = `${String(hour).padStart(2, '0')}:${String(minute).padStart(2, '0')}`;
        const overlapping = await bookingsRepository.findOverlapping(
          shopId,
          serviceId,
          scheduledDate,
          timeStr,
          service.duration,
        );
        slots.push({ time: timeStr, available: overlapping.length === 0 });
      }
    }

    return slots;
  },

  // ─── Admin Methods ─────────────────────────────────────────────────────

  /** List all bookings platform-wide (admin). */
  async listAllBookings(filters: BookingFilters & { shopId?: string }) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await bookingsRepository.findAll(filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Get platform-wide booking statistics (admin). */
  async getPlatformBookingStats() {
    const [grouped, revenueResult] = await Promise.all([
      prisma.booking.groupBy({ by: ['status'], _count: { id: true } }),
      prisma.booking.aggregate({
        where: { status: BookingStatus.COMPLETED },
        _sum: { totalPrice: true },
      }),
    ]);

    const counts: Record<string, number> = {};
    grouped.forEach((g) => {
      counts[g.status] = g._count.id;
    });

    const total = Object.values(counts).reduce((a, b) => a + b, 0);
    const completed = counts[BookingStatus.COMPLETED] ?? 0;
    const cancelled = counts[BookingStatus.CANCELLED] ?? 0;

    return {
      totalBookings: total,
      completedBookings: completed,
      cancelledBookings: cancelled,
      completionRate: total > 0 ? (completed / total) * 100 : 0,
      cancellationRate: total > 0 ? (cancelled / total) * 100 : 0,
      totalRevenue: revenueResult._sum.totalPrice ?? 0,
    };
  },

  /** Get any booking details by ID (admin access). */
  async getBookingByIdAdmin(bookingId: string) {
    const booking = await bookingsRepository.findById(bookingId);
    if (!booking) throw new NotFoundError('Booking not found');
    return booking;
  },
};
