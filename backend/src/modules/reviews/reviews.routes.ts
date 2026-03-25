import { Router } from 'express';
import { authenticate, authorize } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import {
  submitReviewSchema,
  updateReviewSchema,
  respondSchema,
  reportReviewSchema,
  shopReviewsQuerySchema,
} from './reviews.validators';
import * as ctrl from './reviews.controller';

const router = Router();

// ─── Customer routes ──────────────────────────────────────────────────────────

/** Submit a review */
router.post(
  '/reviews',
  authenticate,
  authorize('CUSTOMER'),
  validate(submitReviewSchema),
  ctrl.submitReview,
);

/** List user's own reviews */
router.get('/reviews', authenticate, ctrl.getUserReviews);

/** Get a specific review */
router.get('/reviews/:id', ctrl.getReviewById);

/** Update a review (within edit window) */
router.put(
  '/reviews/:id',
  authenticate,
  authorize('CUSTOMER'),
  validate(updateReviewSchema),
  ctrl.updateReview,
);

/** Delete a review */
router.delete(
  '/reviews/:id',
  authenticate,
  authorize('CUSTOMER'),
  ctrl.deleteReview,
);

/** Mark review as helpful (toggle) */
router.post('/reviews/:id/helpful', authenticate, ctrl.markHelpful);

/** Report a review */
router.post(
  '/reviews/:id/report',
  authenticate,
  validate(reportReviewSchema),
  ctrl.reportReview,
);

// ─── Public routes ────────────────────────────────────────────────────────────

/** Get shop reviews (public, paginated, sortable) */
router.get(
  '/shops/:shopId/reviews',
  validate(shopReviewsQuerySchema, 'query'),
  ctrl.getShopReviews,
);

/** Get shop review summary */
router.get('/shops/:shopId/reviews/summary', ctrl.getShopReviewSummary);

// ─── Shop owner routes ────────────────────────────────────────────────────────

/** Respond to a review */
router.post(
  '/shops/:shopId/reviews/:reviewId/respond',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(respondSchema),
  ctrl.respondToReview,
);

/** Update review response */
router.put(
  '/shops/:shopId/reviews/:reviewId/respond',
  authenticate,
  authorize('SHOP_OWNER'),
  validate(respondSchema),
  ctrl.updateReviewResponse,
);

/** Delete review response */
router.delete(
  '/shops/:shopId/reviews/:reviewId/respond',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.deleteReviewResponse,
);

/** Shop review statistics */
router.get(
  '/shops/:shopId/reviews/stats',
  authenticate,
  authorize('SHOP_OWNER'),
  ctrl.getShopReviewStats,
);

// ─── Admin routes ─────────────────────────────────────────────────────────────

/** List all reviews (admin) */
router.get(
  '/admin/reviews',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminListReviews,
);

/** Reported reviews */
router.get(
  '/admin/reviews/reported',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetReportedReviews,
);

/** Hide a review */
router.put(
  '/admin/reviews/:id/hide',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminHideReview,
);

/** Restore a hidden review */
router.put(
  '/admin/reviews/:id/restore',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminRestoreReview,
);

/** Get report details */
router.get(
  '/admin/reviews/reports/:reportId',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminGetReportDetails,
);

/** Resolve a report */
router.put(
  '/admin/reviews/reports/:reportId/resolve',
  authenticate,
  authorize('ADMIN'),
  ctrl.adminResolveReport,
);

export default router;
