import { Router, RequestHandler } from 'express';
import multer from 'multer';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { validate } from '../../middleware/validate';
import {
  updateProfileSchema,
  addressSchema,
  updateAddressSchema,
  listUsersQuerySchema,
  updateUserStatusSchema,
  changeRoleSchema,
} from './users.validators';
import * as controller from './users.controller';

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// All user routes require authentication
router.use(authenticate);

// ─── Profile ────────────────────────────────────────────────────────────────
router.get('/profile', controller.getProfile);
router.put('/profile', validate(updateProfileSchema), controller.updateProfile);
router.post('/profile/avatar', upload.single('avatar'), controller.uploadAvatar);
router.delete('/profile/avatar', controller.removeAvatar);
router.get('/profile/completion', controller.getProfileCompletion);

// ─── Addresses ──────────────────────────────────────────────────────────────
router.get('/addresses', controller.getAddresses);
router.post('/addresses', validate(addressSchema), controller.addAddress);
router.put('/addresses/:id', validate(updateAddressSchema), controller.updateAddress);
router.delete('/addresses/:id', controller.deleteAddress);
router.put('/addresses/:id/primary', controller.setPrimaryAddress);

// ─── Account ────────────────────────────────────────────────────────────────
router.delete('/account', controller.requestAccountDeletion);
router.get('/activity', controller.getActivitySummary);

// ─── Admin routes ────────────────────────────────────────────────────────────
const isAdmin = authorize('ADMIN', 'SUPER_ADMIN') as unknown as RequestHandler;
const isSuperAdmin = authorize('SUPER_ADMIN') as unknown as RequestHandler;

router.get(
  '/',
  isAdmin,
  validate(listUsersQuerySchema, 'query'),
  controller.listUsers,
);
router.get('/:id', isAdmin, controller.getUserById);
router.put(
  '/:id',
  isAdmin,
  validate(updateProfileSchema),
  controller.adminUpdateUser,
);
router.put(
  '/:id/status',
  isAdmin,
  validate(updateUserStatusSchema),
  controller.toggleUserStatus,
);
router.put(
  '/:id/role',
  isSuperAdmin,
  validate(changeRoleSchema),
  controller.changeUserRole,
);

export default router;
