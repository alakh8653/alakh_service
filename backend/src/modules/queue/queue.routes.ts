import { Router } from 'express';
import { queueController } from './queue.controller';
import { authenticate } from '../../shared/middleware/authenticate';
import { authorize } from '../../shared/middleware/authorize';
import { validate } from '../../shared/middleware/validate';
import { UserRole } from '../../shared/types';
import {
  joinQueueSchema,
  reorderSchema,
  queueSettingsSchema,
  queueStatsQuerySchema,
  queueFiltersQuerySchema,
} from './queue.validators';

// ─── Customer Router ──────────────────────────────────────────────────────────
export const queueRouter = Router();

queueRouter.use(authenticate);

queueRouter.post('/join', validate(joinQueueSchema), queueController.joinQueue);
queueRouter.get('/my-entries', queueController.getMyQueueEntries);
queueRouter.get('/:entryId/status', queueController.getQueueStatus);
queueRouter.delete('/:entryId/leave', queueController.leaveQueue);

// ─── Shop Owner Router ────────────────────────────────────────────────────────
export const shopQueueRouter = Router({ mergeParams: true });

shopQueueRouter.use(authenticate);
shopQueueRouter.use(authorize(UserRole.SHOP_OWNER, UserRole.ADMIN));

shopQueueRouter.get('/', validate(queueFiltersQuerySchema, 'query'), queueController.getShopQueue);
shopQueueRouter.post('/call-next', queueController.callNext);
shopQueueRouter.put('/reorder', validate(reorderSchema), queueController.reorderQueue);
shopQueueRouter.delete('/clear', queueController.clearQueue);
shopQueueRouter.get('/settings', queueController.getQueueSettings);
shopQueueRouter.put('/settings', validate(queueSettingsSchema), queueController.updateQueueSettings);
shopQueueRouter.get('/stats', validate(queueStatsQuerySchema, 'query'), queueController.getQueueStats);
shopQueueRouter.put('/:entryId/serve', queueController.startServing);
shopQueueRouter.put('/:entryId/complete', queueController.completeEntry);
shopQueueRouter.put('/:entryId/skip', queueController.skipEntry);
