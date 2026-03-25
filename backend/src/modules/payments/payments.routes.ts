import { Router } from 'express';
import { authenticate, authorize } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import {
  initiatePaymentSchema,
  verifyPaymentSchema,
  requestRefundSchema,
  addPaymentMethodSchema,
  bankAccountSchema,
  paymentFiltersSchema,
  settlementFiltersSchema,
} from './payments.validators';
import * as ctrl from './payments.controller';

const router = Router();

// ─── Customer routes ──────────────────────────────────────────────────────────

/** Initiate payment for a booking */
router.post(
  '/payments/initiate',
  authenticate,
  authorize('CUSTOMER'),
  validate(initiatePaymentSchema),
  ctrl.initiatePayment,
);

/** Verify Razorpay callback signature */
router.post(
  '/payments/verify',
  authenticate,
  authorize('CUSTOMER'),
  validate(verifyPaymentSchema),
  ctrl.verifyPayment,
);

/** List authenticated user's payments */
router.get(
  '/payments',
  authenticate,
  validate(paymentFiltersSchema, 'query'),
  ctrl.getUserPayments,
);

/** Get specific payment detail */
router.get('/payments/:id', authenticate, ctrl.getPaymentById);

/** Download payment receipt */
router.get('/payments/:id/receipt', authenticate, ctrl.getPaymentReceipt);

/** Request refund */
router.post(
  '/payments/refund/:id',
  authenticate,
  authorize('CUSTOMER'),
  validate(requestRefundSchema),
  ctrl.requestRefund,
);

/** List saved payment methods */
router.get('/payments/methods', authenticate, ctrl.getPaymentMethods);

/** Add a payment method */
router.post(
  '/payments/methods',
  authenticate,
  validate(addPaymentMethodSchema),
  ctrl.addPaymentMethod,
);

/** Remove a saved payment method */
router.delete('/payments/methods/:id', authenticate, ctrl.removePaymentMethod);

/** Set default payment method */
router.put(
  '/payments/methods/:id/default',
  authenticate,
  ctrl.setDefaultMethod,
);

/** Wallet balance + history */
router.get('/payments/wallet', authenticate, ctrl.getWalletBalance);

// ─── Shop owner routes ────────────────────────────────────────────────────────

/** List shop payments */
router.get(
  '/shops/:shopId/payments',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(paymentFiltersSchema, 'query'),
  ctrl.getShopPayments,
);

/** Shop payment statistics */
router.get(
  '/shops/:shopId/payments/stats',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.getShopPaymentStats,
);

/** List shop settlements */
router.get(
  '/shops/:shopId/settlements',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(settlementFiltersSchema, 'query'),
  ctrl.getSettlements,
);

/** Get settlement detail */
router.get(
  '/shops/:shopId/settlements/:id',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.getSettlementDetail,
);

/** List bank accounts */
router.get(
  '/shops/:shopId/bank-accounts',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.getBankAccounts,
);

/** Add bank account */
router.post(
  '/shops/:shopId/bank-accounts',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(bankAccountSchema),
  ctrl.addBankAccount,
);

/** Update bank account */
router.put(
  '/shops/:shopId/bank-accounts/:id',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(bankAccountSchema.partial()),
  ctrl.updateBankAccount,
);

/** Remove bank account */
router.delete(
  '/shops/:shopId/bank-accounts/:id',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.removeBankAccount,
);

/** Set default bank account */
router.put(
  '/shops/:shopId/bank-accounts/:id/default',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.setDefaultBankAccount,
);

/** Request early payout */
router.post(
  '/shops/:shopId/settlements/request-payout',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.requestEarlyPayout,
);

// ─── Admin routes ─────────────────────────────────────────────────────────────

/** List all payments */
router.get(
  '/admin/payments',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminListPayments,
);

/** Platform payment stats */
router.get(
  '/admin/payments/stats',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetPaymentStats,
);

/** Failed payments queue */
router.get(
  '/admin/payments/failed',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetFailedPayments,
);

/** Retry failed payment */
router.post(
  '/admin/payments/:id/retry',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminRetryPayment,
);

/** Refund queue */
router.get(
  '/admin/refunds',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetRefundQueue,
);

/** Approve refund */
router.put(
  '/admin/refunds/:id/approve',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminApproveRefund,
);

/** Reject refund */
router.put(
  '/admin/refunds/:id/reject',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminRejectRefund,
);

/** All settlements */
router.get(
  '/admin/settlements',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetAllSettlements,
);

/** Process settlements batch */
router.post(
  '/admin/settlements/process',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminProcessSettlements,
);

/** Reconciliation report */
router.get(
  '/admin/payments/reconciliation',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetReconciliation,
);

export default router;
