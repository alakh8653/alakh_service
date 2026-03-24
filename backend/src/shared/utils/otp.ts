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
