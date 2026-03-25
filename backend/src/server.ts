
import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import morgan from 'morgan';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';

import { errorHandler } from './shared/errors/AppError';
import paymentsRouter from './modules/payments/payments.routes';
import reviewsRouter from './modules/reviews/reviews.routes';
import chatRouter from './modules/chat/chat.routes';
import notificationsRouter from './modules/notifications/notifications.routes';

const app = express();
const httpServer = createServer(app);

// ─── Socket.IO setup ──────────────────────────────────────────────────────────

const io = new SocketServer(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') ?? '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  const userId = socket.handshake.auth?.userId as string | undefined;
  if (userId) {
    socket.join(`user:${userId}`);
  }

  socket.on('join_conversation', (conversationId: string) => {
    socket.join(`conversation:${conversationId}`);
  });

  socket.on('leave_conversation', (conversationId: string) => {
    socket.leave(`conversation:${conversationId}`);
  });

  socket.on('disconnect', () => {
    // TODO: Update Redis presence key on disconnect
  });
});

// ─── Express middleware ───────────────────────────────────────────────────────

app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN?.split(',') ?? '*',
    credentials: true,
  }),
);
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// ─── Health check ─────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── API Routes ───────────────────────────────────────────────────────────────

const API_PREFIX = process.env.API_PREFIX ?? '/api/v1';

app.use(API_PREFIX, paymentsRouter);
app.use(API_PREFIX, reviewsRouter);
app.use(API_PREFIX, chatRouter);
app.use(API_PREFIX, notificationsRouter);

// ─── Global error handler ─────────────────────────────────────────────────────

app.use(errorHandler);

// ─── Start server ─────────────────────────────────────────────────────────────

const PORT = parseInt(process.env.PORT ?? '3000', 10);

httpServer.listen(PORT, () => {
  console.info(`🚀 Alakh Service API running on http://localhost:${PORT}${API_PREFIX}`);
  console.info(`🔌 Socket.IO listening on port ${PORT}`);
});

export { app, io };


import { createApp } from './config/app';
import { connectDatabase, disconnectDatabase } from './config/database';
import { connectRedis, disconnectRedis } from './config/redis';
import { env } from './config/env';
import { errorHandler } from './middleware/errorHandler';
import { notFound } from './middleware/notFound';

async function bootstrap(): Promise<void> {
  // Connect to external services
  await connectDatabase();
  await connectRedis();

  const app = createApp();

  // ── API routes (modules will be wired here)
  app.get(`/api/${env.API_VERSION}`, (_req, res) => {
    res.json({
      success: true,
      message: `AlakhService API ${env.API_VERSION}`,
      version: env.API_VERSION,
    });
  });

  // ── 404 handler (must be after all routes)
  app.use(notFound);

  // ── Global error handler (must be last)
  app.use(errorHandler);

  const server = app.listen(env.PORT, () => {
    console.log(`🚀 Server running on port ${env.PORT} [${env.NODE_ENV}]`);
    console.log(`   API: http://localhost:${env.PORT}/api/${env.API_VERSION}`);
    console.log(`   Health: http://localhost:${env.PORT}/health`);
  });

  // ── Graceful shutdown
  const shutdown = async (signal: string): Promise<void> => {
    console.log(`\n${signal} received. Shutting down gracefully...`);
    server.close(async () => {
      await disconnectDatabase();
      await disconnectRedis();
      console.log('Server closed.');
      process.exit(0);
    });

    // Force exit if not done in 10s
    setTimeout(() => {
      console.error('Forced shutdown after timeout.');
      process.exit(1);
    }, 10_000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  process.on('unhandledRejection', (reason) => {
    console.error('Unhandled Rejection:', reason);
    process.exit(1);
  });

  process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
  });
}

bootstrap().catch((err) => {
  console.error('Failed to start server:', err);

import 'dotenv/config';
import http from 'http';
import { Server as SocketServer } from 'socket.io';

import { createApp } from './app';
import { env } from './config/env';
import { logger } from './config/logger';
import { connectDatabase, disconnectDatabase } from './config/database';
import { connectRedis, disconnectRedis } from './config/redis';
import { initializeFirebase } from './config/firebase';
import { corsOptions } from './config/cors';

let server: http.Server;

const bootstrap = async (): Promise<void> => {
  // ---- Initialize DB ----
  await connectDatabase();

  // ---- Initialize Redis ----
  try {
    await connectRedis();
  } catch (err) {
    logger.warn('Redis connection failed, continuing without cache:', err);
  }

  // ---- Initialize Firebase ----
  initializeFirebase();

  // ---- Build Express app ----
  const app = createApp();

  // ---- HTTP server ----
  server = http.createServer(app);

  // ---- Socket.IO ----
  const io = new SocketServer(server, {
    cors: {
      origin: corsOptions.origin,
      credentials: true,
    },
    transports: ['websocket', 'polling'],
  });

  io.on('connection', (socket) => {
    logger.debug(`Socket connected: ${socket.id}`);

    socket.on('join:room', (roomId: string) => {
      socket.join(roomId);
      logger.debug(`Socket ${socket.id} joined room ${roomId}`);
    });

    socket.on('leave:room', (roomId: string) => {
      socket.leave(roomId);
    });

    socket.on('disconnect', (reason) => {
      logger.debug(`Socket disconnected: ${socket.id} - ${reason}`);
    });
  });

  // Attach io instance to app for use in routes
  app.set('io', io);

  // ---- Start listening ----
  server.listen(env.PORT, () => {
    logger.info(`🚀 Server running at ${env.APP_URL}`);
    logger.info(`📚 API Docs: ${env.APP_URL}/api/docs`);
    logger.info(`🌍 Environment: ${env.NODE_ENV}`);
  });
};

const gracefulShutdown = async (signal: string): Promise<void> => {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);

  if (server) {
    server.close(async () => {
      logger.info('HTTP server closed');
      await disconnectDatabase();
      await disconnectRedis();
      logger.info('Graceful shutdown complete');
      process.exit(0);
    });

    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10_000);
  } else {
    process.exit(0);
  }
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

process.on('unhandledRejection', (reason: unknown) => {
  logger.error('Unhandled Promise Rejection:', reason);
  // Give the process a chance to flush logs
  setTimeout(() => process.exit(1), 1000);
});

process.on('uncaughtException', (err: Error) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

bootstrap().catch((err) => {
  logger.error('Bootstrap failed:', err);
  process.exit(1);
});

