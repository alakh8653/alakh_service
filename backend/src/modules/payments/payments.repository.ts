import prisma from '../../config/database';
import {
  Payment,
  PaymentMethod,
  Refund,
  Settlement,
  BankAccount,
  WalletTransaction,
  Prisma,
  PaymentStatus,
  RefundStatus,
  SettlementStatus,
  PaymentMethodType,
} from '@prisma/client';
import {
  PaymentFilters,
  SettlementFilters,
  PaginationParams,
  PaginatedResult,
} from './payments.types';

/**
 * Data-access layer for the payments module.
 * All database interactions are isolated here; no business logic.
 */
export class PaymentsRepository {
  // ─── Payments ──────────────────────────────────────────────────────────────

  /** Create a new payment record */
  async createPayment(data: Prisma.PaymentCreateInput): Promise<Payment> {
    return prisma.payment.create({ data });
  }

  /** Find a payment by its primary key */
  async findPaymentById(id: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { id } });
  }

  /** Find a payment by Razorpay order ID */
  async findPaymentByOrderId(razorpayOrderId: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { razorpayOrderId } });
  }

  /** Find payment by booking */
  async findPaymentByBookingId(bookingId: string): Promise<Payment | null> {
    return prisma.payment.findUnique({ where: { bookingId } });
  }

  /** Find a payment with full relations */
  async findPaymentWithDetails(id: string) {
    return prisma.payment.findUnique({
      where: { id },
      include: {
        booking: true,
        shop: { select: { id: true, name: true } },
        user: { select: { id: true, name: true, email: true } },
        refunds: true,
      },
    });
  }

  /** Update payment fields */
  async updatePayment(
    id: string,
    data: Prisma.PaymentUpdateInput,
  ): Promise<Payment> {
    return prisma.payment.update({ where: { id }, data });
  }

  /**
   * Paginated list of payments for a user with optional filters.
   */
  async listUserPayments(
    userId: string,
    filters: PaymentFilters,
    pagination: PaginationParams,
  ): Promise<PaginatedResult<Payment>> {
    const where: Prisma.PaymentWhereInput = {
      userId,
      ...(filters.status && { status: filters.status }),
      ...(filters.method && { method: filters.method }),
      ...(filters.startDate || filters.endDate
        ? {
            createdAt: {
              ...(filters.startDate && { gte: filters.startDate }),
              ...(filters.endDate && { lte: filters.endDate }),
            },
          }
        : {}),
      ...(filters.minAmount !== undefined || filters.maxAmount !== undefined
        ? {
            amount: {
              ...(filters.minAmount !== undefined && {
                gte: filters.minAmount,
              }),
              ...(filters.maxAmount !== undefined && {
                lte: filters.maxAmount,
              }),
            },
          }
        : {}),
    };

    const [data, total] = await prisma.$transaction([
      prisma.payment.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: { shop: { select: { id: true, name: true } } },
      }),
      prisma.payment.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  /**
   * Paginated list of payments received by a shop.
   */
  async listShopPayments(
    shopId: string,
    filters: PaymentFilters,
    pagination: PaginationParams,
  ): Promise<PaginatedResult<Payment>> {
    const where: Prisma.PaymentWhereInput = {
      shopId,
      ...(filters.status && { status: filters.status }),
      ...(filters.method && { method: filters.method }),
      ...(filters.startDate || filters.endDate
        ? {
            createdAt: {
              ...(filters.startDate && { gte: filters.startDate }),
              ...(filters.endDate && { lte: filters.endDate }),
            },
          }
        : {}),
    };

    const [data, total] = await prisma.$transaction([
      prisma.payment.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: { user: { select: { id: true, name: true } } },
      }),
      prisma.payment.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  /** Aggregate payment stats for a shop within a date range */
  async getShopPaymentStats(shopId: string, from: Date, to: Date) {
    const [aggregate, byMethod, byStatus] = await prisma.$transaction([
      prisma.payment.aggregate({
        where: { shopId, createdAt: { gte: from, lte: to }, status: 'COMPLETED' },
        _sum: { amount: true },
        _count: true,
        _avg: { amount: true },
      }),
      prisma.payment.groupBy({
        by: ['method'],
        where: { shopId, createdAt: { gte: from, lte: to }, status: 'COMPLETED' },
        _sum: { amount: true },
        _count: true,
      }),
      prisma.payment.groupBy({
        by: ['status'],
        where: { shopId, createdAt: { gte: from, lte: to } },
        _count: true,
      }),
    ]);

    return { aggregate, byMethod, byStatus };
  }

  /** List all payments (admin) */
  async listAllPayments(
    filters: PaymentFilters & { userId?: string; shopId?: string },
    pagination: PaginationParams,
  ) {
    const where: Prisma.PaymentWhereInput = {
      ...(filters.userId && { userId: filters.userId }),
      ...(filters.shopId && { shopId: filters.shopId }),
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate || filters.endDate
        ? {
            createdAt: {
              ...(filters.startDate && { gte: filters.startDate }),
              ...(filters.endDate && { lte: filters.endDate }),
            },
          }
        : {}),
    };

    const [data, total] = await prisma.$transaction([
      prisma.payment.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, name: true, email: true } },
          shop: { select: { id: true, name: true } },
        },
      }),
      prisma.payment.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  /** Platform-wide stats aggregation */
  async getPlatformStats(from: Date, to: Date) {
    return prisma.payment.aggregate({
      where: { createdAt: { gte: from, lte: to } },
      _sum: { amount: true, platformFee: true },
      _count: true,
      _avg: { amount: true },
    });
  }

  // ─── Payment Methods ────────────────────────────────────────────────────────

  async createPaymentMethod(
    data: Prisma.PaymentMethodCreateInput,
  ): Promise<PaymentMethod> {
    return prisma.paymentMethod.create({ data });
  }

  async findPaymentMethodById(id: string): Promise<PaymentMethod | null> {
    return prisma.paymentMethod.findUnique({ where: { id } });
  }

  async listUserPaymentMethods(userId: string): Promise<PaymentMethod[]> {
    return prisma.paymentMethod.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async updatePaymentMethod(
    id: string,
    data: Prisma.PaymentMethodUpdateInput,
  ): Promise<PaymentMethod> {
    return prisma.paymentMethod.update({ where: { id }, data });
  }

  async deletePaymentMethod(id: string): Promise<void> {
    await prisma.paymentMethod.delete({ where: { id } });
  }

  /** Unset the default flag for all user's payment methods */
  async clearDefaultMethods(userId: string): Promise<void> {
    await prisma.paymentMethod.updateMany({
      where: { userId },
      data: { isDefault: false },
    });
  }

  // ─── Refunds ────────────────────────────────────────────────────────────────

  async createRefund(data: Prisma.RefundCreateInput): Promise<Refund> {
    return prisma.refund.create({ data });
  }

  async findRefundById(id: string): Promise<Refund | null> {
    return prisma.refund.findUnique({ where: { id } });
  }

  async findRefundsByPayment(paymentId: string): Promise<Refund[]> {
    return prisma.refund.findMany({ where: { paymentId } });
  }

  async updateRefund(
    id: string,
    data: Prisma.RefundUpdateInput,
  ): Promise<Refund> {
    return prisma.refund.update({ where: { id }, data });
  }

  async listRefunds(
    filters: { status?: RefundStatus },
    pagination: PaginationParams,
  ) {
    const where: Prisma.RefundWhereInput = {
      ...(filters.status && { status: filters.status }),
    };

    const [data, total] = await prisma.$transaction([
      prisma.refund.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: {
          payment: true,
          user: { select: { id: true, name: true, email: true } },
        },
      }),
      prisma.refund.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  // ─── Settlements ────────────────────────────────────────────────────────────

  async createSettlement(
    data: Prisma.SettlementCreateInput,
  ): Promise<Settlement> {
    return prisma.settlement.create({ data });
  }

  async findSettlementById(id: string) {
    return prisma.settlement.findUnique({
      where: { id },
      include: { items: { include: { payment: true } }, bankAccount: true },
    });
  }

  async listShopSettlements(
    shopId: string,
    filters: SettlementFilters,
    pagination: PaginationParams,
  ) {
    const where: Prisma.SettlementWhereInput = {
      shopId,
      ...(filters.status && { status: filters.status }),
      ...(filters.startDate || filters.endDate
        ? {
            createdAt: {
              ...(filters.startDate && { gte: filters.startDate }),
              ...(filters.endDate && { lte: filters.endDate }),
            },
          }
        : {}),
    };

    const [data, total] = await prisma.$transaction([
      prisma.settlement.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.settlement.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  async updateSettlement(
    id: string,
    data: Prisma.SettlementUpdateInput,
  ): Promise<Settlement> {
    return prisma.settlement.update({ where: { id }, data });
  }

  /** Fetch COMPLETED payments for a shop that are not yet part of a settlement */
  async getUnsettledPayments(shopId: string): Promise<Payment[]> {
    return prisma.payment.findMany({
      where: {
        shopId,
        status: 'COMPLETED',
        settlementItems: { none: {} },
      },
    });
  }

  async listAllSettlements(
    filters: SettlementFilters,
    pagination: PaginationParams,
  ) {
    const where: Prisma.SettlementWhereInput = {
      ...(filters.status && { status: filters.status }),
    };

    const [data, total] = await prisma.$transaction([
      prisma.settlement.findMany({
        where,
        skip: (pagination.page - 1) * pagination.perPage,
        take: pagination.perPage,
        orderBy: { createdAt: 'desc' },
        include: { shop: { select: { id: true, name: true } } },
      }),
      prisma.settlement.count({ where }),
    ]);

    return {
      data,
      total,
      page: pagination.page,
      perPage: pagination.perPage,
      totalPages: Math.ceil(total / pagination.perPage),
    };
  }

  async createSettlementItem(
    settlementId: string,
    paymentId: string,
  ) {
    return prisma.settlementItem.create({
      data: { settlementId, paymentId },
    });
  }

  // ─── Bank Accounts ──────────────────────────────────────────────────────────

  async createBankAccount(
    data: Prisma.BankAccountCreateInput,
  ): Promise<BankAccount> {
    return prisma.bankAccount.create({ data });
  }

  async findBankAccountById(id: string): Promise<BankAccount | null> {
    return prisma.bankAccount.findUnique({ where: { id } });
  }

  async listShopBankAccounts(shopId: string): Promise<BankAccount[]> {
    return prisma.bankAccount.findMany({
      where: { shopId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async updateBankAccount(
    id: string,
    data: Prisma.BankAccountUpdateInput,
  ): Promise<BankAccount> {
    return prisma.bankAccount.update({ where: { id }, data });
  }

  async deleteBankAccount(id: string): Promise<void> {
    await prisma.bankAccount.delete({ where: { id } });
  }

  async clearDefaultBankAccounts(shopId: string): Promise<void> {
    await prisma.bankAccount.updateMany({
      where: { shopId },
      data: { isDefault: false },
    });
  }

  // ─── Wallet ─────────────────────────────────────────────────────────────────

  async getWalletTransactions(
    userId: string,
    limit = 20,
  ): Promise<WalletTransaction[]> {
    return prisma.walletTransaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async createWalletTransaction(
    data: Prisma.WalletTransactionCreateInput,
  ): Promise<WalletTransaction> {
    return prisma.walletTransaction.create({ data });
  }

  /** Sum of CREDIT minus DEBIT for a user */
  async getWalletBalance(userId: string): Promise<number> {
    const [credits, debits] = await prisma.$transaction([
      prisma.walletTransaction.aggregate({
        where: { userId, type: 'CREDIT' },
        _sum: { amount: true },
      }),
      prisma.walletTransaction.aggregate({
        where: { userId, type: 'DEBIT' },
        _sum: { amount: true },
      }),
    ]);

    return (credits._sum.amount ?? 0) - (debits._sum.amount ?? 0);
  }

  // ─── Reconciliation ─────────────────────────────────────────────────────────

  async getReconciliationData(from: Date, to: Date) {
    const [payments, refunds, settlements] = await prisma.$transaction([
      prisma.payment.aggregate({
        where: { createdAt: { gte: from, lte: to }, status: 'COMPLETED' },
        _sum: { amount: true },
      }),
      prisma.refund.aggregate({
        where: { createdAt: { gte: from, lte: to }, status: 'PROCESSED' },
        _sum: { amount: true },
      }),
      prisma.settlement.aggregate({
        where: { createdAt: { gte: from, lte: to }, status: 'COMPLETED' },
        _sum: { netAmount: true },
      }),
    ]);

    return { payments, refunds, settlements };
  }
}
