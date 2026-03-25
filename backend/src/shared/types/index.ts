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


// ---- Pagination ----
export interface PaginationQuery {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
}

export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface PaginatedResult<T> {
  data: T[];
  meta: PaginationMeta;
}

// ---- API Response ----

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

  meta?: PaginationMeta;
  errors?: Record<string, string[]>;
  requestId?: string;
}

// ---- Auth ----
export interface JwtPayload {
  sub: string;
  role: string;
  email?: string;
  phone?: string;
  iat?: number;
  exp?: number;
}

export interface RefreshTokenPayload {
  sub: string;
  tokenId: string;
  iat?: number;
  exp?: number;
}

export interface AuthenticatedUser {
  id: string;
  email?: string | null;
  phone?: string | null;
  role: string;
  name?: string | null;
}

// Extend Express Request
declare global {
  namespace Express {
    interface Request {
      user?: AuthenticatedUser;
      requestId?: string;
      pagination?: PaginationQuery & { skip: number };
    }
  }
}

// ---- File Upload ----
export interface UploadedFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

// ---- Geo ----
export interface GeoCoordinates {
  lat: number;
  lng: number;
}

export interface GeoAddress {
  street?: string;
  city: string;
  state: string;
  country: string;
  zipCode?: string;
  coordinates?: GeoCoordinates;
}

// ---- Service ----
export type ServiceType = 'HOME' | 'ONSITE' | 'BOTH';
export type DayOfWeek = 'MON' | 'TUE' | 'WED' | 'THU' | 'FRI' | 'SAT' | 'SUN';

export interface TimeSlot {
  day: DayOfWeek;
  startTime: string; // HH:mm
  endTime: string;   // HH:mm
}

// ---- Notification ----
export interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

// ---- Request with parsed body ----
export type TypedRequest<B = unknown, P = unknown, Q = unknown> = Request<
  P extends Record<string, string> ? P : Record<string, string>,
  unknown,
  B,
  Q extends Record<string, string> ? Q : Record<string, string>
>;

