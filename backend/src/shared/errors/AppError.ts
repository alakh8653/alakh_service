
import { Request, Response, NextFunction } from 'express';

/** HTTP status codes used across the application */
export const HttpStatus = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

/**
 * Base application error class.
 * All custom errors extend this to allow uniform error handling middleware.

/**
 * Base application error class.
 * All custom errors extend this class.

 */
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;
  public readonly code?: string;


  constructor(
    message: string,
    statusCode = HttpStatus.INTERNAL_SERVER_ERROR,
    code?: string,
    isOperational = true,
  ) {

  constructor(message: string, statusCode: number, code?: string, isOperational = true) {

    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.code = code;
    Object.setPrototypeOf(this, new.target.prototype);

    Error.captureStackTrace(this, this.constructor);
  }
}

/** 400 Bad Request */
export class BadRequestError extends AppError {
  constructor(message = 'Bad request', code?: string) {
    super(message, HttpStatus.BAD_REQUEST, code);
  }
}

/** 401 Unauthorised */
export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized', code?: string) {
    super(message, HttpStatus.UNAUTHORIZED, code);
  }
}

/** 403 Forbidden */
export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden', code?: string) {
    super(message, HttpStatus.FORBIDDEN, code);
  }
}

/** 404 Not Found */
export class NotFoundError extends AppError {
  constructor(message = 'Resource not found', code?: string) {
    super(message, HttpStatus.NOT_FOUND, code);
  }
}

/** 409 Conflict */
export class ConflictError extends AppError {
  constructor(message = 'Conflict', code?: string) {
    super(message, HttpStatus.CONFLICT, code);
  }
}

/** 422 Unprocessable Entity – validation failures */
export class ValidationError extends AppError {
  public readonly errors: unknown;

  constructor(message = 'Validation failed', errors?: unknown) {
    super(message, HttpStatus.UNPROCESSABLE_ENTITY, 'VALIDATION_ERROR');
    this.errors = errors;
  }
}

/**
 * Global error-handling middleware.
 * Must be registered after all routes.
 */
export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof ValidationError) {
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      code: err.code,
      errors: err.errors,
    });
    return;
  }

  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      code: err.code,
    });
    return;
  }

  // Unhandled errors
  console.error('[Unhandled Error]', err);
  res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
    success: false,
    message: 'An unexpected error occurred',
    code: 'INTERNAL_ERROR',
  });

    Error.captureStackTrace(this);
  }
}

export class BadRequestError extends AppError {
  constructor(message = 'Bad Request', code?: string) {
    super(message, 400, code);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized', code?: string) {
    super(message, 401, code);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden', code?: string) {
    super(message, 403, code);
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'Not Found', code?: string) {
    super(message, 404, code);
  }
}

export class ConflictError extends AppError {
  constructor(message = 'Conflict', code?: string) {
    super(message, 409, code);
  }
}

export class UnprocessableEntityError extends AppError {
  constructor(message = 'Unprocessable Entity', code?: string) {
    super(message, 422, code);
  }
}

export class InternalServerError extends AppError {
  constructor(message = 'Internal Server Error', code?: string) {
    super(message, 500, code, false);
  }

}
