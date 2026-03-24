import { env } from '../../config/env';
import { PaginationMeta, PaginationQuery } from '../types';

export interface ParsedPagination {
  page: number;
  limit: number;
  skip: number;
  sortBy: string;
  sortOrder: 'asc' | 'desc';
  search?: string;
}

export const parsePagination = (query: PaginationQuery): ParsedPagination => {
  const page = Math.max(1, Number(query.page) || 1);
  const limit = Math.min(
    env.MAX_PAGE_SIZE,
    Math.max(1, Number(query.limit) || env.DEFAULT_PAGE_SIZE),
  );
  const skip = (page - 1) * limit;
  const sortOrder: 'asc' | 'desc' = query.sortOrder === 'asc' ? 'asc' : 'desc';

  return {
    page,
    limit,
    skip,
    sortBy: query.sortBy ?? 'createdAt',
    sortOrder,
    search: query.search,
  };
};

export const buildPaginationMeta = (
  total: number,
  page: number,
  limit: number,
): PaginationMeta => {
  const totalPages = Math.ceil(total / limit);
  return {
    total,
    page,
    limit,
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1,
  };
};
