import { Request, Response, NextFunction } from 'express';
import { ReviewsService } from './reviews.service';
import { HttpStatus } from '../../shared/errors/AppError';

const service = new ReviewsService();

// ─── Customer handlers ────────────────────────────────────────────────────────

/** POST /api/v1/reviews */
export async function submitReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.submitReview(req.user!.userId, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/reviews */
export async function getUserReviews(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const page = parseInt((req.query.page as string) ?? '1', 10);
    const perPage = parseInt((req.query.perPage as string) ?? '20', 10);
    const result = await service.getUserReviews(req.user!.userId, page, perPage);
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/reviews/:id */
export async function getReviewById(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getReviewById(req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/reviews/:id */
export async function updateReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.updateReview(
      req.user!.userId,
      req.params.id,
      req.body,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/reviews/:id */
export async function deleteReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.deleteReview(req.user!.userId, req.params.id);
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/reviews/:id/helpful */
export async function markHelpful(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.markHelpful(req.user!.userId, req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/reviews/:id/report */
export async function reportReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.reportReview(
      req.user!.userId,
      req.params.id,
      req.body.reason,
      req.body.details,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── Public handlers ──────────────────────────────────────────────────────────

/** GET /api/v1/shops/:shopId/reviews */
export async function getShopReviews(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { rating, sortBy, sortOrder, page, perPage } = req.query as Record<
      string,
      string
    >;
    const result = await service.getShopReviews(
      req.params.shopId,
      {
        rating: rating ? parseInt(rating, 10) : undefined,
        sortBy: sortBy as 'date' | 'rating' | 'helpful' | undefined,
        sortOrder: sortOrder as 'asc' | 'desc' | undefined,
      },
      parseInt(page ?? '1', 10),
      parseInt(perPage ?? '20', 10),
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/shops/:shopId/reviews/summary */
export async function getShopReviewSummary(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getShopReviewSummary(req.params.shopId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── Shop owner handlers ──────────────────────────────────────────────────────

/** POST /api/v1/shops/:shopId/reviews/:reviewId/respond */
export async function respondToReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.respondToReview(
      req.params.shopId,
      req.user!.userId,
      req.params.reviewId,
      req.body.text,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/shops/:shopId/reviews/:reviewId/respond */
export async function updateReviewResponse(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.updateResponse(
      req.params.shopId,
      req.user!.userId,
      req.params.reviewId,
      req.body.text,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/shops/:shopId/reviews/:reviewId/respond */
export async function deleteReviewResponse(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.deleteResponse(
      req.params.shopId,
      req.user!.userId,
      req.params.reviewId,
    );
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/shops/:shopId/reviews/stats */
export async function getShopReviewStats(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const period =
      (req.query.period as 'week' | 'month' | 'year') ?? 'month';
    const result = await service.getShopReviewStats(
      req.params.shopId,
      req.user!.userId,
      period,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

// ─── Admin handlers ───────────────────────────────────────────────────────────

/** GET /api/v1/admin/reviews */
export async function adminListReviews(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { shopId, userId, rating, isHidden, page, perPage } =
      req.query as Record<string, string>;
    const result = await service.listAllReviews(
      {
        shopId,
        userId,
        rating: rating ? parseInt(rating, 10) : undefined,
        isHidden: isHidden !== undefined ? isHidden === 'true' : undefined,
      },
      parseInt(page ?? '1', 10),
      parseInt(perPage ?? '20', 10),
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/admin/reviews/reported */
export async function adminGetReportedReviews(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { page, perPage } = req.query as Record<string, string>;
    const result = await service.getReportedReviews(
      parseInt(page ?? '1', 10),
      parseInt(perPage ?? '20', 10),
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/admin/reviews/:id/hide */
export async function adminHideReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.hideReview(req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/admin/reviews/:id/restore */
export async function adminRestoreReview(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.restoreReview(req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/admin/reviews/reports/:reportId */
export async function adminGetReportDetails(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getReportDetails(req.params.reportId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/admin/reviews/reports/:reportId/resolve */
export async function adminResolveReport(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.resolveReport(
      req.params.reportId,
      req.body.adminNote,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}
