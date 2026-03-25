import { PaymentMethodType, PaymentStatus, RefundStatus, SettlementStatus } from '@prisma/client';

// ─── Input types ─────────────────────────────────────────────────────────────

/** Input for initiating a new payment */
export interface InitiatePaymentInput {
  bookingId: string;
  paymentMethodType: PaymentMethodType;
  savedMethodId?: string;
}

/** Input for verifying a Razorpay payment */
export interface VerifyPaymentInput {
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
}

/** Input for adding a new payment method */
export interface AddPaymentMethodInput {
  type: PaymentMethodType;
  token: string;
  last4?: string;
  brand?: string;
}

/** Input for adding / updating a bank account */
export interface BankAccountInput {
  accountHolderName: string;
  accountNumber: string;
  ifscCode: string;
  bankName: string;
}

// ─── Response / Output types ──────────────────────────────────────────────────

/** Full payment record with related entities */
export interface PaymentWithDetails {
  id: string;
  bookingId: string;
  userId: string;
  shopId: string;
  amount: number;
  taxAmount: number;
  platformFee: number;
  netAmount: number;
  currency: string;
  status: PaymentStatus;
  method?: PaymentMethodType;
  razorpayOrderId?: string;
  razorpayPaymentId?: string;
  transactionId?: string;
  createdAt: Date;
  updatedAt: Date;
  booking?: {
    id: string;
    serviceId: string;
    shopId: string;
    status: string;
  };
  shop?: { id: string; name: string };
}

/** Structured payment receipt */
export interface PaymentReceipt {
  receiptNumber: string;
  payment: PaymentWithDetails;
  bookingDetails: {
    id: string;
    serviceName: string;
    shopName: string;
    bookingDate: Date;
  };
  breakdown: {
    baseAmount: number;
    taxAmount: number;
    discountAmount: number;
    platformFee: number;
    totalAmount: number;
  };
  generatedAt: Date;
}

/** Aggregated payment statistics for a shop */
export interface PaymentStats {
  totalRevenue: number;
  totalTransactions: number;
  averageTransactionValue: number;
  byMethod: Record<string, number>;
  byStatus: Record<string, number>;
  previousPeriodRevenue: number;
  revenueGrowthPercent: number;
}

/** Settlement detail including constituent payments */
export interface SettlementDetail {
  id: string;
  shopId: string;
  amount: number;
  platformFee: number;
  netAmount: number;
  status: SettlementStatus;
  bankAccountId?: string;
  processedAt?: Date;
  createdAt: Date;
  payments: Array<{ id: string; amount: number; createdAt: Date }>;
}

/** Refund request */
export interface RefundRequest {
  paymentId: string;
  userId: string;
  amount: number;
  reason: string;
  status: RefundStatus;
  createdAt: Date;
}

/** Platform-level reconciliation report */
export interface ReconciliationReport {
  period: { from: Date; to: Date };
  totalCollected: number;
  totalRefunded: number;
  totalSettled: number;
  platformRevenue: number;
  pendingSettlements: number;
  discrepancies: Array<{
    paymentId: string;
    issue: string;
  }>;
}

/** User wallet balance and recent transactions */
export interface WalletBalance {
  balance: number;
  currency: string;
  transactions: Array<{
    id: string;
    amount: number;
    type: 'CREDIT' | 'DEBIT';
    description: string;
    createdAt: Date;
    balanceAfter: number;
  }>;
}

/** Pagination helpers */
export interface PaginationParams {
  page: number;
  perPage: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}

/** Payment filter criteria */
export interface PaymentFilters {
  status?: PaymentStatus;
  method?: PaymentMethodType;
  startDate?: Date;
  endDate?: Date;
  minAmount?: number;
  maxAmount?: number;
}

/** Settlement filter criteria */
export interface SettlementFilters {
  status?: SettlementStatus;
  startDate?: Date;
  endDate?: Date;
}
