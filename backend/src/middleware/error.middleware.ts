import { Request, Response, NextFunction } from 'express';
import { AppError, isAppError } from '../shared/errors';
import { logger } from '../config/logger';
import { env } from '../config/env';
import { ZodError } from 'zod';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  let statusCode = 500;
  let message = 'Internal server error';
  let code = 'INTERNAL_ERROR';
  let errors: Record<string, string[]> | undefined;

  if (isAppError(err)) {
    statusCode = err.statusCode;
    message = err.message;
    code = err.code;
    if ('errors' in err && err.errors) {
      errors = err.errors as Record<string, string[]>;
    }

    if (err.isOperational) {
      logger.warn(`[${code}] ${message}`, {
        path: req.path,
        method: req.method,
        requestId: req.requestId,
      });
    } else {
      logger.error(`[Unexpected AppError] ${message}`, {
        stack: err.stack,
        path: req.path,
        method: req.method,
      });
    }
  } else if (err instanceof ZodError) {
    statusCode = 422;
    message = 'Validation failed';
    code = 'VALIDATION_ERROR';
    const fieldErrors: Record<string, string[]> = {};
    for (const issue of err.issues) {
      const key = issue.path.join('.') || '_root';
      if (!fieldErrors[key]) fieldErrors[key] = [];
      fieldErrors[key].push(issue.message);
    }
    errors = fieldErrors;
  } else if (err.name === 'PrismaClientKnownRequestError') {
    const prismaErr = err as Error & { code?: string; meta?: { target?: string[] } };
    if (prismaErr.code === 'P2002') {
      statusCode = 409;
      message = `Duplicate value for field: ${prismaErr.meta?.target?.join(', ')}`;
      code = 'CONFLICT';
    } else if (prismaErr.code === 'P2025') {
      statusCode = 404;
      message = 'Record not found';
      code = 'NOT_FOUND';
    } else {
      logger.error('Prisma error:', { code: prismaErr.code, stack: err.stack });
    }
  } else {
    logger.error('Unhandled error:', { message: err.message, stack: err.stack });
  }

  res.status(statusCode).json({
    success: false,
    message,
    code,
    ...(errors && { errors }),
    ...(env.NODE_ENV === 'development' && { stack: err.stack }),
    requestId: req.requestId,
  });
};

export const notFoundHandler = (req: Request, res: Response): void => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.path} not found`,
    code: 'NOT_FOUND',
    requestId: req.requestId,
  });
};
