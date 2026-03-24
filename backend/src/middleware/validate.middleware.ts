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
