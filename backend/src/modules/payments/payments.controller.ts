import { Request, Response, NextFunction } from 'express';
import { PaymentsService } from './payments.service';
import { HttpStatus } from '../../shared/errors/AppError';

const service = new PaymentsService();

// ─── Customer handlers ────────────────────────────────────────────────────────

/**
 * POST /api/v1/payments/initiate
 * Initiate a payment for a booking.
 */
export async function initiatePayment(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user!.userId;
    const result = await service.initiatePayment(userId, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/payments/verify
 * Verify a Razorpay payment after gateway callback.
 */
export async function verifyPayment(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user!.userId;
    const result = await service.verifyPayment(userId, req.body);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/payments
 * List the authenticated user's payments.
 */
export async function getUserPayments(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const userId = req.user!.userId;
    const { page, perPage, status, method, startDate, endDate, minAmount, maxAmount } =
      req.query as Record<string, string>;

    const result = await service.getUserPayments(
      userId,
      {
        status: status as never,
        method: method as never,
        startDate: startDate ? new Date(startDate) : undefined,
        endDate: endDate ? new Date(endDate) : undefined,
        minAmount: minAmount ? parseFloat(minAmount) : undefined,
        maxAmount: maxAmount ? parseFloat(maxAmount) : undefined,
      },
      { page: parseInt(page ?? '1'), perPage: parseInt(perPage ?? '20') },
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/payments/:id
 * Get details for a single payment.
 */
export async function getPaymentById(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getPaymentById(
      req.params.id,
      req.user!.userId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/payments/:id/receipt
 * Get payment receipt data.
 */
export async function getPaymentReceipt(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getPaymentReceipt(
      req.params.id,
      req.user!.userId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/payments/refund/:id
 * Request a refund for a completed payment.
 */
export async function requestRefund(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.requestRefund(
      req.params.id,
      req.user!.userId,
      req.body.reason,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/payments/methods
 * List saved payment methods.
 */
export async function getPaymentMethods(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getPaymentMethods(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/payments/methods
 * Add / save a payment method.
 */
export async function addPaymentMethod(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.addPaymentMethod(req.user!.userId, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * DELETE /api/v1/payments/methods/:id
 * Remove a saved payment method.
 */
export async function removePaymentMethod(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.removePaymentMethod(req.user!.userId, req.params.id);
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/v1/payments/methods/:id/default
 * Set a payment method as default.
 */
export async function setDefaultMethod(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.setDefaultMethod(
      req.user!.userId,
      req.params.id,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/payments/wallet
 * Get wallet balance and transaction history.
 */
export async function getWalletBalance(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getWalletBalance(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── Shop owner handlers ──────────────────────────────────────────────────────

/**
 * GET /api/v1/shops/:shopId/payments
 * List payments received by a shop.
 */
export async function getShopPayments(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage, status } = req.query as Record<string, string>;
    const result = await service.getShopPayments(
      req.params.shopId,
      req.user!.userId,
      { status: status as never },
      { page: parseInt(page ?? '1'), perPage: parseInt(perPage ?? '20') },
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/shops/:shopId/payments/stats
 * Payment statistics for a shop.
 */
export async function getShopPaymentStats(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const period = (req.query.period as 'week' | 'month' | 'year') ?? 'month';
    const result = await service.getShopPaymentStats(
      req.params.shopId,
      req.user!.userId,
      period,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/shops/:shopId/settlements
 * List settlements for a shop.
 */
export async function getSettlements(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage, status } = req.query as Record<string, string>;
    const result = await service.getSettlements(
      req.params.shopId,
      req.user!.userId,
      { status: status as never },
      { page: parseInt(page ?? '1'), perPage: parseInt(perPage ?? '20') },
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/shops/:shopId/settlements/:id
 * Get settlement detail.
 */
export async function getSettlementDetail(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getSettlementDetail(
      req.params.shopId,
      req.user!.userId,
      req.params.id,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/shops/:shopId/bank-accounts
 * List bank accounts for a shop.
 */
export async function getBankAccounts(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { shopId } = req.params;
    const shop = await import('../../config/database').then((m) =>
      m.default.shop.findUnique({ where: { id: shopId } }),
    );
    if (!shop || shop.ownerId !== req.user!.userId) {
      res
        .status(HttpStatus.FORBIDDEN)
        .json({ success: false, message: 'Access denied' });
      return;
    }
    const accounts = await import('./payments.repository').then((m) =>
      new m.PaymentsRepository().listShopBankAccounts(shopId),
    );
    res.status(HttpStatus.OK).json({ success: true, data: accounts });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/shops/:shopId/bank-accounts
 * Add a bank account.
 */
export async function addBankAccount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.addBankAccount(
      req.params.shopId,
      req.user!.userId,
      req.body,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/v1/shops/:shopId/bank-accounts/:id
 * Update bank account details.
 */
export async function updateBankAccount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.updateBankAccount(
      req.params.shopId,
      req.user!.userId,
      req.params.id,
      req.body,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * DELETE /api/v1/shops/:shopId/bank-accounts/:id
 * Remove a bank account.
 */
export async function removeBankAccount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.removeBankAccount(
      req.params.shopId,
      req.user!.userId,
      req.params.id,
    );
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/v1/shops/:shopId/bank-accounts/:id/default
 * Set default bank account.
 */
export async function setDefaultBankAccount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.setDefaultBankAccount(
      req.params.shopId,
      req.user!.userId,
      req.params.id,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/shops/:shopId/settlements/request-payout
 * Request early payout.
 */
export async function requestEarlyPayout(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.requestEarlyPayout(
      req.params.shopId,
      req.user!.userId,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── Admin handlers ───────────────────────────────────────────────────────────

/**
 * GET /api/v1/admin/payments
 * List all payments with admin filters.
 */
export async function adminListPayments(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage, status, userId, shopId } = req.query as Record<
      string,
      string
    >;
    const result = await service.listAllPayments(
      { status: status as never, userId, shopId },
      { page: parseInt(page ?? '1'), perPage: parseInt(perPage ?? '20') },
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/admin/payments/stats
 * Platform payment statistics.
 */
export async function adminGetPaymentStats(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const period = parseInt((req.query.period as string) ?? '30', 10);
    const result = await service.getPlatformPaymentStats(period);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/admin/payments/failed
 * Failed payments queue.
 */
export async function adminGetFailedPayments(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage } = req.query as Record<string, string>;
    const result = await service.getFailedPayments({
      page: parseInt(page ?? '1'),
      perPage: parseInt(perPage ?? '20'),
    });
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/admin/payments/:id/retry
 * Retry a failed payment.
 */
export async function adminRetryPayment(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.retryPayment(req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/admin/refunds
 * Refund requests queue.
 */
export async function adminGetRefundQueue(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage } = req.query as Record<string, string>;
    const result = await service.getRefundQueue({
      page: parseInt(page ?? '1'),
      perPage: parseInt(perPage ?? '20'),
    });
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/v1/admin/refunds/:id/approve
 * Approve a refund.
 */
export async function adminApproveRefund(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.approveRefund(req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /api/v1/admin/refunds/:id/reject
 * Reject a refund.
 */
export async function adminRejectRefund(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.rejectRefund(
      req.params.id,
      req.body.adminNote ?? '',
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/admin/settlements
 * All settlements (admin).
 */
export async function adminGetAllSettlements(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage, status } = req.query as Record<string, string>;
    const result = await service.getAllSettlements(
      { status: status as never },
      { page: parseInt(page ?? '1'), perPage: parseInt(perPage ?? '20') },
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /api/v1/admin/settlements/process
 * Process pending settlements batch.
 */
export async function adminProcessSettlements(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.processSettlementsBatch();
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/v1/admin/payments/reconciliation
 * Reconciliation report.
 */
export async function adminGetReconciliation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const now = new Date();
    const from = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    const to = now;
    const result = await service.getReconciliationReport(
      req.query.from ? new Date(req.query.from as string) : from,
      req.query.to ? new Date(req.query.to as string) : to,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}
