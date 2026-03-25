import { Router } from 'express';
import { dispatchController } from './dispatch.controller';
import { authenticate } from '../../shared/middleware/authenticate';
import { authorize } from '../../shared/middleware/authorize';
import { validate } from '../../shared/middleware/validate';
import { UserRole } from '../../shared/types';
import {
  createDispatchSchema,
  rejectDispatchSchema,
  cancelDispatchSchema,
  dispatchFiltersQuerySchema,
  nearestStaffQuerySchema,
} from './dispatch.validators';

// ─── Staff / Customer Router ──────────────────────────────────────────────────
export const dispatchRouter = Router();

dispatchRouter.use(authenticate);

// Staff actions
dispatchRouter.get('/my', authorize(UserRole.STAFF), validate(dispatchFiltersQuerySchema, 'query'), dispatchController.getMyDispatches);
dispatchRouter.get('/customer', dispatchController.getCustomerDispatches);
dispatchRouter.put('/:id/accept', authorize(UserRole.STAFF), dispatchController.acceptDispatch);
dispatchRouter.put('/:id/reject', authorize(UserRole.STAFF), validate(rejectDispatchSchema), dispatchController.rejectDispatch);
dispatchRouter.put('/:id/en-route', authorize(UserRole.STAFF), dispatchController.markEnRoute);
dispatchRouter.put('/:id/arrived', authorize(UserRole.STAFF), dispatchController.markArrived);
dispatchRouter.put('/:id/start-service', authorize(UserRole.STAFF), dispatchController.startService);
dispatchRouter.put('/:id/complete', authorize(UserRole.STAFF), dispatchController.completeDispatch);
dispatchRouter.get('/:id/eta', dispatchController.getEta);

// ─── Shop Owner Router ────────────────────────────────────────────────────────
export const shopDispatchRouter = Router({ mergeParams: true });

shopDispatchRouter.use(authenticate);
shopDispatchRouter.use(authorize(UserRole.SHOP_OWNER, UserRole.ADMIN));

shopDispatchRouter.post('/', validate(createDispatchSchema), dispatchController.createDispatch);
shopDispatchRouter.get('/', validate(dispatchFiltersQuerySchema, 'query'), dispatchController.getShopDispatches);
shopDispatchRouter.get('/stats', dispatchController.getDispatchStats);
shopDispatchRouter.get('/nearest-staff', validate(nearestStaffQuerySchema, 'query'), dispatchController.findNearestStaff);
shopDispatchRouter.get('/:id', dispatchController.getDispatchById);
shopDispatchRouter.put('/:id/cancel', validate(cancelDispatchSchema), dispatchController.cancelDispatch);
shopDispatchRouter.put('/:id/reassign', dispatchController.reassignDispatch);

// ─── Admin Router ─────────────────────────────────────────────────────────────
export const adminDispatchRouter = Router();

adminDispatchRouter.use(authenticate);
adminDispatchRouter.use(authorize(UserRole.ADMIN));

adminDispatchRouter.get('/', dispatchController.listAllDispatches);
