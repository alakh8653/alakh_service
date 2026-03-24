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
  process.exit(1);
});
