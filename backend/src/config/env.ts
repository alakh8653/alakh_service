import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const envSchema = z.object({
  // Application
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000').transform(Number),
  APP_NAME: z.string().default('AlakhService'),
  APP_URL: z.string().url().default('http://localhost:3000'),
  CLIENT_URL: z.string().url().default('http://localhost:5173'),

  // Database
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),

  // Redis
  REDIS_HOST: z.string().default('localhost'),
  REDIS_PORT: z.string().default('6379').transform(Number),
  REDIS_PASSWORD: z.string().optional().default(''),
  REDIS_DB: z.string().default('0').transform(Number),
  REDIS_URL: z.string().optional(),

  // JWT
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  JWT_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_SECRET: z.string().min(32, 'JWT_REFRESH_SECRET must be at least 32 characters'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),

  // AWS S3
  AWS_ACCESS_KEY_ID: z.string().optional(),
  AWS_SECRET_ACCESS_KEY: z.string().optional(),
  AWS_REGION: z.string().default('ap-south-1'),
  AWS_S3_BUCKET: z.string().optional(),
  AWS_S3_URL: z.string().optional(),

  // Firebase
  FIREBASE_PROJECT_ID: z.string().optional(),
  FIREBASE_PRIVATE_KEY_ID: z.string().optional(),
  FIREBASE_PRIVATE_KEY: z.string().optional(),
  FIREBASE_CLIENT_EMAIL: z.string().optional(),
  FIREBASE_CLIENT_ID: z.string().optional(),
  FIREBASE_AUTH_URI: z.string().optional(),
  FIREBASE_TOKEN_URI: z.string().optional(),
  FIREBASE_DATABASE_URL: z.string().optional(),

  // Email
  SMTP_HOST: z.string().default('smtp.gmail.com'),
  SMTP_PORT: z.string().default('587').transform(Number),
  SMTP_SECURE: z
    .string()
    .default('false')
    .transform((v) => v === 'true'),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  EMAIL_FROM_NAME: z.string().default('Alakh Service'),
  EMAIL_FROM_ADDRESS: z.string().email().default('noreply@alakhservice.com'),

  // Razorpay
  RAZORPAY_KEY_ID: z.string().optional(),
  RAZORPAY_KEY_SECRET: z.string().optional(),
  RAZORPAY_WEBHOOK_SECRET: z.string().optional(),

  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: z.string().default('900000').transform(Number),
  RATE_LIMIT_MAX_REQUESTS: z.string().default('100').transform(Number),
  AUTH_RATE_LIMIT_MAX: z.string().default('10').transform(Number),

  // Logging
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'http', 'debug']).default('debug'),
  LOG_DIR: z.string().default('logs'),

  // OTP
  OTP_EXPIRY_MINUTES: z.string().default('10').transform(Number),
  OTP_LENGTH: z.string().default('6').transform(Number),

  // File Upload
  MAX_FILE_SIZE_MB: z.string().default('10').transform(Number),
  ALLOWED_IMAGE_TYPES: z
    .string()
    .default('image/jpeg,image/png,image/webp,image/gif'),
  ALLOWED_VIDEO_TYPES: z.string().default('video/mp4,video/webm'),
  ALLOWED_DOC_TYPES: z.string().default('application/pdf'),

  // Pagination
  DEFAULT_PAGE_SIZE: z.string().default('20').transform(Number),
  MAX_PAGE_SIZE: z.string().default('100').transform(Number),

  // Cache TTL
  CACHE_TTL_SHORT: z.string().default('300').transform(Number),
  CACHE_TTL_MEDIUM: z.string().default('3600').transform(Number),
  CACHE_TTL_LONG: z.string().default('86400').transform(Number),

  // Bcrypt
  BCRYPT_SALT_ROUNDS: z.string().default('12').transform(Number),

  // CORS
  ALLOWED_ORIGINS: z
    .string()
    .default('http://localhost:3000,http://localhost:5173'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:');
  console.error(parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;
export type Env = typeof env;
