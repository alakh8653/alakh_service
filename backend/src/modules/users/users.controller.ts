import { Request, Response, NextFunction } from 'express';
import { sendSuccess, sendPaginated } from '../../shared/response';
import { RequestWithUser } from '../../shared/types';
import { usersService } from './users.service';
import {
  UpdateProfileInput,
  AddressInput,
  UpdateAddressInput,
  UserListFilters,
  AdminUpdateUserInput,
} from './users.types';

// ─── Profile ────────────────────────────────────────────────────────────────

/** GET /users/profile */
export async function getProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const profile = await usersService.getProfile(id);
    sendSuccess(res, profile, 'Profile retrieved');
  } catch (err) {
    next(err);
  }
}

/** PUT /users/profile */
export async function updateProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const updated = await usersService.updateProfile(id, req.body as UpdateProfileInput);
    sendSuccess(res, updated, 'Profile updated');
  } catch (err) {
    next(err);
  }
}

/** POST /users/profile/avatar */
export async function uploadAvatar(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    if (!req.file) {
      res.status(400).json({ success: false, message: 'No file uploaded', code: 'BAD_REQUEST' });
      return;
    }
    const updated = await usersService.uploadAvatar(id, req.file);
    sendSuccess(res, updated, 'Avatar uploaded');
  } catch (err) {
    next(err);
  }
}

/** DELETE /users/profile/avatar */
export async function removeAvatar(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const updated = await usersService.removeAvatar(id);
    sendSuccess(res, updated, 'Avatar removed');
  } catch (err) {
    next(err);
  }
}

// ─── Addresses ──────────────────────────────────────────────────────────────

/** GET /users/addresses */
export async function getAddresses(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const addresses = await usersService.getAddresses(id);
    sendSuccess(res, addresses, 'Addresses retrieved');
  } catch (err) {
    next(err);
  }
}

/** POST /users/addresses */
export async function addAddress(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const address = await usersService.addAddress(id, req.body as AddressInput);
    sendSuccess(res, address, 'Address added', 201);
  } catch (err) {
    next(err);
  }
}

/** PUT /users/addresses/:id */
export async function updateAddress(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const address = await usersService.updateAddress(
      id,
      req.params.id,
      req.body as UpdateAddressInput,
    );
    sendSuccess(res, address, 'Address updated');
  } catch (err) {
    next(err);
  }
}

/** DELETE /users/addresses/:id */
export async function deleteAddress(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    await usersService.deleteAddress(id, req.params.id);
    sendSuccess(res, null, 'Address deleted');
  } catch (err) {
    next(err);
  }
}

/** PUT /users/addresses/:id/primary */
export async function setPrimaryAddress(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const address = await usersService.setPrimaryAddress(id, req.params.id);
    sendSuccess(res, address, 'Primary address set');
  } catch (err) {
    next(err);
  }
}

// ─── Misc ────────────────────────────────────────────────────────────────────

/** GET /users/profile/completion */
export async function getProfileCompletion(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const completion = await usersService.getProfileCompletion(id);
    sendSuccess(res, completion, 'Profile completion retrieved');
  } catch (err) {
    next(err);
  }
}

/** DELETE /users/account */
export async function requestAccountDeletion(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    await usersService.requestAccountDeletion(id);
    sendSuccess(res, null, 'Account deletion requested');
  } catch (err) {
    next(err);
  }
}

/** GET /users/activity */
export async function getActivitySummary(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = (req as RequestWithUser).user;
    const activity = await usersService.getActivitySummary(id);
    sendSuccess(res, activity, 'Activity summary retrieved');
  } catch (err) {
    next(err);
  }
}

// ─── Admin ───────────────────────────────────────────────────────────────────

/** GET /users/ (admin) */
export async function listUsers(req: Request, res: Response, next: NextFunction) {
  try {
    const filters = req.query as unknown as UserListFilters;
    const { users, meta } = await usersService.listUsers(filters);
    sendPaginated(res, users, meta, 'Users retrieved');
  } catch (err) {
    next(err);
  }
}

/** GET /users/:id (admin) */
export async function getUserById(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await usersService.getUserById(req.params.id);
    sendSuccess(res, user, 'User retrieved');
  } catch (err) {
    next(err);
  }
}

/** PUT /users/:id (admin) */
export async function adminUpdateUser(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await usersService.updateUser(
      req.params.id,
      req.body as AdminUpdateUserInput,
    );
    sendSuccess(res, user, 'User updated');
  } catch (err) {
    next(err);
  }
}

/** PUT /users/:id/status (admin) */
export async function toggleUserStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { isActive } = req.body as { isActive: boolean };
    const user = await usersService.toggleUserStatus(req.params.id, isActive);
    sendSuccess(res, user, 'User status updated');
  } catch (err) {
    next(err);
  }
}

/** PUT /users/:id/role (super admin) */
export async function changeUserRole(req: Request, res: Response, next: NextFunction) {
  try {
    const { role } = req.body as { role: string };
    const user = await usersService.changeUserRole(req.params.id, role);
    sendSuccess(res, user, 'User role updated');
  } catch (err) {
    next(err);
  }
}
