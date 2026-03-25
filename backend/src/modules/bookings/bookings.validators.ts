import { z } from 'zod';
import { BookingStatus } from '@prisma/client';

export const createBookingSchema = z.object({
  shopId: z.string().cuid('Invalid shop ID'),
  serviceId: z.string().cuid('Invalid service ID'),
  staffId: z.string().cuid('Invalid staff ID').optional(),
  scheduledDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .refine(
      (date) => new Date(date) >= new Date(new Date().toDateString()),
      'Scheduled date must be today or in the future',
    ),
  scheduledTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Time must be in HH:mm format'),
  notes: z.string().max(500).optional(),
});

export const cancelBookingSchema = z.object({
  reason: z.string().max(500).optional(),
});

export const rescheduleSchema = z.object({
  scheduledDate: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be in YYYY-MM-DD format')
    .refine(
      (date) => new Date(date) >= new Date(new Date().toDateString()),
      'Scheduled date must be today or in the future',
    ),
  scheduledTime: z
    .string()
    .regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Time must be in HH:mm format'),
});

export const assignStaffSchema = z.object({
  staffId: z.string().cuid('Invalid staff ID'),
});

export const listBookingsQuerySchema = z.object({
  status: z.nativeEnum(BookingStatus).optional(),
  startDate: z.string().optional(),
  endDate: z.string().optional(),
  search: z.string().optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.enum(['scheduledDate', 'createdAt', 'totalPrice']).default('scheduledDate'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export const calendarQuerySchema = z.object({
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Start date must be YYYY-MM-DD'),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'End date must be YYYY-MM-DD'),
  view: z.enum(['day', 'week', 'month']).default('week'),
});

export const availabilityQuerySchema = z.object({
  serviceId: z.string().cuid('Invalid service ID'),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD'),
});
