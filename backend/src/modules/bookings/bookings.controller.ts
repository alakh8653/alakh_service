import { Response, NextFunction } from 'express';
import { bookingsService } from './bookings.service';
import { AuthenticatedRequest } from '../../shared/types';
import { sendSuccess, sendCreated, sendPaginated } from '../../shared/utils/response';
import { CreateBookingInput, BookingFilters } from './bookings.types';

/**
 * Bookings controller — thin handlers that delegate to the service layer.
 */
export const bookingsController = {
  /** POST /api/v1/bookings */
  async createBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.createBooking(
        req.user!.userId,
        req.body as CreateBookingInput,
      );
      sendCreated(res, booking, 'Booking created successfully');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/bookings */
  async getUserBookings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await bookingsService.getUserBookings(
        req.user!.userId,
        req.query as unknown as BookingFilters,
      );
      sendPaginated(res, result, 'Bookings retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/bookings/upcoming */
  async getUpcomingBookings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const bookings = await bookingsService.getUpcomingBookings(req.user!.userId);
      sendSuccess(res, bookings, 'Upcoming bookings retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/bookings/history */
  async getBookingHistory(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await bookingsService.getBookingHistory(
        req.user!.userId,
        req.query as unknown as BookingFilters,
      );
      sendPaginated(res, result, 'Booking history retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/bookings/:id */
  async getBookingById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.getBookingById(
        req.params.id,
        req.user!.userId,
        req.user!.role,
      );
      sendSuccess(res, booking, 'Booking retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/bookings/:id/receipt */
  async getBookingReceipt(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const receipt = await bookingsService.getBookingReceipt(req.params.id, req.user!.userId);
      sendSuccess(res, receipt, 'Receipt retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/bookings/:id/cancel */
  async cancelBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.cancelBooking(
        req.params.id,
        req.user!.userId,
        req.body.reason,
      );
      sendSuccess(res, booking, 'Booking cancelled');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/bookings/:id/reschedule */
  async rescheduleBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.rescheduleBooking(
        req.params.id,
        req.user!.userId,
        req.body.scheduledDate,
        req.body.scheduledTime,
      );
      sendSuccess(res, booking, 'Booking rescheduled');
    } catch (err) {
      next(err);
    }
  },

  // ─── Shop Owner Handlers ──────────────────────────────────────────────

  /** GET /api/v1/shops/:shopId/bookings */
  async getShopBookings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await bookingsService.getShopBookings(
        req.params.shopId,
        req.user!.userId,
        req.query as unknown as BookingFilters,
      );
      sendPaginated(res, result, 'Shop bookings retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/bookings/:id */
  async getShopBookingById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.getBookingById(
        req.params.id,
        req.user!.userId,
        req.user!.role,
      );
      sendSuccess(res, booking, 'Booking retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/confirm */
  async confirmBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.confirmBooking(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
      );
      sendSuccess(res, booking, 'Booking confirmed');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/start */
  async startBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.startBooking(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
      );
      sendSuccess(res, booking, 'Booking started');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/complete */
  async completeBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.completeBooking(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
      );
      sendSuccess(res, booking, 'Booking completed');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/cancel */
  async shopCancelBooking(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.shopCancelBooking(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
        req.body.reason,
      );
      sendSuccess(res, booking, 'Booking cancelled');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/no-show */
  async markNoShow(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.markNoShow(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
      );
      sendSuccess(res, booking, 'No-show recorded');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/bookings/:id/assign-staff */
  async assignStaff(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.assignStaff(
        req.params.shopId,
        req.user!.userId,
        req.params.id,
        req.body.staffId,
      );
      sendSuccess(res, booking, 'Staff assigned');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/bookings/calendar */
  async getBookingCalendar(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const calendar = await bookingsService.getBookingCalendar(
        req.params.shopId,
        req.user!.userId,
        req.query.startDate as string,
        req.query.endDate as string,
      );
      sendSuccess(res, calendar, 'Calendar retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/bookings/stats */
  async getBookingStats(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const stats = await bookingsService.getBookingStats(
        req.params.shopId,
        req.user!.userId,
        req.query.period as string,
      );
      sendSuccess(res, stats, 'Stats retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/bookings/availability */
  async checkAvailability(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const slots = await bookingsService.checkAvailability(
        req.params.shopId,
        req.query.serviceId as string,
        req.query.date as string,
      );
      sendSuccess(res, slots, 'Availability retrieved');
    } catch (err) {
      next(err);
    }
  },

  // ─── Admin Handlers ──────────────────────────────────────────────────

  /** GET /api/v1/admin/bookings */
  async listAllBookings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await bookingsService.listAllBookings(
        req.query as unknown as BookingFilters & { shopId?: string },
      );
      sendPaginated(res, result, 'All bookings retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/admin/bookings/stats */
  async getPlatformBookingStats(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const stats = await bookingsService.getPlatformBookingStats();
      sendSuccess(res, stats, 'Platform stats retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/admin/bookings/:id */
  async getBookingByIdAdmin(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const booking = await bookingsService.getBookingByIdAdmin(req.params.id);
      sendSuccess(res, booking, 'Booking retrieved');
    } catch (err) {
      next(err);
    }
  },
};
