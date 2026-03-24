import winston from 'winston';
import path from 'path';
import fs from 'fs';
import { env } from './env';

const LOG_DIR = env.LOG_DIR || 'logs';
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

const { combine, timestamp, printf, colorize, errors, json } = winston.format;

const devFormat = combine(
  colorize({ all: true }),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  errors({ stack: true }),
  printf(({ timestamp: ts, level, message, stack, ...meta }) => {
    const metaStr = Object.keys(meta).length ? ` ${JSON.stringify(meta)}` : '';
    return `${ts} [${level}]: ${stack || message}${metaStr}`;
  }),
);

const prodFormat = combine(timestamp(), errors({ stack: true }), json());

export const logger = winston.createLogger({
  level: env.LOG_LEVEL,
  format: env.NODE_ENV === 'production' ? prodFormat : devFormat,
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({
      filename: path.join(LOG_DIR, 'error.log'),
      level: 'error',
      format: combine(timestamp(), errors({ stack: true }), json()),
      maxsize: 10 * 1024 * 1024, // 10MB
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: path.join(LOG_DIR, 'combined.log'),
      format: combine(timestamp(), errors({ stack: true }), json()),
      maxsize: 20 * 1024 * 1024, // 20MB
      maxFiles: 10,
    }),
  ],
  exceptionHandlers: [
    new winston.transports.File({ filename: path.join(LOG_DIR, 'exceptions.log') }),
  ],
  rejectionHandlers: [
    new winston.transports.File({ filename: path.join(LOG_DIR, 'rejections.log') }),
  ],
});

export const morganStream = {
  write: (message: string) => logger.http(message.trim()),
};
