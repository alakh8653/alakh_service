import { PrismaClient } from '@prisma/client';
import { env } from './env';
import { logger } from './logger';

declare global {
  // eslint-disable-next-line no-var
  var __prisma: PrismaClient | undefined;
}

const createPrismaClient = () => {
  return new PrismaClient({
    log:
      env.NODE_ENV === 'development'
        ? [
            { emit: 'event', level: 'query' },
            { emit: 'event', level: 'error' },
            { emit: 'event', level: 'warn' },
          ]
        : [{ emit: 'event', level: 'error' }],
  });
};

export const prisma: PrismaClient = global.__prisma ?? createPrismaClient();

if (env.NODE_ENV !== 'production') {
  global.__prisma = prisma;
}

if (env.NODE_ENV === 'development') {
  // @ts-expect-error prisma event typing
  prisma.$on('query', (e: { query: string; duration: number }) => {
    logger.debug(`Prisma Query: ${e.query} (${e.duration}ms)`);
  });
}

// @ts-expect-error prisma event typing
prisma.$on('error', (e: { message: string }) => {
  logger.error(`Prisma Error: ${e.message}`);
});

export const connectDatabase = async (): Promise<void> => {
  try {
    await prisma.$connect();
    logger.info('✅ Database connected successfully');
  } catch (error) {
    logger.error('❌ Database connection failed:', error);
    throw error;
  }
};

export const disconnectDatabase = async (): Promise<void> => {
  await prisma.$disconnect();
  logger.info('Database disconnected');
};
