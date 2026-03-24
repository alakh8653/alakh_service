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
