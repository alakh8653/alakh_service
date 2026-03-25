import prisma from '../../config/database';
import { Prisma, Review, ReviewReport, ReviewResponse } from '@prisma/client';
import { ShopReviewFilters } from './reviews.types';

const REVIEW_REPORT_THRESHOLD = parseInt(
  process.env.REVIEW_REPORT_THRESHOLD ?? '5',
  10,
);

/**
 * Data-access layer for the reviews module.
 */
export class ReviewsRepository {
  // ─── Reviews ────────────────────────────────────────────────────────────────

  async createReview(data: Prisma.ReviewCreateInput): Promise<Review> {
    return prisma.review.create({ data });
  }

  async findReviewById(id: string) {
    return prisma.review.findFirst({
      where: { id, deletedAt: null },
      include: {
        user: { select: { id: true, name: true } },
        shop: { select: { id: true, name: true } },
        response: true,
      },
    });
  }

  async findReviewByBookingId(bookingId: string): Promise<Review | null> {
    return prisma.review.findUnique({ where: { bookingId } });
  }

  async updateReview(
    id: string,
    data: Prisma.ReviewUpdateInput,
  ): Promise<Review> {
    return prisma.review.update({ where: { id }, data });
  }

  /** Soft delete – set deletedAt timestamp */
  async softDeleteReview(id: string): Promise<Review> {
    return prisma.review.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  async listUserReviews(
    userId: string,
    page: number,
    perPage: number,
  ) {
    const where: Prisma.ReviewWhereInput = {
      userId,
      deletedAt: null,
    };

    const [data, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { createdAt: 'desc' },
        include: { shop: { select: { id: true, name: true } }, response: true },
      }),
      prisma.review.count({ where }),
    ]);

    return { data, total, page, perPage, totalPages: Math.ceil(total / perPage) };
  }

  async listShopReviews(
    shopId: string,
    filters: ShopReviewFilters,
    page: number,
    perPage: number,
  ) {
    const where: Prisma.ReviewWhereInput = {
      shopId,
      isHidden: false,
      deletedAt: null,
      ...(filters.rating && { rating: filters.rating }),
    };

    const orderByField =
      filters.sortBy === 'rating'
        ? 'rating'
        : filters.sortBy === 'helpful'
        ? 'helpfulCount'
        : 'createdAt';

    const [data, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { [orderByField]: filters.sortOrder ?? 'desc' },
        include: {
          user: { select: { id: true, name: true } },
          response: true,
        },
      }),
      prisma.review.count({ where }),
    ]);

    return { data, total, page, perPage, totalPages: Math.ceil(total / perPage) };
  }

  /** Aggregate shop review summary */
  async getShopReviewSummary(shopId: string) {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [aggregate, distribution, verifiedCount, recentAvg] =
      await prisma.$transaction([
        prisma.review.aggregate({
          where: { shopId, deletedAt: null, isHidden: false },
          _avg: { rating: true },
          _count: true,
        }),
        prisma.review.groupBy({
          by: ['rating'],
          where: { shopId, deletedAt: null, isHidden: false },
          _count: true,
        }),
        prisma.review.count({
          where: { shopId, isVerified: true, deletedAt: null, isHidden: false },
        }),
        prisma.review.aggregate({
          where: {
            shopId,
            deletedAt: null,
            isHidden: false,
            createdAt: { gte: thirtyDaysAgo },
          },
          _avg: { rating: true },
        }),
      ]);

    return { aggregate, distribution, verifiedCount, recentAvg };
  }

  /**
   * Recalculate and update the shop's avgRating and totalReviews.
   * Called after any review create/update/delete.
   */
  async recalculateShopRating(shopId: string): Promise<void> {
    const agg = await prisma.review.aggregate({
      where: { shopId, isHidden: false, deletedAt: null },
      _avg: { rating: true },
      _count: true,
    });

    await prisma.shop.update({
      where: { id: shopId },
      data: {
        avgRating: parseFloat((agg._avg.rating ?? 0).toFixed(2)),
        totalReviews: agg._count,
      },
    });
  }

  // ─── Review Response ────────────────────────────────────────────────────────

  async findReviewResponse(reviewId: string): Promise<ReviewResponse | null> {
    return prisma.reviewResponse.findUnique({ where: { reviewId } });
  }

  async createReviewResponse(
    reviewId: string,
    shopId: string,
    text: string,
  ): Promise<ReviewResponse> {
    return prisma.reviewResponse.create({
      data: { reviewId, shopId, text },
    });
  }

  async updateReviewResponse(
    reviewId: string,
    text: string,
  ): Promise<ReviewResponse> {
    return prisma.reviewResponse.update({
      where: { reviewId },
      data: { text },
    });
  }

  async deleteReviewResponse(reviewId: string): Promise<void> {
    await prisma.reviewResponse.delete({ where: { reviewId } });
  }

  // ─── Helpful toggle ─────────────────────────────────────────────────────────

  async findHelpfulRecord(reviewId: string, userId: string) {
    return prisma.reviewHelpful.findUnique({
      where: { reviewId_userId: { reviewId, userId } },
    });
  }

  async createHelpful(reviewId: string, userId: string) {
    return prisma.reviewHelpful.create({ data: { reviewId, userId } });
  }

  async deleteHelpful(reviewId: string, userId: string) {
    return prisma.reviewHelpful.delete({
      where: { reviewId_userId: { reviewId, userId } },
    });
  }

  async incrementHelpfulCount(reviewId: string, delta: 1 | -1) {
    return prisma.review.update({
      where: { id: reviewId },
      data: { helpfulCount: { increment: delta } },
    });
  }

  // ─── Reports ────────────────────────────────────────────────────────────────

  async createReport(
    data: Prisma.ReviewReportCreateInput,
  ): Promise<ReviewReport> {
    return prisma.reviewReport.create({ data });
  }

  async countReportsForReview(reviewId: string): Promise<number> {
    return prisma.reviewReport.count({ where: { reviewId } });
  }

  async listReports(
    filters: { isResolved?: boolean },
    page: number,
    perPage: number,
  ) {
    const where: Prisma.ReviewReportWhereInput = {
      ...(filters.isResolved !== undefined && {
        isResolved: filters.isResolved,
      }),
    };

    const [data, total] = await prisma.$transaction([
      prisma.reviewReport.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { createdAt: 'desc' },
        include: { review: true, reporter: { select: { id: true, name: true } } },
      }),
      prisma.reviewReport.count({ where }),
    ]);

    return { data, total, page, perPage, totalPages: Math.ceil(total / perPage) };
  }

  async findReportById(id: string): Promise<ReviewReport | null> {
    return prisma.reviewReport.findUnique({ where: { id } });
  }

  async updateReport(
    id: string,
    data: Prisma.ReviewReportUpdateInput,
  ): Promise<ReviewReport> {
    return prisma.reviewReport.update({ where: { id }, data });
  }

  /** Auto-flag a review if report count exceeds the threshold */
  async autoFlagIfThreshold(reviewId: string): Promise<boolean> {
    const count = await this.countReportsForReview(reviewId);
    if (count >= REVIEW_REPORT_THRESHOLD) {
      await prisma.review.update({
        where: { id: reviewId },
        data: { isHidden: true },
      });
      return true;
    }
    return false;
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

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
    const where: Prisma.ReviewWhereInput = {
      deletedAt: null,
      ...(filters.shopId && { shopId: filters.shopId }),
      ...(filters.userId && { userId: filters.userId }),
      ...(filters.rating !== undefined && { rating: filters.rating }),
      ...(filters.isHidden !== undefined && { isHidden: filters.isHidden }),
    };

    const [data, total] = await prisma.$transaction([
      prisma.review.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { id: true, name: true, email: true } },
          shop: { select: { id: true, name: true } },
        },
      }),
      prisma.review.count({ where }),
    ]);

    return { data, total, page, perPage, totalPages: Math.ceil(total / perPage) };
  }
}
