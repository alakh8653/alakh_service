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
