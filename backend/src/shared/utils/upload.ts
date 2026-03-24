import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';
import path from 'path';
import { uploadToS3, deleteFromS3 } from '../../config/storage';
import { env } from '../../config/env';
import { BadRequestError } from '../errors';

export interface ProcessedImage {
  buffer: Buffer;
  width: number;
  height: number;
  format: string;
  size: number;
}

export const processImage = async (
  buffer: Buffer,
  options: { width?: number; height?: number; quality?: number; format?: 'jpeg' | 'png' | 'webp' } = {},
): Promise<ProcessedImage> => {
  const { width, height, quality = 80, format = 'webp' } = options;

  let pipeline = sharp(buffer);

  if (width || height) {
    pipeline = pipeline.resize(width, height, { fit: 'inside', withoutEnlargement: true });
  }

  const outputBuffer = await pipeline[format]({ quality }).toBuffer();
  const meta = await sharp(outputBuffer).metadata();

  return {
    buffer: outputBuffer,
    width: meta.width ?? 0,
    height: meta.height ?? 0,
    format,
    size: outputBuffer.length,
  };
};

export const uploadFile = async (
  buffer: Buffer,
  originalName: string,
  mimeType: string,
  folder = 'uploads',
): Promise<string> => {
  validateFileSizeBuffer(buffer);

  const ext = path.extname(originalName).toLowerCase() || `.${mimeType.split('/')[1]}`;
  const fileName = `${uuidv4()}${ext}`;

  return uploadToS3(buffer, { folder, fileName, contentType: mimeType, isPublic: true });
};

export const uploadImageProcessed = async (
  buffer: Buffer,
  folder = 'images',
  options: { width?: number; height?: number; quality?: number } = {},
): Promise<string> => {
  validateFileSizeBuffer(buffer);
  const processed = await processImage(buffer, { ...options, format: 'webp' });
  const fileName = `${uuidv4()}.webp`;
  return uploadToS3(processed.buffer, { folder, fileName, contentType: 'image/webp', isPublic: true });
};

export const deleteFile = async (url: string): Promise<void> => {
  await deleteFromS3(url);
};

const validateFileSizeBuffer = (buffer: Buffer): void => {
  if (buffer.length > env.MAX_FILE_SIZE_MB * 1024 * 1024) {
    throw new BadRequestError(`File size exceeds ${env.MAX_FILE_SIZE_MB}MB limit`);
  }
};

export const getAllowedMimeTypes = (): string[] => {
  return [
    ...env.ALLOWED_IMAGE_TYPES.split(','),
    ...env.ALLOWED_VIDEO_TYPES.split(','),
    ...env.ALLOWED_DOC_TYPES.split(','),
  ].map((t) => t.trim());
};
