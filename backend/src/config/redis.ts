import Redis from 'ioredis';
import { env } from './env';
import { logger } from './logger';

let redisClient: Redis | null = null;

export const getRedisClient = (): Redis => {
  if (redisClient) return redisClient;

  const config = env.REDIS_URL
    ? { lazyConnect: true }
    : {
        host: env.REDIS_HOST,
        port: env.REDIS_PORT,
        password: env.REDIS_PASSWORD || undefined,
        db: env.REDIS_DB,
        lazyConnect: true,
      };

  redisClient = env.REDIS_URL ? new Redis(env.REDIS_URL, config) : new Redis(config);

  redisClient.on('connect', () => logger.info('✅ Redis connected'));
  redisClient.on('error', (err) => logger.error('Redis error:', err));
  redisClient.on('close', () => logger.warn('Redis connection closed'));

  return redisClient;
};

export const connectRedis = async (): Promise<void> => {
  const client = getRedisClient();
  try {
    await client.connect();
    logger.info('✅ Redis connected successfully');
  } catch (error) {
    logger.error('❌ Redis connection failed:', error);
    throw error;
  }
};

export const disconnectRedis = async (): Promise<void> => {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
    logger.info('Redis disconnected');
  }
};

export { redisClient };
