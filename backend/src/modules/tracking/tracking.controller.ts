import { Response, NextFunction } from 'express';
import { trackingService } from './tracking.service';
import { AuthenticatedRequest } from '../../shared/types';
import { sendSuccess, sendPaginated } from '../../shared/utils/response';
import { UpdateLocationInput, LocationHistoryFilters } from './tracking.types';

/**
 * Tracking controller — thin handlers that delegate to the service layer.
 */
export const trackingController = {
  /** PUT /api/v1/tracking/:dispatchId/location */
  async updateLocation(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const location = await trackingService.updateLocation(
        req.params.dispatchId,
        req.user!.userId,
        req.body as UpdateLocationInput,
      );
      sendSuccess(res, location, 'Location updated');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/tracking/:dispatchId/live */
  async getLiveLocation(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const location = await trackingService.getLiveLocation(
        req.params.dispatchId,
        req.user!.userId,
      );
      sendSuccess(res, location, 'Live location retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/tracking/:dispatchId/session */
  async getTrackingSession(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const session = await trackingService.getTrackingSession(
        req.params.dispatchId,
        req.user!.userId,
      );
      sendSuccess(res, session, 'Tracking session retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** GET /api/v1/tracking/:dispatchId/history */
  async getLocationHistory(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await trackingService.getLocationHistory(
        req.params.dispatchId,
        req.user!.userId,
        req.query as unknown as LocationHistoryFilters,
      );
      sendPaginated(res, result, 'Location history retrieved');
    } catch (err) {
      next(err);
    }
  },

  /** POST /api/v1/tracking/:dispatchId/subscribe */
  async subscribeToDispatch(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const socketId = req.body.socketId as string;
      await trackingService.subscribeToDispatch(
        socketId,
        req.params.dispatchId,
        req.user!.userId,
      );
      sendSuccess(res, null, 'Subscribed to dispatch tracking');
    } catch (err) {
      next(err);
    }
  },
};
