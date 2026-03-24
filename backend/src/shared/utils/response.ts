import { Response } from 'express';
import { PaginationMeta } from '../types';

export const sendSuccess = <T>(
  res: Response,
  data: T,
  message = 'Success',
  statusCode = 200,
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
