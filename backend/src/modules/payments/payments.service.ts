import crypto from 'crypto';
import { PaymentsRepository } from './payments.repository';
import {
  InitiatePaymentInput,
  VerifyPaymentInput,
  AddPaymentMethodInput,
  BankAccountInput,
  PaymentFilters,
  SettlementFilters,
  PaginationParams,
  PaymentReceipt,
  PaymentStats,
  SettlementDetail,
  WalletBalance,
  ReconciliationReport,
} from './payments.types';
import {
  BadRequestError,
  ConflictError,
  ForbiddenError,
  NotFoundError,
} from '../../shared/errors/AppError';
import prisma from '../../config/database';

const PLATFORM_COMMISSION_PERCENT =
  parseFloat(process.env.PLATFORM_COMMISSION_PERCENT ?? '10') / 100;
const GST_PERCENT = parseFloat(process.env.GST_PERCENT ?? '18') / 100;
const REFUND_WINDOW_HOURS = parseInt(
  process.env.REFUND_WINDOW_HOURS ?? '24',
  10,
);
const MIN_PAYOUT_AMOUNT = parseFloat(process.env.MIN_PAYOUT_AMOUNT ?? '500');

/**
 * Business logic for the payments module.
 */
export class PaymentsService {
  private readonly repo: PaymentsRepository;

  constructor() {
    this.repo = new PaymentsRepository();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /**
   * Calculate platform commission on a payment amount.
   * @param amount - Gross amount in INR
   */
  calculateCommission(amount: number): number {
    return parseFloat((amount * PLATFORM_COMMISSION_PERCENT).toFixed(2));
  }

  /**
   * Calculate GST applicable on the service amount.
   * @param amount - Base amount
   */
  calculateTax(amount: number): number {
    return parseFloat((amount * GST_PERCENT).toFixed(2));
  }

  // ─── Customer: Payment lifecycle ──────────────────────────────────────────

  /**
   * Initiate a payment for a booking.
   * Creates a Razorpay order and persists a PENDING payment record.
   *
   * @param userId - Authenticated customer
   * @param data   - Booking + payment method details
   */
  async initiatePayment(userId: string, data: InitiatePaymentInput) {
    // Validate booking exists and belongs to user
    const booking = await prisma.serviceBooking.findUnique({
      where: { id: data.bookingId },
    });

    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.customerId !== userId)
      throw new ForbiddenError('Booking does not belong to this user');

    // Idempotency check – prevent double payments
    const existing = await this.repo.findPaymentByBookingId(data.bookingId);
    if (existing && existing.status === 'COMPLETED') {
      throw new ConflictError('Booking is already paid');
    }
    if (existing && existing.status === 'PENDING') {
      return existing; // Return existing order for retry
    }

    const baseAmount = booking.totalAmount;
    const discountAmount = booking.discountAmount;
    const taxAmount = this.calculateTax(baseAmount - discountAmount);
    const platformFee = this.calculateCommission(baseAmount - discountAmount);
    const totalAmount = parseFloat(
      (baseAmount - discountAmount + taxAmount).toFixed(2),
    );
    const netAmount = parseFloat((totalAmount - platformFee).toFixed(2));

    const idempotencyKey = `booking_${data.bookingId}_${userId}`;

    // TODO: Integrate Razorpay SDK
    // const razorpay = new Razorpay({ key_id: process.env.RAZORPAY_KEY_ID, key_secret: process.env.RAZORPAY_KEY_SECRET });
    // const order = await razorpay.orders.create({ amount: Math.round(totalAmount * 100), currency: 'INR', receipt: idempotencyKey });
    const mockOrderId = `order_${crypto.randomBytes(10).toString('hex')}`;

    const payment = await this.repo.createPayment({
      booking: { connect: { id: data.bookingId } },
      user: { connect: { id: userId } },
      shop: { connect: { id: booking.shopId } },
      amount: totalAmount,
      taxAmount,
      platformFee,
      netAmount,
      method: data.paymentMethodType,
      razorpayOrderId: mockOrderId,
      idempotencyKey,
    });

    return {
      paymentId: payment.id,
      razorpayOrderId: mockOrderId,
      amount: totalAmount,
      currency: 'INR',
      taxAmount,
      breakdown: { baseAmount, discountAmount, taxAmount, totalAmount },
    };
  }

  /**
   * Verify a Razorpay payment callback using HMAC-SHA256 signature.
   * Updates payment to COMPLETED and confirms the booking.
   */
  async verifyPayment(userId: string, data: VerifyPaymentInput) {
    const payment = await this.repo.findPaymentByOrderId(
      data.razorpay_order_id,
    );
    if (!payment) throw new NotFoundError('Payment order not found');
    if (payment.userId !== userId)
      throw new ForbiddenError('Payment does not belong to this user');

    // Idempotency – already verified
    if (payment.status === 'COMPLETED') return payment;

    // Verify Razorpay signature
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET ?? '')
      .update(`${data.razorpay_order_id}|${data.razorpay_payment_id}`)
      .digest('hex');

    if (expectedSignature !== data.razorpay_signature) {
      await this.repo.updatePayment(payment.id, { status: 'FAILED' });
      throw new BadRequestError('Invalid payment signature');
    }

    // Update payment + booking atomically
    const [updatedPayment] = await prisma.$transaction([
      prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: 'COMPLETED',
          razorpayPaymentId: data.razorpay_payment_id,
          transactionId: data.razorpay_payment_id,
          gatewayResponse: { ...data },
        },
      }),
      prisma.serviceBooking.update({
        where: { id: payment.bookingId },
        data: { status: 'CONFIRMED' },
      }),
    ]);

    // TODO: Send payment receipt notification (emit event to notification service)

    return updatedPayment;
  }

  /** List payments for a user with filters and pagination */
  async getUserPayments(
    userId: string,
    filters: PaymentFilters,
    pagination: PaginationParams,
  ) {
    return this.repo.listUserPayments(userId, filters, pagination);
  }

  /** Get payment details – verifies the requester has access */
  async getPaymentById(paymentId: string, userId: string) {
    const payment = await this.repo.findPaymentWithDetails(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');
    if (payment.userId !== userId)
      throw new ForbiddenError('Access denied');
    return payment;
  }

  /** Generate receipt data for a completed payment */
  async getPaymentReceipt(
    paymentId: string,
    userId: string,
  ): Promise<PaymentReceipt> {
    const payment = await this.repo.findPaymentWithDetails(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');
    if (payment.userId !== userId)
      throw new ForbiddenError('Access denied');
    if (payment.status !== 'COMPLETED')
      throw new BadRequestError('Receipt only available for completed payments');

    const booking = await prisma.serviceBooking.findUnique({
      where: { id: payment.bookingId },
    });

    return {
      receiptNumber: `RCP-${payment.id.slice(0, 8).toUpperCase()}`,
      payment: payment as never,
      bookingDetails: {
        id: payment.bookingId,
        serviceName: `Service #${booking?.serviceId ?? ''}`,
        shopName: payment.shop?.name ?? '',
        bookingDate: booking?.createdAt ?? new Date(),
      },
      breakdown: {
        baseAmount: payment.amount - payment.taxAmount,
        taxAmount: payment.taxAmount,
        discountAmount: 0,
        platformFee: payment.platformFee,
        totalAmount: payment.amount,
      },
      generatedAt: new Date(),
    };
  }

  /**
   * Request a refund for a completed payment.
   * Validates time-window eligibility and creates a PENDING refund record.
   */
  async requestRefund(
    paymentId: string,
    userId: string,
    reason: string,
  ) {
    const payment = await this.repo.findPaymentById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');
    if (payment.userId !== userId)
      throw new ForbiddenError('Access denied');
    if (payment.status !== 'COMPLETED')
      throw new BadRequestError('Only completed payments can be refunded');

    const windowMs = REFUND_WINDOW_HOURS * 60 * 60 * 1000;
    const elapsed = Date.now() - payment.createdAt.getTime();
    if (elapsed > windowMs) {
      throw new BadRequestError(
        `Refund window of ${REFUND_WINDOW_HOURS} hours has expired`,
      );
    }

    // Check for existing pending refund
    const existingRefunds = await this.repo.findRefundsByPayment(paymentId);
    const hasPending = existingRefunds.some((r) => r.status === 'PENDING');
    if (hasPending) throw new ConflictError('A refund request already exists');

    const refund = await this.repo.createRefund({
      payment: { connect: { id: paymentId } },
      user: { connect: { id: userId } },
      amount: payment.amount,
      reason,
    });

    // TODO: Notify admin about refund request (emit event)

    return refund;
  }

  // ─── Payment Methods ───────────────────────────────────────────────────────

  /** List saved payment methods for a user */
  async getPaymentMethods(userId: string) {
    return this.repo.listUserPaymentMethods(userId);
  }

  /** Tokenize and save a new payment method */
  async addPaymentMethod(userId: string, data: AddPaymentMethodInput) {
    // TODO: Validate & tokenize via Razorpay before storing
    return this.repo.createPaymentMethod({
      user: { connect: { id: userId } },
      type: data.type,
      token: data.token,
      last4: data.last4,
      brand: data.brand,
    });
  }

  /** Remove a saved payment method */
  async removePaymentMethod(userId: string, methodId: string) {
    const method = await this.repo.findPaymentMethodById(methodId);
    if (!method) throw new NotFoundError('Payment method not found');
    if (method.userId !== userId) throw new ForbiddenError('Access denied');
    await this.repo.deletePaymentMethod(methodId);
  }

  /** Set a payment method as the default, clearing others */
  async setDefaultMethod(userId: string, methodId: string) {
    const method = await this.repo.findPaymentMethodById(methodId);
    if (!method) throw new NotFoundError('Payment method not found');
    if (method.userId !== userId) throw new ForbiddenError('Access denied');

    await this.repo.clearDefaultMethods(userId);
    return this.repo.updatePaymentMethod(methodId, { isDefault: true });
  }

  // ─── Wallet ────────────────────────────────────────────────────────────────

  /** Get wallet balance and recent transactions */
  async getWalletBalance(userId: string): Promise<WalletBalance> {
    const [balance, transactions] = await Promise.all([
      this.repo.getWalletBalance(userId),
      this.repo.getWalletTransactions(userId, 20),
    ]);

    return {
      balance,
      currency: 'INR',
      transactions: transactions.map((t) => ({
        id: t.id,
        amount: t.amount,
        type: t.type as 'CREDIT' | 'DEBIT',
        description: t.description,
        createdAt: t.createdAt,
        balanceAfter: t.balanceAfter,
      })),
    };
  }

  // ─── Shop Owner ─────────────────────────────────────────────────────────────

  /** Validate shop ownership */
  private async validateShopOwnership(shopId: string, ownerId: string) {
    const shop = await prisma.shop.findUnique({ where: { id: shopId } });
    if (!shop) throw new NotFoundError('Shop not found');
    if (shop.ownerId !== ownerId)
      throw new ForbiddenError('You do not own this shop');
    return shop;
  }

  /** List payments received by a shop */
  async getShopPayments(
    shopId: string,
    ownerId: string,
    filters: PaymentFilters,
    pagination: PaginationParams,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    return this.repo.listShopPayments(shopId, filters, pagination);
  }

  /** Aggregate payment statistics for a shop over a period */
  async getShopPaymentStats(
    shopId: string,
    ownerId: string,
    period: 'week' | 'month' | 'year' = 'month',
  ): Promise<PaymentStats> {
    await this.validateShopOwnership(shopId, ownerId);

    const now = new Date();
    const periodMap = { week: 7, month: 30, year: 365 };
    const days = periodMap[period];
    const from = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
    const prevFrom = new Date(from.getTime() - days * 24 * 60 * 60 * 1000);

    const [current, previous] = await Promise.all([
      this.repo.getShopPaymentStats(shopId, from, now),
      this.repo.getShopPaymentStats(shopId, prevFrom, from),
    ]);

    const totalRevenue = current.aggregate._sum.amount ?? 0;
    const prevRevenue = previous.aggregate._sum.amount ?? 0;

    const byMethod: Record<string, number> = {};
    current.byMethod.forEach((row) => {
      if (row.method) byMethod[row.method] = row._sum.amount ?? 0;
    });

    const byStatus: Record<string, number> = {};
    current.byStatus.forEach((row) => {
      byStatus[row.status] = row._count;
    });

    return {
      totalRevenue,
      totalTransactions: current.aggregate._count,
      averageTransactionValue: current.aggregate._avg.amount ?? 0,
      byMethod,
      byStatus,
      previousPeriodRevenue: prevRevenue,
      revenueGrowthPercent:
        prevRevenue === 0
          ? 100
          : parseFloat(
              (((totalRevenue - prevRevenue) / prevRevenue) * 100).toFixed(2),
            ),
    };
  }

  /** List settlements for a shop */
  async getSettlements(
    shopId: string,
    ownerId: string,
    filters: SettlementFilters,
    pagination: PaginationParams,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    return this.repo.listShopSettlements(shopId, filters, pagination);
  }

  /** Get settlement detail with constituent payments */
  async getSettlementDetail(
    shopId: string,
    ownerId: string,
    settlementId: string,
  ): Promise<SettlementDetail> {
    await this.validateShopOwnership(shopId, ownerId);
    const settlement = await this.repo.findSettlementById(settlementId);
    if (!settlement || settlement.shopId !== shopId)
      throw new NotFoundError('Settlement not found');

    return {
      id: settlement.id,
      shopId: settlement.shopId,
      amount: settlement.amount,
      platformFee: settlement.platformFee,
      netAmount: settlement.netAmount,
      status: settlement.status,
      bankAccountId: settlement.bankAccountId ?? undefined,
      processedAt: settlement.processedAt ?? undefined,
      createdAt: settlement.createdAt,
      payments: settlement.items.map((item) => ({
        id: item.payment.id,
        amount: item.payment.amount,
        createdAt: item.payment.createdAt,
      })),
    };
  }

  /** Add a bank account for a shop */
  async addBankAccount(shopId: string, ownerId: string, data: BankAccountInput) {
    await this.validateShopOwnership(shopId, ownerId);
    return this.repo.createBankAccount({
      shop: { connect: { id: shopId } },
      ...data,
    });
  }

  /** Update bank account details */
  async updateBankAccount(
    shopId: string,
    ownerId: string,
    accountId: string,
    data: Partial<BankAccountInput>,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    const account = await this.repo.findBankAccountById(accountId);
    if (!account || account.shopId !== shopId)
      throw new NotFoundError('Bank account not found');
    return this.repo.updateBankAccount(accountId, data);
  }

  /** Remove a bank account */
  async removeBankAccount(
    shopId: string,
    ownerId: string,
    accountId: string,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    const accounts = await this.repo.listShopBankAccounts(shopId);
    if (accounts.length <= 1)
      throw new BadRequestError('Cannot remove the last bank account');
    const account = accounts.find((a) => a.id === accountId);
    if (!account) throw new NotFoundError('Bank account not found');
    await this.repo.deleteBankAccount(accountId);
  }

  /** Set a bank account as default */
  async setDefaultBankAccount(
    shopId: string,
    ownerId: string,
    accountId: string,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    const account = await this.repo.findBankAccountById(accountId);
    if (!account || account.shopId !== shopId)
      throw new NotFoundError('Bank account not found');

    await this.repo.clearDefaultBankAccounts(shopId);
    return this.repo.updateBankAccount(accountId, { isDefault: true });
  }

  /** Request an early payout for unsettled payments */
  async requestEarlyPayout(shopId: string, ownerId: string) {
    await this.validateShopOwnership(shopId, ownerId);

    const unsettled = await this.repo.getUnsettledPayments(shopId);
    const total = unsettled.reduce((sum, p) => sum + p.amount, 0);

    if (total < MIN_PAYOUT_AMOUNT) {
      throw new BadRequestError(
        `Minimum payout amount is ₹${MIN_PAYOUT_AMOUNT}. Current unsettled: ₹${total.toFixed(2)}`,
      );
    }

    const accounts = await this.repo.listShopBankAccounts(shopId);
    const defaultAccount = accounts.find((a) => a.isDefault) ?? accounts[0];

    if (!defaultAccount)
      throw new BadRequestError('No bank account configured for this shop');

    const platformFee = this.calculateCommission(total);
    const netAmount = parseFloat((total - platformFee).toFixed(2));

    const settlement = await this.repo.createSettlement({
      shop: { connect: { id: shopId } },
      amount: total,
      platformFee,
      netAmount,
      bankAccount: { connect: { id: defaultAccount.id } },
    });

    // Link payments to settlement
    await Promise.all(
      unsettled.map((p) =>
        this.repo.createSettlementItem(settlement.id, p.id),
      ),
    );

    // TODO: Trigger settlement processing via Bull job queue

    return settlement;
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  /** List all payments (admin) */
  async listAllPayments(
    filters: PaymentFilters & { userId?: string; shopId?: string },
    pagination: PaginationParams,
  ) {
    return this.repo.listAllPayments(filters, pagination);
  }

  /** Platform-level payment statistics */
  async getPlatformPaymentStats(period = 30) {
    const now = new Date();
    const from = new Date(now.getTime() - period * 24 * 60 * 60 * 1000);
    return this.repo.getPlatformStats(from, now);
  }

  /** Get failed payments */
  async getFailedPayments(pagination: PaginationParams) {
    return this.repo.listAllPayments({ status: 'FAILED' }, pagination);
  }

  /** Retry a failed payment – re-creates a Razorpay order */
  async retryPayment(paymentId: string) {
    const payment = await this.repo.findPaymentById(paymentId);
    if (!payment) throw new NotFoundError('Payment not found');
    if (payment.status !== 'FAILED')
      throw new BadRequestError('Only failed payments can be retried');

    // TODO: Create new Razorpay order and update record
    const newOrderId = `order_retry_${crypto.randomBytes(8).toString('hex')}`;
    return this.repo.updatePayment(paymentId, {
      status: 'PENDING',
      razorpayOrderId: newOrderId,
    });
  }

  /** Admin: get pending refund requests */
  async getRefundQueue(pagination: PaginationParams) {
    return this.repo.listRefunds({ status: 'PENDING' }, pagination);
  }

  /** Admin: approve and process a refund via Razorpay */
  async approveRefund(refundId: string) {
    const refund = await this.repo.findRefundById(refundId);
    if (!refund) throw new NotFoundError('Refund not found');
    if (refund.status !== 'PENDING')
      throw new BadRequestError('Refund is not in PENDING state');

    // TODO: Process refund via Razorpay SDK
    // const razorpay = new Razorpay({ ... });
    // const rzpRefund = await razorpay.payments.refund(payment.razorpayPaymentId, { amount: refund.amount * 100 });

    const mockRefundId = `rfnd_${crypto.randomBytes(10).toString('hex')}`;

    const updated = await this.repo.updateRefund(refundId, {
      status: 'PROCESSED',
      razorpayRefundId: mockRefundId,
      resolvedAt: new Date(),
    });

    // Update payment status
    await this.repo.updatePayment(refund.paymentId, { status: 'REFUNDED' });

    // TODO: Notify customer about refund approval

    return updated;
  }

  /** Admin: reject a refund request */
  async rejectRefund(refundId: string, adminNote: string) {
    const refund = await this.repo.findRefundById(refundId);
    if (!refund) throw new NotFoundError('Refund not found');
    if (refund.status !== 'PENDING')
      throw new BadRequestError('Refund is not in PENDING state');

    const updated = await this.repo.updateRefund(refundId, {
      status: 'REJECTED',
      adminNote,
      resolvedAt: new Date(),
    });

    // TODO: Notify customer about refund rejection

    return updated;
  }

  /** Admin: list all settlements */
  async getAllSettlements(
    filters: SettlementFilters,
    pagination: PaginationParams,
  ) {
    return this.repo.listAllSettlements(filters, pagination);
  }

  /** Admin: process all pending settlements as a batch */
  async processSettlementsBatch() {
    const pending = await this.repo.listAllSettlements(
      { status: 'PENDING' },
      { page: 1, perPage: 100 },
    );

    // TODO: Enqueue settlement processing via Bull job queue
    // await settlementQueue.addBulk(pending.data.map(s => ({ data: s })));

    return {
      enqueued: pending.data.length,
      message: `${pending.data.length} settlements queued for processing`,
    };
  }

  /** Generate a reconciliation report for a date range */
  async getReconciliationReport(
    from: Date,
    to: Date,
  ): Promise<ReconciliationReport> {
    const data = await this.repo.getReconciliationData(from, to);

    const totalCollected = data.payments._sum.amount ?? 0;
    const totalRefunded = data.refunds._sum.amount ?? 0;
    const totalSettled = data.settlements._sum.netAmount ?? 0;
    const platformRevenue = parseFloat(
      (totalCollected * PLATFORM_COMMISSION_PERCENT).toFixed(2),
    );

    return {
      period: { from, to },
      totalCollected,
      totalRefunded,
      totalSettled,
      platformRevenue,
      pendingSettlements: parseFloat(
        (totalCollected - totalRefunded - totalSettled).toFixed(2),
      ),
      discrepancies: [], // TODO: detect discrepancies via gateway reconciliation API
    };
  }
}
