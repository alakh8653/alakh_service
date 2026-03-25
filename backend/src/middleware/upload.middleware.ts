import multer from 'multer';
import { env } from '../config/env';
import { BadRequestError } from '../shared/errors';
import { Request } from 'express';

const memoryStorage = multer.memoryStorage();

const fileFilter = (allowedTypes: string[]) => {
  return (_req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new BadRequestError(`File type '${file.mimetype}' is not allowed`));
    }
  };
};

const maxSizeBytes = env.MAX_FILE_SIZE_MB * 1024 * 1024;

export const uploadImage = multer({
  storage: memoryStorage,
  limits: { fileSize: maxSizeBytes },
  fileFilter: fileFilter(env.ALLOWED_IMAGE_TYPES.split(',').map((t) => t.trim())),
});

export const uploadVideo = multer({
  storage: memoryStorage,
  limits: { fileSize: maxSizeBytes * 5 }, // 5x larger for videos
  fileFilter: fileFilter(env.ALLOWED_VIDEO_TYPES.split(',').map((t) => t.trim())),
});

export const uploadDocument = multer({
  storage: memoryStorage,
  limits: { fileSize: maxSizeBytes },
  fileFilter: fileFilter(env.ALLOWED_DOC_TYPES.split(',').map((t) => t.trim())),
});

export const uploadAny = multer({
  storage: memoryStorage,
  limits: { fileSize: maxSizeBytes },
  fileFilter: fileFilter([
    ...env.ALLOWED_IMAGE_TYPES.split(','),
    ...env.ALLOWED_VIDEO_TYPES.split(','),
    ...env.ALLOWED_DOC_TYPES.split(','),
  ].map((t) => t.trim())),
});
