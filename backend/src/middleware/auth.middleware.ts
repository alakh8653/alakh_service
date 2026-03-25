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

import { verifyAccessToken } from '../shared/utils/jwt';
import { UnauthorizedError } from '../shared/errors';
import { prisma } from '../config/database';
import { cacheGet, cacheSet } from '../shared/utils/cache';
import { CONSTANTS } from '../config/constants';
import { AuthenticatedUser } from '../shared/types';
import { env } from '../config/env';

export const authenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.slice(7);
    const payload = verifyAccessToken(token);

    // Try cache first
    const cacheKey = CONSTANTS.CACHE_KEYS.USER(payload.sub);
    let user = await cacheGet<AuthenticatedUser>(cacheKey);

    if (!user) {
      const dbUser = await prisma.user.findUnique({
        where: { id: payload.sub },
        select: { id: true, email: true, phone: true, role: true, name: true, isActive: true },
      });

      if (!dbUser) throw new UnauthorizedError('User not found');
      if (!dbUser.isActive) throw new UnauthorizedError('Account is deactivated');

      user = dbUser;
      await cacheSet(cacheKey, user, env.CACHE_TTL_SHORT);
    }

    req.user = user;
    next();
  } catch (err) {
    next(err);
  }
};

export const optionalAuthenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) return next();

    const token = authHeader.slice(7);
    const payload = verifyAccessToken(token);
    const dbUser = await prisma.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, email: true, phone: true, role: true, name: true, isActive: true },
    });

    if (dbUser?.isActive) req.user = dbUser;
  } catch {
    // silently ignore auth errors for optional auth
  }
  next();
};

