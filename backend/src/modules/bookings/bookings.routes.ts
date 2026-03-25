import { Router } from 'express';
import { bookingsController } from './bookings.controller';
import { authenticate } from '../../shared/middleware/authenticate';
import { authorize } from '../../shared/middleware/authorize';
import { validate } from '../../shared/middleware/validate';
import { UserRole } from '../../shared/types';
import {
  createBookingSchema,
  cancelBookingSchema,
  rescheduleSchema,
  assignStaffSchema,
  listBookingsQuerySchema,
  calendarQuerySchema,
  availabilityQuerySchema,
} from './bookings.validators';

// ─── Customer Router ──────────────────────────────────────────────────────────
export const bookingsRouter = Router();

bookingsRouter.use(authenticate);

bookingsRouter.post('/', validate(createBookingSchema), bookingsController.createBooking);
bookingsRouter.get('/', validate(listBookingsQuerySchema, 'query'), bookingsController.getUserBookings);
bookingsRouter.get('/upcoming', bookingsController.getUpcomingBookings);
bookingsRouter.get('/history', validate(listBookingsQuerySchema, 'query'), bookingsController.getBookingHistory);
bookingsRouter.get('/:id', bookingsController.getBookingById);
bookingsRouter.get('/:id/receipt', bookingsController.getBookingReceipt);
bookingsRouter.put('/:id/cancel', validate(cancelBookingSchema), bookingsController.cancelBooking);
bookingsRouter.put('/:id/reschedule', validate(rescheduleSchema), bookingsController.rescheduleBooking);

// ─── Shop Owner Router ────────────────────────────────────────────────────────
export const shopBookingsRouter = Router({ mergeParams: true });

shopBookingsRouter.use(authenticate);
shopBookingsRouter.use(authorize(UserRole.SHOP_OWNER, UserRole.ADMIN));

shopBookingsRouter.get('/', validate(listBookingsQuerySchema, 'query'), bookingsController.getShopBookings);
shopBookingsRouter.get('/calendar', validate(calendarQuerySchema, 'query'), bookingsController.getBookingCalendar);
shopBookingsRouter.get('/stats', bookingsController.getBookingStats);
shopBookingsRouter.get('/availability', validate(availabilityQuerySchema, 'query'), bookingsController.checkAvailability);
shopBookingsRouter.get('/:id', bookingsController.getShopBookingById);
shopBookingsRouter.put('/:id/confirm', bookingsController.confirmBooking);
shopBookingsRouter.put('/:id/start', bookingsController.startBooking);
shopBookingsRouter.put('/:id/complete', bookingsController.completeBooking);
shopBookingsRouter.put('/:id/cancel', validate(cancelBookingSchema), bookingsController.shopCancelBooking);
shopBookingsRouter.put('/:id/no-show', bookingsController.markNoShow);
shopBookingsRouter.put('/:id/assign-staff', validate(assignStaffSchema), bookingsController.assignStaff);

// ─── Admin Router ─────────────────────────────────────────────────────────────
export const adminBookingsRouter = Router();

adminBookingsRouter.use(authenticate);
adminBookingsRouter.use(authorize(UserRole.ADMIN));

adminBookingsRouter.get('/', bookingsController.listAllBookings);
adminBookingsRouter.get('/stats', bookingsController.getPlatformBookingStats);
adminBookingsRouter.get('/:id', bookingsController.getBookingByIdAdmin);
