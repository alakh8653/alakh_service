import { z } from 'zod';
import { PaymentMethodType, PaymentStatus, SettlementStatus } from '@prisma/client';

/** Initiate a payment for a booking */
export const initiatePaymentSchema = z.object({
  bookingId: z.string().uuid('Invalid booking ID'),
  paymentMethodType: z.nativeEnum(PaymentMethodType),
  savedMethodId: z.string().uuid().optional(),
});

/** Verify Razorpay callback */
export const verifyPaymentSchema = z.object({
  razorpay_order_id: z.string().min(1, 'Razorpay order ID is required'),
  razorpay_payment_id: z.string().min(1, 'Razorpay payment ID is required'),
  razorpay_signature: z.string().min(1, 'Razorpay signature is required'),
});

/** Request a refund */
export const requestRefundSchema = z.object({
  reason: z.string().min(10, 'Reason must be at least 10 characters').max(500),
});

/** Save a new payment method */
export const addPaymentMethodSchema = z.object({
  type: z.nativeEnum(PaymentMethodType),
  token: z.string().min(1, 'Token is required'),
  last4: z.string().length(4).optional(),
  brand: z.string().max(50).optional(),
});

/** Bank account details */
export const bankAccountSchema = z.object({
  accountHolderName: z.string().min(2).max(100),
  accountNumber: z
    .string()
    .regex(/^\d{10,18}$/, 'Account number must be 10-18 digits'),
  ifscCode: z
    .string()
    .regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, 'Invalid IFSC code format'),
  bankName: z.string().min(2).max(100),
});

/** Filters for listing payments */
export const paymentFiltersSchema = z.object({
  status: z.nativeEnum(PaymentStatus).optional(),
  method: z.nativeEnum(PaymentMethodType).optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  minAmount: z.coerce.number().min(0).optional(),
  maxAmount: z.coerce.number().min(0).optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

/** Filters for listing settlements */
export const settlementFiltersSchema = z.object({
  status: z.nativeEnum(SettlementStatus).optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
  page: z.coerce.number().int().min(1).default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
});

/** Admin: send notification to user */
export const adminPaymentFiltersSchema = paymentFiltersSchema.extend({
  userId: z.string().uuid().optional(),
  shopId: z.string().uuid().optional(),
});

export type InitiatePaymentDto = z.infer<typeof initiatePaymentSchema>;
export type VerifyPaymentDto = z.infer<typeof verifyPaymentSchema>;
export type RequestRefundDto = z.infer<typeof requestRefundSchema>;
export type AddPaymentMethodDto = z.infer<typeof addPaymentMethodSchema>;
export type BankAccountDto = z.infer<typeof bankAccountSchema>;
export type PaymentFiltersDto = z.infer<typeof paymentFiltersSchema>;
export type SettlementFiltersDto = z.infer<typeof settlementFiltersSchema>;
