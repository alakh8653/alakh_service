import { Request, Response, NextFunction } from 'express';

import { AnyZodObject, ZodError } from 'zod';
import { ValidationError } from '../errors/AppError';

/**
 * Express middleware factory that validates request body, query, or params
 * against a Zod schema.  Throws a {@link ValidationError} on failure.
 *
 * @param schema - Zod schema to validate against
 * @param target - Part of the request to validate (default: 'body')
 */
export function validate(
  schema: AnyZodObject,
  target: 'body' | 'query' | 'params' = 'body',
) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      const parsed = schema.parse(req[target]);
      req[target] = parsed; // replace with coerced/sanitised values
      next();
    } catch (err) {
      if (err instanceof ZodError) {
        const errors = err.errors.map((e) => ({
          path: e.path.join('.'),
          message: e.message,
        }));
        next(new ValidationError('Validation failed', errors));
      } else {
        next(err);
      }
    }
  };
}

import { ZodSchema, ZodError } from 'zod';
import { ValidationError } from '../shared/errors';

type ValidateTarget = 'body' | 'query' | 'params';

export const validate = (schema: ZodSchema, target: ValidateTarget = 'body') => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    try {
      const result = schema.safeParse(req[target]);
      if (!result.success) {
        const fieldErrors = formatZodErrors(result.error);
        return next(new ValidationError('Validation failed', fieldErrors));
      }
      // Assign parsed (and coerced) data back
      req[target] = result.data;
      next();
    } catch (err) {
      next(err);
    }
  };
};

const formatZodErrors = (error: ZodError): Record<string, string[]> => {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const key = issue.path.join('.') || '_root';
    if (!errors[key]) errors[key] = [];
    errors[key].push(issue.message);
  }
  return errors;
};

export const validateBody = (schema: ZodSchema) => validate(schema, 'body');
export const validateQuery = (schema: ZodSchema) => validate(schema, 'query');
export const validateParams = (schema: ZodSchema) => validate(schema, 'params');

