import { Response } from 'express';
import { PaginationMeta } from './types';

export interface ApiSuccessResponse<T> {
  success: true;
  message: string;
  data: T;
}

export interface ApiPaginatedResponse<T> {
  success: true;
  message: string;
  data: T[];
  meta: PaginationMeta;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  code: string;
  details?: unknown;
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message = 'Success',
  statusCode = 200,
): Response<ApiSuccessResponse<T>> {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

export function sendPaginated<T>(
  res: Response,
  data: T[],
  meta: PaginationMeta,
  message = 'Success',
): Response<ApiPaginatedResponse<T>> {
  return res.status(200).json({
    success: true,
    message,
    data,
    meta,
  });
}

export function sendError(
  res: Response,
  message = 'An error occurred',
  code = 'ERROR',
  statusCode = 500,
  details?: unknown,
): Response<ApiErrorResponse> {
  const body: ApiErrorResponse = { success: false, message, code };
  if (details !== undefined) body.details = details;
  return res.status(statusCode).json(body);
}
