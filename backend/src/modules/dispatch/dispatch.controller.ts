import { Response, NextFunction } from 'express';
import { dispatchService } from './dispatch.service';
import { AuthenticatedRequest } from '../../shared/types';
import { sendSuccess, sendCreated, sendPaginated } from '../../shared/utils/response';
import { CreateDispatchInput, DispatchFilters } from './dispatch.types';

/**
 * Dispatch controller — thin handlers that delegate to the service layer.
 */
export const dispatchController = {
  // ─── Shop Owner Handlers ──────────────────────────────────────────────

  /** POST /api/v1/shops/:shopId/dispatch */
  async createDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.createDispatch(
        req.params.shopId,
        req.user!.userId,
        req.body as CreateDispatchInput,
      );
      sendCreated(res, dispatch, 'Dispatch created successfully');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/dispatch */
  async getShopDispatches(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await dispatchService.getShopDispatches(
        req.params.shopId,
        req.user!.userId,
        req.query as unknown as DispatchFilters,
      );
      sendPaginated(res, result, 'Dispatches retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/dispatch/:id */
  async getDispatchById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.getDispatchById(
        req.params.id,
        req.user!.userId,
        req.user!.role,
      );
      sendSuccess(res, dispatch, 'Dispatch retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/dispatch/:id/cancel */
  async cancelDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.cancelDispatch(
        req.params.id,
        req.params.shopId,
        req.user!.userId,
        req.body.reason,
      );
      sendSuccess(res, dispatch, 'Dispatch cancelled');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/shops/:shopId/dispatch/:id/reassign */
  async reassignDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.reassignDispatch(
        req.params.id,
        req.params.shopId,
        req.user!.userId,
        req.body.staffId,
      );
      sendSuccess(res, dispatch, 'Dispatch reassigned');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/dispatch/stats */
  async getDispatchStats(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const stats = await dispatchService.getDispatchStats(
        req.params.shopId,
        req.user!.userId,
        req.query.period as string,
      );
      sendSuccess(res, stats, 'Dispatch stats retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/shops/:shopId/dispatch/nearest-staff */
  async findNearestStaff(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const staff = await dispatchService.findNearestStaff(
        req.params.shopId,
        req.user!.userId,
        Number(req.query.latitude),
        Number(req.query.longitude),
        Number(req.query.radiusKm) || 10,
      );
      sendSuccess(res, staff, 'Nearest staff retrieved');
    } catch (err) {
      next(err);
    }
  },

  // ─── Staff Handlers ───────────────────────────────────────────────────

  /** GET /api/v1/dispatch/my */
  async getMyDispatches(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await dispatchService.getStaffDispatches(
        req.user!.userId,
        req.query as unknown as DispatchFilters,
      );
      sendPaginated(res, result, 'Dispatches retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/accept */
  async acceptDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.acceptDispatch(req.params.id, req.user!.userId);
      sendSuccess(res, dispatch, 'Dispatch accepted');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/reject */
  async rejectDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.rejectDispatch(
        req.params.id,
        req.user!.userId,
        req.body.reason,
      );
      sendSuccess(res, dispatch, 'Dispatch rejected');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/en-route */
  async markEnRoute(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.markEnRoute(req.params.id, req.user!.userId);
      sendSuccess(res, dispatch, 'Marked as en route');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/arrived */
  async markArrived(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.markArrived(req.params.id, req.user!.userId);
      sendSuccess(res, dispatch, 'Marked as arrived');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/start-service */
  async startService(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.startService(req.params.id, req.user!.userId);
      sendSuccess(res, dispatch, 'Service started');
    } catch (err) {
      next(err);
    }
  },

  /** PUT /api/v1/dispatch/:id/complete */
  async completeDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const dispatch = await dispatchService.completeDispatch(req.params.id, req.user!.userId);
      sendSuccess(res, dispatch, 'Dispatch completed');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/dispatch/:id/eta */
  async getEta(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const eta = await dispatchService.calculateEta(req.params.id, req.user!.userId);
      sendSuccess(res, eta, 'ETA calculated');
    } catch (err) {
      next(err);
    }
  },

  // ─── Customer Handlers ────────────────────────────────────────────────

  /** GET /api/v1/dispatch/customer */
  async getCustomerDispatches(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await dispatchService.getCustomerDispatches(
        req.user!.userId,
        req.query as unknown as DispatchFilters,
      );
      sendPaginated(res, result, 'Dispatches retrieved');
    } catch (err) {
      next(err);
    }
  },

  // ─── Admin Handlers ───────────────────────────────────────────────────

  /** GET /api/v1/admin/dispatch */
  async listAllDispatches(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await dispatchService.listAllDispatches(
        req.query as unknown as DispatchFilters & { shopId?: string },
      );
      sendPaginated(res, result, 'All dispatches retrieved');
    } catch (err) {
      next(err);
    }
  },
};
