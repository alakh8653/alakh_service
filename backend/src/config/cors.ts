import { CorsOptions } from 'cors';

/**
 * Allowed origins for CORS.
 *
 * Covers Flutter web dev servers, Android emulator access to localhost,
 * and any custom origins configured via the CORS_ORIGINS environment variable.
 */
const allowedOrigins: Array<string | undefined> = [
  'http://localhost:3000', // Backend itself
  'http://localhost:8080', // Flutter web (shop_web)
  'http://localhost:8081', // Flutter web (admin_web)
  'http://localhost:5000', // Flutter web (mobile_app web)
  'http://localhost:3001', // Alternative Flutter web port
  'http://10.0.2.2:3000', // Android emulator → host machine
  process.env.CORS_ORIGINS, // Custom origins from env (comma-separated or single origin)
];

/**
 * Flattened, deduplicated list of allowed origins, excluding undefined values.
 *
 * If CORS_ORIGINS contains comma-separated values they are each treated as
 * individual allowed origins.
 */
const resolvedOrigins: string[] = allowedOrigins
  .flatMap((o) =>
    o
      ? o
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean)
      : [],
  )
  .filter((v, i, arr) => arr.indexOf(v) === i); // deduplicate

/**
 * CORS configuration used by the Express app.
 *
 * Origin validation: requests from any origin in [resolvedOrigins] are
 * permitted. In development (NODE_ENV !== 'production') all origins are
 * additionally allowed to simplify local iteration.
 */
export const corsOptions: CorsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (e.g. mobile apps, curl, Postman)
    if (!origin) {
      return callback(null, true);
    }

    // In non-production environments, allow all origins for developer convenience
    if (process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }

    if (resolvedOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error(`CORS: origin '${origin}' is not allowed`));
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Request-ID',
    'X-Client-Version',
  ],
  exposedHeaders: ['X-Request-ID', 'X-Rate-Limit-Remaining'],
  maxAge: 86400, // 24 hours — browsers cache preflight responses
};
