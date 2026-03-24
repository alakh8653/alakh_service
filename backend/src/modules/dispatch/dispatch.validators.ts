import { z } from 'zod';
import { DispatchStatus } from '@prisma/client';

export const createDispatchSchema = z.object({
  bookingId: z.string().cuid('Invalid booking ID'),
  staffId: z.string().cuid('Invalid staff ID'),
  destinationLatitude: z.number().min(-90).max(90).optional(),
  destinationLongitude: z.number().min(-180).max(180).optional(),
});

export const updateLocationSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  heading: z.number().min(0).max(360).optional(),
  speed: z.number().min(0).optional(),
  accuracy: z.number().min(0).optional(),
});

export const rejectDispatchSchema = z.object({
  reason: z.string().max(500).optional(),
});

export const cancelDispatchSchema = z.object({
  reason: z.string().max(500).optional(),
});

export const dispatchFiltersQuerySchema = z.object({
  status: z.nativeEnum(DispatchStatus).optional(),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  staffId: z.string().cuid().optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

export const nearestStaffQuerySchema = z.object({
  latitude: z.coerce.number().min(-90).max(90),
  longitude: z.coerce.number().min(-180).max(180),
  radiusKm: z.coerce.number().min(0.1).max(100).default(10),
});
