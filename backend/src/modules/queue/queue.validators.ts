import { z } from 'zod';
import { QueueEntryStatus } from '@prisma/client';

export const joinQueueSchema = z.object({
  shopId: z.string().cuid('Invalid shop ID'),
  serviceId: z.string().cuid('Invalid service ID').optional(),
});

export const reorderSchema = z.object({
  entries: z
    .array(
      z.object({
        id: z.string().cuid('Invalid entry ID'),
        position: z.number().int().min(1),
      }),
    )
    .min(1, 'At least one entry required'),
});

export const queueSettingsSchema = z.object({
  isActive: z.boolean().optional(),
  maxCapacity: z.number().int().min(1).max(500).optional(),
  autoAccept: z.boolean().optional(),
  estimatedServiceTime: z.number().int().min(1).max(480).optional(),
});

export const queueStatsQuerySchema = z.object({
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});

export const queueFiltersQuerySchema = z.object({
  status: z.nativeEnum(QueueEntryStatus).optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});
