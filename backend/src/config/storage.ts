import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { env } from './env';
import { logger } from './logger';
import { v4 as uuidv4 } from 'uuid';

let s3Client: S3Client | null = null;

export const getS3Client = (): S3Client => {
  if (s3Client) return s3Client;

  s3Client = new S3Client({
    region: env.AWS_REGION,
    credentials:
      env.AWS_ACCESS_KEY_ID && env.AWS_SECRET_ACCESS_KEY
        ? {
            accessKeyId: env.AWS_ACCESS_KEY_ID,
            secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
          }
        : undefined,
  });

  return s3Client;
};

export interface UploadOptions {
  folder?: string;
  fileName?: string;
  contentType?: string;
  isPublic?: boolean;
}

export const uploadToS3 = async (
  buffer: Buffer,
  options: UploadOptions = {},
): Promise<string> => {
  if (!env.AWS_S3_BUCKET) throw new Error('AWS_S3_BUCKET is not configured');

  const { folder = 'uploads', contentType = 'application/octet-stream', isPublic = true } = options;
  const fileName = options.fileName ?? `${uuidv4()}`;
  const key = `${folder}/${fileName}`;

  const client = getS3Client();

  await client.send(
    new PutObjectCommand({
      Bucket: env.AWS_S3_BUCKET,
      Key: key,
      Body: buffer,
      ContentType: contentType,
      ACL: isPublic ? 'public-read' : 'private',
    }),
  );

  return env.AWS_S3_URL ? `${env.AWS_S3_URL}/${key}` : key;
};

export const deleteFromS3 = async (key: string): Promise<void> => {
  if (!env.AWS_S3_BUCKET) throw new Error('AWS_S3_BUCKET is not configured');

  // Extract key from full URL if needed
  const objectKey = key.startsWith('http') ? key.split('.amazonaws.com/')[1] : key;

  const client = getS3Client();
  await client.send(
    new DeleteObjectCommand({
      Bucket: env.AWS_S3_BUCKET,
      Key: objectKey,
    }),
  );

  logger.info(`Deleted S3 object: ${objectKey}`);
};

export const getPresignedUploadUrl = async (
  key: string,
  contentType: string,
  expiresIn = 3600,
): Promise<string> => {
  if (!env.AWS_S3_BUCKET) throw new Error('AWS_S3_BUCKET is not configured');

  const client = getS3Client();
  const command = new PutObjectCommand({
    Bucket: env.AWS_S3_BUCKET,
    Key: key,
    ContentType: contentType,
  });

  return getSignedUrl(client, command, { expiresIn });
};

export const getPresignedDownloadUrl = async (key: string, expiresIn = 3600): Promise<string> => {
  if (!env.AWS_S3_BUCKET) throw new Error('AWS_S3_BUCKET is not configured');

  const client = getS3Client();
  const command = new GetObjectCommand({ Bucket: env.AWS_S3_BUCKET, Key: key });
  return getSignedUrl(client, command, { expiresIn });
};
