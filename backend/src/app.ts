import express, { Application } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';

import { corsOptions } from './config/cors';
import { morganStream } from './config/logger';
import { swaggerSpec } from './config/swagger';
import { env } from './config/env';
import { globalRateLimit, requestId, errorHandler, notFoundHandler } from './middleware';
import apiRouter from './routes';

export const createApp = (): Application => {
  const app = express();

  // ---- Core security middleware ----
  app.use(helmet());
  app.use(cors(corsOptions));

  // ---- Request ID ----
  app.use(requestId);

  // ---- Compression ----
  app.use(compression());

  // ---- Body parsers ----
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // ---- HTTP logging ----
  app.use(
    morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev', {
      stream: morganStream,
    }),
  );

  // ---- Global rate limiting ----
  app.use(globalRateLimit);

  // ---- Health check ----
  app.get('/health', (_req, res) => {
    res.json({
      success: true,
      status: 'ok',
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
      environment: env.NODE_ENV,
    });
  });

  // ---- API docs ----
  if (env.NODE_ENV !== 'production') {
    app.use(
      '/api/docs',
      swaggerUi.serve,
      swaggerUi.setup(swaggerSpec, {
        explorer: true,
        customCssUrl:
          'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/5.11.0/swagger-ui.min.css',
      }),
    );
  }

  // ---- API routes ----
  app.use('/api/v1', apiRouter);

  // ---- 404 handler ----
  app.use(notFoundHandler);

  // ---- Global error handler ----
  app.use(errorHandler);

  return app;
};
