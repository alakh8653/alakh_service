import { Request, Response, NextFunction } from 'express';
import { UnauthorizedError } from '../shared/errors';
import { verifyAccessToken } from '../shared/utils/jwt';
import { prisma } from '../config/database';
import { RequestWithUser } from '../shared/types';

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('No bearer token provided');
    }

    const token = authHeader.slice(7);
    if (!token) {
      throw new UnauthorizedError('Token is missing');
    }

    const payload = verifyAccessToken(token);

    if (payload.type !== 'access') {
      throw new UnauthorizedError('Invalid token type');
    }

    // Verify user still exists and is active
    const user = await prisma.user.findFirst({
      where: { id: payload.sub, isActive: true, deletedAt: null },
      select: { id: true, email: true, role: true },
    });

    if (!user) {
      throw new UnauthorizedError('User account not found or inactive');
    }

    (req as RequestWithUser).user = {
      id: user.id,
      email: user.email,
      role: user.role,
    };

    next();
  } catch (error) {
    next(error);
  }
}
