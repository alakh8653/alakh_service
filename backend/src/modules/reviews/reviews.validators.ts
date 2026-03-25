import { z } from 'zod';
import { ReviewReportReason } from '@prisma/client';

/** Submit a new review */
export const submitReviewSchema = z.object({
  bookingId: z.string().uuid('Invalid booking ID'),
  rating: z.number().int().min(1).max(5),
  title: z.string().max(100).optional(),
  text: z.string().min(10, 'Review text must be at least 10 characters').max(2000),
  photos: z.array(z.string().url()).max(5, 'Maximum 5 photos allowed').optional(),
});

/** Update an existing review */
export const updateReviewSchema = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  title: z.string().max(100).optional(),
  text: z
    .string()
    .min(10, 'Review text must be at least 10 characters')
    .max(2000)
    .optional(),
  photos: z.array(z.string().url()).max(5).optional(),
});

/** Shop owner response to a review */
export const respondSchema = z.object({
  text: z
    .string()
    .min(10, 'Response must be at least 10 characters')
    .max(1000),
});

/** Report an inappropriate review */
export const reportReviewSchema = z.object({
  reason: z.nativeEnum(ReviewReportReason),
  details: z.string().max(500).optional(),
});

/** Query params for fetching shop reviews */
export const shopReviewsQuerySchema = z.object({
  rating: z.coerce.number().int().min(1).max(5).optional(),
  sortBy: z.enum(['date', 'rating', 'helpful']).default('date'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

/** Query params for listing user's own reviews */
export const userReviewsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

/** Admin filter for listing all reviews */
export const adminReviewFiltersSchema = z.object({
  shopId: z.string().uuid().optional(),
  userId: z.string().uuid().optional(),
  rating: z.coerce.number().int().min(1).max(5).optional(),
  isHidden: z.coerce.boolean().optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

export type SubmitReviewDto = z.infer<typeof submitReviewSchema>;
export type UpdateReviewDto = z.infer<typeof updateReviewSchema>;
export type RespondDto = z.infer<typeof respondSchema>;
export type ReportReviewDto = z.infer<typeof reportReviewSchema>;
export type ShopReviewsQueryDto = z.infer<typeof shopReviewsQuerySchema>;
