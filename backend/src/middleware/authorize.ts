import { Response, NextFunction } from 'express';
import { Role } from '@prisma/client';
import { ForbiddenError, UnauthorizedError } from '../shared/errors';
import { RequestWithUser } from '../shared/types';

export function authorize(...allowedRoles: Role[]) {
  return (req: RequestWithUser, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      next(new UnauthorizedError('Authentication required'));
      return;
    }

    if (!allowedRoles.includes(req.user.role)) {
      next(
        new ForbiddenError(
          `Access denied. Required roles: ${allowedRoles.join(', ')}`,
        ),
      );
      return;
    }

    next();
  };
}
