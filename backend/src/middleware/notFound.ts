import { Request, Response, NextFunction } from 'express';
import { sendError } from '../shared/response';

export function notFound(req: Request, res: Response, _next: NextFunction): void {
  sendError(
    res,
    `Cannot ${req.method} ${req.originalUrl}`,
    'NOT_FOUND',
    404,
  );
}
