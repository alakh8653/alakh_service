import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { UnauthorizedError, ForbiddenError } from '../shared/errors/AppError';

/** Payload stored in the JWT access token */
export interface JWTPayload {
  userId: string;
  email: string;
  role: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
}

// Augment Express Request type
declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

/**
 * Middleware – verifies the Bearer JWT token and attaches the decoded
 * payload to `req.user`.
 */
export function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
): void {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    throw new UnauthorizedError('Missing or invalid Authorization header');
  }

  const token = authHeader.slice(7);
  try {
    const payload = jwt.verify(
      token,
      process.env.JWT_SECRET ?? 'default_secret',
    ) as JWTPayload;
    req.user = payload;
    next();
  } catch {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

/**
 * Middleware factory – checks that `req.user.role` is in the allowed list.
 * Must be used *after* {@link authenticate}.
 *
 * @param roles - Allowed roles
 */
export function authorize(...roles: Array<'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN'>) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      throw new UnauthorizedError();
    }
    if (!roles.includes(req.user.role)) {
      throw new ForbiddenError(
        `Access denied. Required roles: ${roles.join(', ')}`,
      );
    }
    next();
  };
}
