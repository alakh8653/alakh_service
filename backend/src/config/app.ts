import express, { Application } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { env } from './env';

export function createApp(): Application {
  const app = express();

  // ── Security headers
  app.use(helmet());

  // ── CORS
  app.use(
    cors({
      origin:
        env.NODE_ENV === 'production'
          ? ['https://alakhservice.com', 'https://www.alakhservice.com']
          : '*',
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true,
    }),
  );

  // ── Compression
  app.use(compression());

  // ── Request logging
  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));

  // ── Body parsers
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // ── Global rate limiter
  const limiter = rateLimit({
    windowMs: env.RATE_LIMIT_WINDOW_MS,
    max: env.RATE_LIMIT_MAX,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      message: 'Too many requests, please try again later.',
    },
  });
  app.use(limiter);

  // ── Health check
  app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString(), env: env.NODE_ENV });
  });

  return app;
}
