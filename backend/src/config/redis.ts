
import IORedis from 'ioredis';

const redisConfig = {
  host: process.env.REDIS_HOST ?? 'localhost',
  port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  password: process.env.REDIS_PASSWORD || undefined,
  maxRetriesPerRequest: 3,
  retryStrategy: (times: number) => Math.min(times * 50, 2000),
};

/**
 * Singleton Redis client instance.
 */
export const redis = new IORedis(redisConfig);

redis.on('error', (err) => {
  console.error('[Redis] Connection error:', err.message);
});

redis.on('connect', () => {
  console.info('[Redis] Connected successfully');
});

export default redis;

import Redis from 'ioredis';
import { env } from './env';


let redisInstance: Redis | null = null;

export function getRedis(): Redis {
  if (!redisInstance) {
    redisInstance = new Redis(env.REDIS_URL, {
      maxRetriesPerRequest: 3,
      enableReadyCheck: true,
      lazyConnect: true,
    });

    redisInstance.on('connect', () => {
      console.log('✅ Redis connected');
    });

    redisInstance.on('error', (err: Error) => {
      console.error('❌ Redis error:', err.message);
    });

    redisInstance.on('close', () => {
      console.warn('Redis connection closed');
    });
  }

  return redisInstance;
}

export async function connectRedis(): Promise<void> {
  const client = getRedis();
  await client.connect();
}

export async function disconnectRedis(): Promise<void> {
  if (redisInstance) {
    await redisInstance.quit();
    redisInstance = null;
    console.log('Redis disconnected');
  }
}

export const redis = getRedis();

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


