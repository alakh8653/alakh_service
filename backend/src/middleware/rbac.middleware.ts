import { Request, Response, NextFunction } from 'express';
import { ForbiddenError, UnauthorizedError } from '../shared/errors';
import { CONSTANTS, Role } from '../config/constants';

export const authorize = (...allowedRoles: Role[]) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new UnauthorizedError());
    }

    const userRole = req.user.role as Role;

    // Super admin bypasses all RBAC
    if (userRole === CONSTANTS.ROLES.SUPER_ADMIN) {
      return next();
    }

    if (!allowedRoles.includes(userRole)) {
      return next(
        new ForbiddenError(
          `Role '${userRole}' is not authorized to perform this action`,
        ),
      );
    }

    next();
  };
};

export const isSelf = (paramName = 'id') => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) return next(new UnauthorizedError());

    const targetId = req.params[paramName];
    const isSameUser = req.user.id === targetId;
    const isAdmin =
      req.user.role === CONSTANTS.ROLES.ADMIN ||
      req.user.role === CONSTANTS.ROLES.SUPER_ADMIN;

    if (!isSameUser && !isAdmin) {
      return next(new ForbiddenError('You can only access your own resources'));
    }

    next();
  };
};

export const isAdmin = authorize(CONSTANTS.ROLES.ADMIN, CONSTANTS.ROLES.SUPER_ADMIN);
export const isSuperAdmin = authorize(CONSTANTS.ROLES.SUPER_ADMIN);
export const isProvider = authorize(
  CONSTANTS.ROLES.PROVIDER,
  CONSTANTS.ROLES.ADMIN,
  CONSTANTS.ROLES.SUPER_ADMIN,
);
export const isCustomer = authorize(
  CONSTANTS.ROLES.CUSTOMER,
  CONSTANTS.ROLES.ADMIN,
  CONSTANTS.ROLES.SUPER_ADMIN,
);
