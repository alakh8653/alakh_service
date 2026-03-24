import bcrypt from 'bcryptjs';
import { env } from '../../config/env';

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, env.BCRYPT_SALT_ROUNDS);
};

export const comparePassword = async (
  password: string,
  hash: string,
): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

export const hashString = async (value: string, rounds = 10): Promise<string> => {
  return bcrypt.hash(value, rounds);
};
