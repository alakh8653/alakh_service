import { getRedisClient } from '../../config/redis';
import { logger } from '../../config/logger';

export const cacheGet = async <T>(key: string): Promise<T | null> => {
  try {
    const client = getRedisClient();
    const value = await client.get(key);
    return value ? (JSON.parse(value) as T) : null;
  } catch (err) {
    logger.warn(`Cache GET failed for key ${key}:`, err);
    return null;
  }
};

export const cacheSet = async <T>(
  key: string,
  value: T,
  ttlSeconds?: number,
): Promise<void> => {
  try {
    const client = getRedisClient();
    const serialized = JSON.stringify(value);
    if (ttlSeconds) {
      await client.setex(key, ttlSeconds, serialized);
    } else {
      await client.set(key, serialized);
    }
  } catch (err) {
    logger.warn(`Cache SET failed for key ${key}:`, err);
  }
};

export const cacheDel = async (...keys: string[]): Promise<void> => {
  try {
    const client = getRedisClient();
    if (keys.length > 0) await client.del(...keys);
  } catch (err) {
    logger.warn(`Cache DEL failed for keys ${keys.join(',')}:`, err);
  }
};

export const cacheDelPattern = async (pattern: string): Promise<void> => {
  try {
    const client = getRedisClient();
    const keys = await client.keys(pattern);
    if (keys.length > 0) await client.del(...keys);
  } catch (err) {
    logger.warn(`Cache DEL pattern failed for ${pattern}:`, err);
  }
};

export const cacheGetOrSet = async <T>(
  key: string,
  fetcher: () => Promise<T>,
  ttlSeconds?: number,
): Promise<T> => {
  const cached = await cacheGet<T>(key);
  if (cached !== null) return cached;

  const value = await fetcher();
  await cacheSet(key, value, ttlSeconds);
  return value;
};

export const cacheIncr = async (key: string, ttlSeconds?: number): Promise<number> => {
  try {
    const client = getRedisClient();
    const val = await client.incr(key);
    if (ttlSeconds && val === 1) {
      await client.expire(key, ttlSeconds);
    }
    return val;
  } catch (err) {
    logger.warn(`Cache INCR failed for key ${key}:`, err);
    return 0;
  }
};
