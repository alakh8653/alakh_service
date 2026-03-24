import { env } from './env';

export const CONSTANTS = {
  // Token types
  TOKEN_TYPES: {
    ACCESS: 'access',
    REFRESH: 'refresh',
    RESET_PASSWORD: 'reset_password',
    EMAIL_VERIFY: 'email_verify',
  },

  // User roles
  ROLES: {
    SUPER_ADMIN: 'SUPER_ADMIN',
    ADMIN: 'ADMIN',
    PROVIDER: 'PROVIDER',
    CUSTOMER: 'CUSTOMER',
  } as const,

  // Booking statuses
  BOOKING_STATUS: {
    PENDING: 'PENDING',
    CONFIRMED: 'CONFIRMED',
    IN_PROGRESS: 'IN_PROGRESS',
    COMPLETED: 'COMPLETED',
    CANCELLED: 'CANCELLED',
    REJECTED: 'REJECTED',
  } as const,

  // Payment statuses
  PAYMENT_STATUS: {
    PENDING: 'PENDING',
    PAID: 'PAID',
    FAILED: 'FAILED',
    REFUNDED: 'REFUNDED',
    PARTIALLY_REFUNDED: 'PARTIALLY_REFUNDED',
  } as const,

  // OTP
  OTP_EXPIRY_MS: env.OTP_EXPIRY_MINUTES * 60 * 1000,

  // Pagination
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: env.DEFAULT_PAGE_SIZE,
  MAX_LIMIT: env.MAX_PAGE_SIZE,

  // Cache keys
  CACHE_KEYS: {
    USER: (id: string) => `user:${id}`,
    SESSION: (id: string) => `session:${id}`,
    OTP: (phone: string) => `otp:${phone}`,
    CATEGORIES: 'categories:all',
    PROVIDER: (id: string) => `provider:${id}`,
    SERVICE: (id: string) => `service:${id}`,
    RATE_LIMIT: (key: string) => `rl:${key}`,
  },

  // File upload
  MAX_FILE_SIZE: env.MAX_FILE_SIZE_MB * 1024 * 1024,

  // Rating
  MIN_RATING: 1,
  MAX_RATING: 5,

  // Commission
  DEFAULT_PLATFORM_COMMISSION_PERCENT: 15,

  // Response messages
  MESSAGES: {
    SUCCESS: 'Success',
    CREATED: 'Created successfully',
    UPDATED: 'Updated successfully',
    DELETED: 'Deleted successfully',
    NOT_FOUND: 'Resource not found',
    UNAUTHORIZED: 'Unauthorized',
    FORBIDDEN: 'Forbidden',
    VALIDATION_ERROR: 'Validation error',
    INTERNAL_ERROR: 'Internal server error',
    DUPLICATE: 'Resource already exists',
  },
} as const;

export type Role = (typeof CONSTANTS.ROLES)[keyof typeof CONSTANTS.ROLES];
export type BookingStatus =
  (typeof CONSTANTS.BOOKING_STATUS)[keyof typeof CONSTANTS.BOOKING_STATUS];
export type PaymentStatus =
  (typeof CONSTANTS.PAYMENT_STATUS)[keyof typeof CONSTANTS.PAYMENT_STATUS];
