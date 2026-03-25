import nodemailer, { Transporter } from 'nodemailer';
import { env } from './env';
import { logger } from './logger';

let transporter: Transporter | null = null;

export const getEmailTransporter = (): Transporter => {
  if (transporter) return transporter;

  transporter = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE,
    auth:
      env.SMTP_USER && env.SMTP_PASS
        ? { user: env.SMTP_USER, pass: env.SMTP_PASS }
        : undefined,
    pool: true,
    maxConnections: 5,
    maxMessages: 100,
  });

  return transporter;
};

export const verifyEmailConnection = async (): Promise<boolean> => {
  if (!env.SMTP_USER) {
    logger.warn('Email not configured. Email sending disabled.');
    return false;
  }
  try {
    await getEmailTransporter().verify();
    logger.info('✅ Email transporter ready');
    return true;
  } catch (error) {
    logger.warn('Email transporter verification failed:', error);
    return false;
  }
};

export interface EmailOptions {
  to: string | string[];
  subject: string;
  html: string;
  text?: string;
  replyTo?: string;
  attachments?: Array<{ filename: string; content: Buffer | string; contentType?: string }>;
}

export const sendEmail = async (options: EmailOptions): Promise<boolean> => {
  if (!env.SMTP_USER) {
    logger.warn(`[Email Skipped] To: ${options.to} | Subject: ${options.subject}`);
    return false;
  }

  try {
    const info = await getEmailTransporter().sendMail({
      from: `"${env.EMAIL_FROM_NAME}" <${env.EMAIL_FROM_ADDRESS}>`,
      to: Array.isArray(options.to) ? options.to.join(', ') : options.to,
      subject: options.subject,
      html: options.html,
      text: options.text,
      replyTo: options.replyTo,
      attachments: options.attachments,
    });

    logger.info(`Email sent: ${info.messageId}`);
    return true;
  } catch (error) {
    logger.error('Email send failed:', error);
    return false;
  }
};
