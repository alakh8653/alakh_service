import { Response, NextFunction } from 'express';
import { queueService } from './queue.service';
import { AuthenticatedRequest } from '../../shared/types';
import { sendSuccess, sendCreated, sendPaginated } from '../../shared/utils/response';
import { JoinQueueInput, QueueFilters, QueueSettingsInput } from './queue.types';

/**
 * Queue controller — thin handlers that delegate to the service layer.
 */
export const queueController = {
  /** POST /api/v1/queue/join */
  async joinQueue(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const status = await queueService.joinQueue(req.user!.userId, req.body as JoinQueueInput);
      sendCreated(res, status, 'Joined queue successfully');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/queue/:entryId/status */
  async getQueueStatus(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const status = await queueService.getQueueStatus(req.params.entryId, req.user!.userId);
      sendSuccess(res, status, 'Queue status retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** DELETE /api/v1/queue/:entryId/leave */
  async leaveQueue(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      await queueService.leaveQueue(req.params.entryId, req.user!.userId);
      sendSuccess(res, null, 'Left queue successfully');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/queue/my-entries */
  async getMyQueueEntries(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const entries = await queueService.getUserQueueEntries(req.user!.userId);
      sendSuccess(res, entries, 'Queue entries retrieved');
    } catch (err) {
      next(err);
    }
  },

  // ─── Shop Owner Handlers ──────────────────────────────────────────────

  /** GET /api/v1/shops/:shopId/queue */
  async getShopQueue(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await queueService.getShopQueue(
        req.params.shopId,
        req.user!.userId,
        req.query as unknown as QueueFilters,
      );
      sendPaginated(res, result, 'Shop queue retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** POST /api/v1/shops/:shopId/queue/call-next */
  async callNext(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const entry = await queueService.callNext(req.params.shopId, req.user!.userId);
      sendSuccess(res, entry, 'Next customer called');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/queue/:entryId/serve */
  async startServing(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const entry = await queueService.startServing(
        req.params.shopId,
        req.user!.userId,
        req.params.entryId,
      );
      sendSuccess(res, entry, 'Serving started');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/queue/:entryId/complete */
  async completeEntry(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const entry = await queueService.completeEntry(
        req.params.shopId,
        req.user!.userId,
        req.params.entryId,
      );
      sendSuccess(res, entry, 'Entry completed');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/queue/:entryId/skip */
  async skipEntry(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      await queueService.skipEntry(req.params.shopId, req.user!.userId, req.params.entryId);
      sendSuccess(res, null, 'Entry skipped');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/queue/reorder */
  async reorderQueue(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      await queueService.reorderQueue(req.params.shopId, req.user!.userId, req.body.entries);
      sendSuccess(res, null, 'Queue reordered');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/queue/settings */
  async getQueueSettings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const settings = await queueService.getQueueSettings(req.params.shopId, req.user!.userId);
      sendSuccess(res, settings, 'Queue settings retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/queue/settings */
  async updateQueueSettings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const settings = await queueService.updateQueueSettings(
        req.params.shopId,
        req.user!.userId,
        req.body as QueueSettingsInput,
      );
      sendSuccess(res, settings, 'Queue settings updated');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/queue/stats */
  async getQueueStats(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const stats = await queueService.getQueueStats(
        req.params.shopId,
        req.user!.userId,
        req.query.startDate as string | undefined,
        req.query.endDate as string | undefined,
      );
      sendSuccess(res, stats, 'Queue stats retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** DELETE /api/v1/shops/:shopId/queue/clear */
  async clearQueue(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await queueService.clearQueue(req.params.shopId, req.user!.userId);
      sendSuccess(res, result, 'Queue cleared');
    } catch (err) {
      next(err);
    }
  },
};
