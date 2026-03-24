import { PaginationParams, PaginatedResponse } from '../types';

export function getPaginationParams(query: { page?: unknown; perPage?: unknown }): PaginationParams {
  const page = Math.max(1, Number(query.page) || 1);
  const perPage = Math.min(100, Math.max(1, Number(query.perPage) || 20));
  return { page, perPage };
}

export function buildPaginatedResponse<T>(
  items: T[],
  total: number,
  params: PaginationParams,
): PaginatedResponse<T> {
  const totalPages = Math.ceil(total / params.perPage);
  return {
    items,
    total,
    page: params.page,
    perPage: params.perPage,
    totalPages,
    hasNextPage: params.page < totalPages,
    hasPrevPage: params.page > 1,
  };
}

export function getSkip(params: PaginationParams): number {
  return (params.page - 1) * params.perPage;
}
