import { Router } from 'express';
import { trackingController } from './tracking.controller';
import { authenticate } from '../../shared/middleware/authenticate';
import { authorize } from '../../shared/middleware/authorize';
import { validate } from '../../shared/middleware/validate';
import { UserRole } from '../../shared/types';
import { updateLocationSchema, locationHistoryQuerySchema } from './tracking.validators';

export const trackingRouter = Router();

trackingRouter.use(authenticate);

// Staff posts location updates
trackingRouter.put(
  '/:dispatchId/location',
  authorize(UserRole.STAFF),
  validate(updateLocationSchema),
  trackingController.updateLocation,
);

// Any authorized user can view live location, session, or history
trackingRouter.get('/:dispatchId/live', trackingController.getLiveLocation);
trackingRouter.get('/:dispatchId/session', trackingController.getTrackingSession);
trackingRouter.get(
  '/:dispatchId/history',
  validate(locationHistoryQuerySchema, 'query'),
  trackingController.getLocationHistory,
);

// Subscribe a socket connection to a dispatch room
trackingRouter.post('/:dispatchId/subscribe', trackingController.subscribeToDispatch);
