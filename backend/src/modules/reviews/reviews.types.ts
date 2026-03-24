import { ReviewReportReason } from '@prisma/client';

// ─── Input types ──────────────────────────────────────────────────────────────

/** Input for submitting a new review */
export interface SubmitReviewInput {
  bookingId: string;
  rating: number;
  title?: string;
  text: string;
  photos?: string[];
}

/** Input for updating an existing review */
export interface UpdateReviewInput {
  rating?: number;
  title?: string;
  text?: string;
  photos?: string[];
}

/** Filters for fetching shop reviews */
export interface ShopReviewFilters {
  rating?: number;
  sortBy?: 'date' | 'rating' | 'helpful';
  sortOrder?: 'asc' | 'desc';
}

// ─── Output types ─────────────────────────────────────────────────────────────

/** Full review record with related entities */
export interface ReviewWithDetails {
  id: string;
  bookingId: string;
  userId: string;
  shopId: string;
  rating: number;
  title?: string;
  text: string;
  photos: string[];
  isVerified: boolean;
  isHidden: boolean;
  helpfulCount: number;
  createdAt: Date;
  updatedAt: Date;
  user?: { id: string; name: string };
  shop?: { id: string; name: string };
  response?: { id: string; text: string; createdAt: Date } | null;
}

/** Aggregated review summary for a shop */
export interface ReviewSummary {
  shopId: string;
  averageRating: number;
  totalReviews: number;
  verifiedCount: number;
  ratingDistribution: {
    1: number;
    2: number;
    3: number;
    4: number;
    5: number;
  };
  recentTrend: number; // avg rating over last 30 days
}

/** Review statistics for shop owners */
export interface ReviewStats {
  shopId: string;
  period: string;
  averageRating: number;
  responseRate: number;
  totalReviews: number;
  ratingTrend: Array<{ date: string; avgRating: number }>;
}

/** A review report submitted by a user */
export interface ReviewReport {
  id: string;
  reviewId: string;
  reporterId: string;
  reason: ReviewReportReason;
  details?: string;
  isResolved: boolean;
  createdAt: Date;
}
