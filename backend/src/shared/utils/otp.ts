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
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < 6; i++) {
    otp += digits[Math.floor(Math.random() * 10)];
  }
  return otp;
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
