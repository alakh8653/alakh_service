import { Response } from 'express';

import { ApiResponse, PaginatedResponse } from '../types';

export function sendSuccess<T>(

import { PaginationMeta } from '../types';

export const sendSuccess = <T>(

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

): Response => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    requestId: res.getHeader('X-Request-ID'),
  });
};

export const sendCreated = <T>(res: Response, data: T, message = 'Created successfully'): Response =>
  sendSuccess(res, data, message, 201);

export const sendPaginated = <T>(
  res: Response,
  data: T[],
  meta: PaginationMeta,
  message = 'Success',
): Response => {
  return res.status(200).json({
    success: true,
    message,
    data,
    meta,
    requestId: res.getHeader('X-Request-ID'),
  });
};

export const sendError = (
  res: Response,
  message: string,
  statusCode = 500,
  code = 'INTERNAL_ERROR',
  errors?: Record<string, string[]>,
): Response => {
  return res.status(statusCode).json({
    success: false,
    message,
    code,
    ...(errors && { errors }),
    requestId: res.getHeader('X-Request-ID'),
  });
};

export const sendNoContent = (res: Response): Response => res.status(204).send();

