import { Request, Response, NextFunction } from 'express';
import { parsePagination } from '../shared/utils/pagination';

export const paginationMiddleware = (req: Request, _res: Response, next: NextFunction): void => {
  const parsed = parsePagination({
    page: req.query['page'] ? Number(req.query['page']) : undefined,
    limit: req.query['limit'] ? Number(req.query['limit']) : undefined,
    sortBy: req.query['sortBy'] as string | undefined,
    sortOrder: req.query['sortOrder'] as 'asc' | 'desc' | undefined,
    search: req.query['search'] as string | undefined,
  });

  req.pagination = parsed;
  next();
};
