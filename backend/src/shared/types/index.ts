import { Request } from 'express';

export enum UserRole {
  CUSTOMER = 'CUSTOMER',
  SHOP_OWNER = 'SHOP_OWNER',
  STAFF = 'STAFF',
  ADMIN = 'ADMIN',
}

export interface AuthPayload {
  userId: string;
  role: UserRole;
  email?: string;
}

export interface AuthenticatedRequest extends Request {
  user?: AuthPayload;
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
  meta?: Record<string, unknown>;
}

export interface PaginationParams {
  page: number;
  perPage: number;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}
