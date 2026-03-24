import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { JsonWebTokenError, TokenExpiredError, NotBeforeError } from 'jsonwebtoken';
import { AppError, ValidationError } from '../shared/errors';
import { sendError } from '../shared/response';
import { env } from '../config/env';

export function errorHandler(
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  // Operational AppErrors
  if (err instanceof AppError) {
    const details = err instanceof ValidationError ? err.details : undefined;
    sendError(res, err.message, err.code, err.statusCode, details);
    return;
  }

  // JWT errors
  if (err instanceof TokenExpiredError) {
    sendError(res, 'Token has expired', 'TOKEN_EXPIRED', 401);
    return;
  }
  if (err instanceof JsonWebTokenError || err instanceof NotBeforeError) {
    sendError(res, 'Invalid token', 'INVALID_TOKEN', 401);
    return;
  }

  // Prisma known request errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    handlePrismaError(err, res);
    return;
  }

  // Prisma validation errors
  if (err instanceof Prisma.PrismaClientValidationError) {
    sendError(res, 'Database validation error', 'DB_VALIDATION_ERROR', 400);
    return;
  }

  // Unknown errors
  if (env.NODE_ENV !== 'production') {
    console.error('Unhandled error:', err);
  }

  sendError(res, 'Internal server error', 'INTERNAL_ERROR', 500);
}

function handlePrismaError(
  err: Prisma.PrismaClientKnownRequestError,
  res: Response,
): void {
  switch (err.code) {
    case 'P2002': {
      const fields = (err.meta?.target as string[])?.join(', ') ?? 'field';
      sendError(res, `Duplicate value for ${fields}`, 'CONFLICT', 409);
      break;
    }
    case 'P2025':
      sendError(res, 'Record not found', 'NOT_FOUND', 404);
      break;
    case 'P2003':
      sendError(res, 'Related record not found', 'FOREIGN_KEY_ERROR', 400);
      break;
    case 'P2014':
      sendError(res, 'Relation violation', 'RELATION_ERROR', 400);
      break;
    default:
      sendError(res, 'Database error', 'DB_ERROR', 500);
  }
}
