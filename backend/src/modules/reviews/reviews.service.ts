import { ReviewsRepository } from './reviews.repository';
import {
  SubmitReviewInput,
  UpdateReviewInput,
  ShopReviewFilters,
  ReviewSummary,
  ReviewStats,
  ReviewWithDetails,
} from './reviews.types';
import {
  BadRequestError,
  ConflictError,
  ForbiddenError,
  NotFoundError,
} from '../../shared/errors/AppError';
import prisma from '../../config/database';

const REVIEW_EDIT_WINDOW_DAYS = parseInt(
  process.env.REVIEW_EDIT_WINDOW_DAYS ?? '7',
  10,
);

/**
 * Business logic for the reviews module.
 */
export class ReviewsService {
  private readonly repo: ReviewsRepository;

  constructor() {
    this.repo = new ReviewsRepository();
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  /**
   * Recalculate a shop's average rating and total review count.
   * Called after any review mutation.
   */
  async recalculateShopRating(shopId: string): Promise<void> {
    await this.repo.recalculateShopRating(shopId);
  }

  // ─── Customer ──────────────────────────────────────────────────────────────

  /**
   * Submit a review for a completed booking.
   * Validates: booking exists, completed, belongs to user, not already reviewed.
   */
  async submitReview(userId: string, data: SubmitReviewInput) {
    const booking = await prisma.serviceBooking.findUnique({
      where: { id: data.bookingId },
    });

    if (!booking) throw new NotFoundError('Booking not found');
    if (booking.customerId !== userId)
      throw new ForbiddenError('Booking does not belong to this user');
    if (booking.status !== 'COMPLETED')
      throw new BadRequestError('Reviews can only be submitted for completed bookings');

    const existing = await this.repo.findReviewByBookingId(data.bookingId);
    if (existing) throw new ConflictError('You have already reviewed this booking');

    // TODO: Upload photos to S3 if provided as base64 / multipart
    // const photoUrls = await Promise.all(data.photos?.map(uploadToS3) ?? []);

    const review = await this.repo.createReview({
      booking: { connect: { id: data.bookingId } },
      user: { connect: { id: userId } },
      shop: { connect: { id: booking.shopId } },
      rating: data.rating,
      title: data.title,
      text: data.text,
      photos: data.photos ?? [],
      isVerified: true, // Booking-verified review
    });

    await this.recalculateShopRating(booking.shopId);

    // TODO: Send notification to shop owner about new review

    return review;
  }

  /** List a user's own reviews with pagination */
  async getUserReviews(userId: string, page: number, perPage: number) {
    return this.repo.listUserReviews(userId, page, perPage);
  }

  /** Get a single review by ID */
  async getReviewById(reviewId: string): Promise<ReviewWithDetails> {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');
    return review as ReviewWithDetails;
  }

  /**
   * Update a review within the edit window.
   * Only the review author can update.
   */
  async updateReview(
    userId: string,
    reviewId: string,
    data: UpdateReviewInput,
  ) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');
    if (review.userId !== userId)
      throw new ForbiddenError('You can only edit your own reviews');

    const windowMs = REVIEW_EDIT_WINDOW_DAYS * 24 * 60 * 60 * 1000;
    const elapsed = Date.now() - review.createdAt.getTime();
    if (elapsed > windowMs) {
      throw new BadRequestError(
        `Reviews can only be edited within ${REVIEW_EDIT_WINDOW_DAYS} days of submission`,
      );
    }

    const updated = await this.repo.updateReview(reviewId, {
      ...(data.rating !== undefined && { rating: data.rating }),
      ...(data.title !== undefined && { title: data.title }),
      ...(data.text !== undefined && { text: data.text }),
      ...(data.photos !== undefined && { photos: data.photos }),
    });

    await this.recalculateShopRating(review.shopId);

    return updated;
  }

  /**
   * Soft-delete a review (author only).
   * Recalculates shop rating after deletion.
   */
  async deleteReview(userId: string, reviewId: string): Promise<void> {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');
    if (review.userId !== userId)
      throw new ForbiddenError('You can only delete your own reviews');

    await this.repo.softDeleteReview(reviewId);
    await this.recalculateShopRating(review.shopId);
  }

  /**
   * Toggle "helpful" on a review.
   * Prevents duplicate helpful marks.
   */
  async markHelpful(userId: string, reviewId: string) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');

    const existing = await this.repo.findHelpfulRecord(reviewId, userId);

    if (existing) {
      // Un-mark as helpful
      await this.repo.deleteHelpful(reviewId, userId);
      await this.repo.incrementHelpfulCount(reviewId, -1);
      return { helpful: false };
    } else {
      await this.repo.createHelpful(reviewId, userId);
      await this.repo.incrementHelpfulCount(reviewId, 1);
      return { helpful: true };
    }
  }

  /**
   * Report a review for moderation.
   * Auto-flags the review if the report threshold is exceeded.
   */
  async reportReview(
    userId: string,
    reviewId: string,
    reason: string,
    details?: string,
  ) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');

    const report = await this.repo.createReport({
      review: { connect: { id: reviewId } },
      reporter: { connect: { id: userId } },
      reason: reason as never,
      details,
    });

    const flagged = await this.repo.autoFlagIfThreshold(reviewId);

    // TODO: Notify admin if flagged
    if (flagged) {
      // emit event to admin notification channel
    }

    return report;
  }

  // ─── Public ────────────────────────────────────────────────────────────────

  /** Get paginated public reviews for a shop */
  async getShopReviews(
    shopId: string,
    filters: ShopReviewFilters,
    page: number,
    perPage: number,
  ) {
    return this.repo.listShopReviews(shopId, filters, page, perPage);
  }

  /** Get review summary (avg, distribution, etc.) for a shop */
  async getShopReviewSummary(shopId: string): Promise<ReviewSummary> {
    const shop = await prisma.shop.findUnique({ where: { id: shopId } });
    if (!shop) throw new NotFoundError('Shop not found');

    const { aggregate, distribution, verifiedCount, recentAvg } =
      await this.repo.getShopReviewSummary(shopId);

    const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 } as Record<
      number,
      number
    >;
    distribution.forEach((row) => {
      ratingDistribution[row.rating] = row._count;
    });

    return {
      shopId,
      averageRating: parseFloat((aggregate._avg.rating ?? 0).toFixed(2)),
      totalReviews: aggregate._count,
      verifiedCount,
      ratingDistribution: ratingDistribution as ReviewSummary['ratingDistribution'],
      recentTrend: parseFloat((recentAvg._avg.rating ?? 0).toFixed(2)),
    };
  }

  // ─── Shop owner ─────────────────────────────────────────────────────────────

  /** Validate shop ownership */
  private async validateShopOwnership(shopId: string, ownerId: string) {
    const shop = await prisma.shop.findUnique({ where: { id: shopId } });
    if (!shop) throw new NotFoundError('Shop not found');
    if (shop.ownerId !== ownerId)
      throw new ForbiddenError('You do not own this shop');
    return shop;
  }

  /** Add a shop owner response to a review */
  async respondToReview(
    shopId: string,
    ownerId: string,
    reviewId: string,
    text: string,
  ) {
    await this.validateShopOwnership(shopId, ownerId);

    const review = await this.repo.findReviewById(reviewId);
    if (!review || review.shopId !== shopId)
      throw new NotFoundError('Review not found for this shop');

    const existing = await this.repo.findReviewResponse(reviewId);
    if (existing)
      throw new ConflictError('A response already exists. Use PUT to update it.');

    return this.repo.createReviewResponse(reviewId, shopId, text);
  }

  /** Update a shop owner's response */
  async updateResponse(
    shopId: string,
    ownerId: string,
    reviewId: string,
    text: string,
  ) {
    await this.validateShopOwnership(shopId, ownerId);
    const existing = await this.repo.findReviewResponse(reviewId);
    if (!existing) throw new NotFoundError('No response found for this review');
    return this.repo.updateReviewResponse(reviewId, text);
  }

  /** Delete a shop owner's response */
  async deleteResponse(
    shopId: string,
    ownerId: string,
    reviewId: string,
  ): Promise<void> {
    await this.validateShopOwnership(shopId, ownerId);
    const existing = await this.repo.findReviewResponse(reviewId);
    if (!existing) throw new NotFoundError('No response found for this review');
    await this.repo.deleteReviewResponse(reviewId);
  }

  /** Get review statistics for a shop owner */
  async getShopReviewStats(
    shopId: string,
    ownerId: string,
    period: 'week' | 'month' | 'year' = 'month',
  ): Promise<ReviewStats> {
    await this.validateShopOwnership(shopId, ownerId);

    const now = new Date();
    const periodMap = { week: 7, month: 30, year: 365 };
    const days = periodMap[period];
    const from = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);

    const [reviews, withResponse] = await Promise.all([
      prisma.review.findMany({
        where: { shopId, createdAt: { gte: from }, deletedAt: null },
        select: { rating: true, createdAt: true, response: true },
      }),
      prisma.reviewResponse.count({
        where: {
          shopId,
          review: { createdAt: { gte: from }, deletedAt: null },
        },
      }),
    ]);

    const avgRating =
      reviews.length > 0
        ? reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length
        : 0;

    const responseRate =
      reviews.length > 0
        ? parseFloat(((withResponse / reviews.length) * 100).toFixed(2))
        : 0;

    // Daily trend (group by date)
    const trendMap = new Map<string, number[]>();
    reviews.forEach((r) => {
      const day = r.createdAt.toISOString().slice(0, 10);
      if (!trendMap.has(day)) trendMap.set(day, []);
      trendMap.get(day)!.push(r.rating);
    });

    const ratingTrend = Array.from(trendMap.entries()).map(
      ([date, ratings]) => ({
        date,
        avgRating: parseFloat(
          (ratings.reduce((s, r) => s + r, 0) / ratings.length).toFixed(2),
        ),
      }),
    );

    return {
      shopId,
      period,
      averageRating: parseFloat(avgRating.toFixed(2)),
      responseRate,
      totalReviews: reviews.length,
      ratingTrend,
    };
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  /** List all reviews (admin) */
  async listAllReviews(
    filters: {
      shopId?: string;
      userId?: string;
      rating?: number;
      isHidden?: boolean;
    },
    page: number,
    perPage: number,
  ) {
    return this.repo.listAllReviews(filters, page, perPage);
  }

  /** List reported reviews (admin) */
  async getReportedReviews(page: number, perPage: number) {
    return this.repo.listReports({ isResolved: false }, page, perPage);
  }

  /** Hide a review (admin moderation) */
  async hideReview(reviewId: string) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');

    const updated = await this.repo.updateReview(reviewId, { isHidden: true });
    await this.recalculateShopRating(review.shopId);
    return updated;
  }

  /** Restore a hidden review */
  async restoreReview(reviewId: string) {
    const review = await this.repo.findReviewById(reviewId);
    if (!review) throw new NotFoundError('Review not found');

    const updated = await this.repo.updateReview(reviewId, { isHidden: false });
    await this.recalculateShopRating(review.shopId);
    return updated;
  }

  /** Get report details */
  async getReportDetails(reportId: string) {
    const report = await this.repo.findReportById(reportId);
    if (!report) throw new NotFoundError('Report not found');
    return report;
  }

  /** Resolve a review report */
  async resolveReport(reportId: string, adminNote?: string) {
    const report = await this.repo.findReportById(reportId);
    if (!report) throw new NotFoundError('Report not found');

    return this.repo.updateReport(reportId, {
      isResolved: true,
      resolvedAt: new Date(),
      adminNote: adminNote ?? null,
    });
  }
}
