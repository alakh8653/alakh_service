import { Response } from 'express';
import { ApiResponse, PaginatedResponse } from '../types';

export function sendSuccess<T>(
  res: Response,
  data: T,
  message = 'Success',
  statusCode = 200,
  meta?: Record<string, unknown>,
): void {
  const response: ApiResponse<T> = { success: true, message, data, meta };
  res.status(statusCode).json(response);
}

export function sendCreated<T>(res: Response, data: T, message = 'Created'): void {
  sendSuccess(res, data, message, 201);
}

export function sendPaginated<T>(
  res: Response,
  result: PaginatedResponse<T>,
  message = 'Success',
): void {
  const response: ApiResponse<T[]> = {
    success: true,
    message,
    data: result.items,
    meta: {
      total: result.total,
      page: result.page,
      perPage: result.perPage,
      totalPages: result.totalPages,
      hasNextPage: result.hasNextPage,
      hasPrevPage: result.hasPrevPage,
    },
  };
  res.status(200).json(response);
}
