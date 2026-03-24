
import { randomInt } from 'crypto';
import { redis } from '../../config/redis';
import { env } from '../../config/env';

const OTP_PREFIX = 'otp:';
const OTP_ATTEMPT_PREFIX = 'otp_attempts:';
const MAX_ATTEMPTS = 5;

function otpKey(identifier: string): string {
  return `${OTP_PREFIX}${identifier}`;
}

function otpAttemptsKey(identifier: string): string {
  return `${OTP_ATTEMPT_PREFIX}${identifier}`;
}

export function generateOTP(): string {
  // Use cryptographically secure random integer in range [0, 999999]
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

export async function storeOTP(identifier: string, otp: string): Promise<void> {
  const key = otpKey(identifier);
  const ttlSeconds = env.OTP_EXPIRES_IN_MINUTES * 60;
  await redis.set(key, otp, 'EX', ttlSeconds);
  // Reset attempt counter on new OTP
  await redis.del(otpAttemptsKey(identifier));
}

export async function verifyOTP(identifier: string, inputOtp: string): Promise<boolean> {
  const attemptsKey = otpAttemptsKey(identifier);
  const attempts = await redis.incr(attemptsKey);

  if (attempts === 1) {
    // Set TTL on first attempt
    await redis.expire(attemptsKey, env.OTP_EXPIRES_IN_MINUTES * 60);
  }

  if (attempts > MAX_ATTEMPTS) {
    await deleteOTP(identifier);
    throw new Error('Too many OTP attempts. Please request a new OTP.');
  }

  const key = otpKey(identifier);
  const storedOtp = await redis.get(key);

  if (!storedOtp) {
    return false;
  }

  const isValid = storedOtp === inputOtp;
  if (isValid) {
    await deleteOTP(identifier);
  }

  return isValid;
}

export async function deleteOTP(identifier: string): Promise<void> {
  await redis.del(otpKey(identifier));
  await redis.del(otpAttemptsKey(identifier));
}

export async function hasActiveOTP(identifier: string): Promise<boolean> {
  const ttl = await redis.ttl(otpKey(identifier));
  return ttl > 0;
}
import crypto from 'crypto';
import { env } from '../../config/env';

export const generateOTP = (): string => {
  const length = env.OTP_LENGTH;
  const max = Math.pow(10, length);
  const min = Math.pow(10, length - 1);
  return String(crypto.randomInt(min, max));
};

export const generateNumericToken = (length = 6): string => {
  const max = Math.pow(10, length);
  const min = Math.pow(10, length - 1);
  return String(crypto.randomInt(min, max));
};

export const generateSecureToken = (bytes = 32): string => {
  return crypto.randomBytes(bytes).toString('hex');
};

export const generateOTPExpiry = (): Date => {
  return new Date(Date.now() + env.OTP_EXPIRY_MINUTES * 60 * 1000);
};

export const isOTPExpired = (expiry: Date): boolean => {
  return new Date() > expiry;
};
