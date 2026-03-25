/**
 * @module disputes/validators
 * @description Zod validation schemas for the Disputes module.
 * All schemas are exported so they can be reused in routes and tests.
 */

import { z } from 'zod';

// ─── Enum Arrays (kept in sync with disputes.types.ts) ───────────────────────

const DISPUTE_TYPES = [
  'SERVICE_QUALITY',
  'OVERCHARGE',
  'NO_SHOW',
  'WRONG_SERVICE',
  'DAMAGED_PROPERTY',
  'UNPROFESSIONAL',
  'OTHER',
] as const;

const DISPUTE_STATUSES = [
  'SUBMITTED',
  'UNDER_REVIEW',
  'AWAITING_RESPONSE',
  'ESCALATED',
  'RESOLVED',
  'CLOSED',
] as const;

const DISPUTE_PRIORITIES = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'] as const;

const DISPUTE_OUTCOMES = [
  'CUSTOMER_FAVORED',
  'SHOP_FAVORED',
  'COMPROMISE',
  'DISMISSED',
] as const;

const PENALTY_ACTIONS = ['NONE', 'WARN', 'SUSPEND', 'BAN'] as const;

// ─── Customer Schemas ─────────────────────────────────────────────────────────

/**
 * Validates the body of a "file dispute" request.
 * @example POST /disputes
 */
export const fileDisputeSchema = z.object({
  bookingId: z.string().uuid({ message: 'bookingId must be a valid UUID' }),
  type: z.enum(DISPUTE_TYPES, {
    errorMap: () => ({ message: `type must be one of: ${DISPUTE_TYPES.join(', ')}` }),
  }),
  reason: z
    .string()
    .trim()
    .min(5, 'reason must be at least 5 characters')
    .max(200, 'reason must be at most 200 characters'),
  description: z
    .string()
    .trim()
    .min(20, 'description must be at least 20 characters')
    .max(5000, 'description must be at most 5000 characters'),
});

/**
 * Validates the optional description accompanying an evidence file upload.
 * The actual file is handled by multer.
 * @example POST /disputes/:id/evidence
 */
export const uploadEvidenceSchema = z.object({
  description: z
    .string()
    .trim()
    .max(500, 'description must be at most 500 characters')
    .optional(),
});

/**
 * Validates the body of a message sent inside a dispute thread.
 * @example POST /disputes/:id/messages
 */
export const sendMessageSchema = z.object({
  content: z
    .string()
    .trim()
    .min(1, 'Message content cannot be empty')
    .max(2000, 'Message content must be at most 2000 characters'),
});

// ─── Shop Schemas ─────────────────────────────────────────────────────────────

/**
 * Validates the shop owner's official response to a dispute.
 * @example POST /shops/:shopId/disputes/:id/respond
 */
export const shopResponseSchema = z.object({
  response: z
    .string()
    .trim()
    .min(10, 'Response must be at least 10 characters')
    .max(5000, 'Response must be at most 5000 characters'),
});

/**
 * Validates the shop owner's voluntary acceptance of fault
 * along with any proposed resolution.
 * @example POST /shops/:shopId/disputes/:id/accept
 */
export const shopAcceptSchema = z.object({
  proposedResolution: z.object({
    /** Fixed refund amount offered (INR). */
    refundAmount: z.number().positive('Refund amount must be positive').optional(),
    /** Free-text action the shop offers to take (e.g. "Redo the service"). */
    action: z
      .string()
      .trim()
      .max(500, 'action must be at most 500 characters')
      .optional(),
    /** Additional notes from the shop. */
    notes: z
      .string()
      .trim()
      .max(2000, 'notes must be at most 2000 characters')
      .optional(),
  }),
});

// ─── Admin Schemas ────────────────────────────────────────────────────────────

/**
 * Validates the body when assigning a mediator to a dispute.
 * @example PUT /admin/disputes/:id/assign
 */
export const assignMediatorSchema = z.object({
  mediatorId: z.string().uuid({ message: 'mediatorId must be a valid UUID' }),
});

/**
 * Validates the body when manually escalating a dispute.
 * @example PUT /admin/disputes/:id/escalate
 */
export const escalateDisputeSchema = z.object({
  reason: z
    .string()
    .trim()
    .min(10, 'Escalation reason must be at least 10 characters')
    .max(1000, 'Escalation reason must be at most 1000 characters'),
});

/**
 * Validates the resolution payload supplied by an admin.
 * @example PUT /admin/disputes/:id/resolve
 */
export const resolveDisputeSchema = z
  .object({
    outcome: z.enum(DISPUTE_OUTCOMES, {
      errorMap: () => ({ message: `outcome must be one of: ${DISPUTE_OUTCOMES.join(', ')}` }),
    }),
    refundAmount: z.number().positive('refundAmount must be a positive number').optional(),
    refundPercentage: z
      .number()
      .min(0, 'refundPercentage must be ≥ 0')
      .max(100, 'refundPercentage must be ≤ 100')
      .optional(),
    penaltyAction: z
      .enum(PENALTY_ACTIONS, {
        errorMap: () => ({ message: `penaltyAction must be one of: ${PENALTY_ACTIONS.join(', ')}` }),
      })
      .optional(),
    notes: z
      .string()
      .trim()
      .min(10, 'Resolution notes must be at least 10 characters')
      .max(5000, 'Resolution notes must be at most 5000 characters'),
  })
  .refine(
    (data) => !(data.refundAmount !== undefined && data.refundPercentage !== undefined),
    { message: 'Provide either refundAmount or refundPercentage, not both' },
  );

// ─── Query / Filter Schemas ───────────────────────────────────────────────────

/**
 * Validates query-string filters for paginated dispute list endpoints.
 */
export const disputeFiltersSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.string().trim().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
  status: z.enum(DISPUTE_STATUSES).optional(),
  type: z.enum(DISPUTE_TYPES).optional(),
  priority: z.enum(DISPUTE_PRIORITIES).optional(),
  assigneeId: z.string().uuid().optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  search: z.string().trim().max(200).optional(),
});

/** Validates pagination query for message list. */
export const messagePaginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(50),
});

/** Validates the period filter for admin stats. */
export const statsQuerySchema = z.object({
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
});

// ─── Inferred Types ───────────────────────────────────────────────────────────

export type FileDisputeBody = z.infer<typeof fileDisputeSchema>;
export type UploadEvidenceBody = z.infer<typeof uploadEvidenceSchema>;
export type SendMessageBody = z.infer<typeof sendMessageSchema>;
export type ShopResponseBody = z.infer<typeof shopResponseSchema>;
export type ShopAcceptBody = z.infer<typeof shopAcceptSchema>;
export type AssignMediatorBody = z.infer<typeof assignMediatorSchema>;
export type EscalateDisputeBody = z.infer<typeof escalateDisputeSchema>;
export type ResolveDisputeBody = z.infer<typeof resolveDisputeSchema>;
export type DisputeFiltersQuery = z.infer<typeof disputeFiltersSchema>;
export type MessagePaginationQuery = z.infer<typeof messagePaginationSchema>;
export type StatsQuery = z.infer<typeof statsQuerySchema>;
