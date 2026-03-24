import { sendEmail, EmailOptions } from '../../config/email';
import { env } from '../../config/env';

const baseHtml = (content: string): string => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 0; }
    .container { max-width: 600px; margin: 30px auto; background: #fff; border-radius: 8px; overflow: hidden; }
    .header { background: #4f46e5; padding: 24px; text-align: center; }
    .header h1 { color: #fff; margin: 0; font-size: 24px; }
    .body { padding: 32px; color: #333; line-height: 1.6; }
    .otp { font-size: 36px; font-weight: bold; text-align: center; letter-spacing: 8px;
           background: #f3f4f6; padding: 16px; border-radius: 8px; margin: 24px 0; color: #4f46e5; }
    .btn { display: inline-block; background: #4f46e5; color: #fff; padding: 12px 28px;
           border-radius: 6px; text-decoration: none; font-weight: bold; margin: 16px 0; }
    .footer { background: #f9fafb; padding: 16px; text-align: center; font-size: 12px; color: #999; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header"><h1>${env.APP_NAME}</h1></div>
    <div class="body">${content}</div>
    <div class="footer">&copy; ${new Date().getFullYear()} ${env.APP_NAME}. All rights reserved.</div>
  </div>
</body>
</html>
`;

export const sendOTPEmail = async (to: string, otp: string, name?: string): Promise<boolean> => {
  const html = baseHtml(`
    <p>Hello ${name ?? 'there'},</p>
    <p>Your OTP for verification is:</p>
    <div class="otp">${otp}</div>
    <p>This OTP is valid for <strong>${env.OTP_EXPIRY_MINUTES} minutes</strong>.</p>
    <p>If you did not request this, please ignore this email.</p>
  `);

  return sendEmail({ to, subject: `Your ${env.APP_NAME} OTP`, html });
};

export const sendWelcomeEmail = async (to: string, name: string): Promise<boolean> => {
  const html = baseHtml(`
    <p>Hi ${name},</p>
    <p>Welcome to <strong>${env.APP_NAME}</strong>! We're excited to have you on board.</p>
    <p>You can now book and manage services right from your phone or browser.</p>
    <p style="text-align:center;"><a href="${env.CLIENT_URL}" class="btn">Get Started</a></p>
  `);

  return sendEmail({ to, subject: `Welcome to ${env.APP_NAME}!`, html });
};

export const sendPasswordResetEmail = async (
  to: string,
  name: string,
  resetToken: string,
): Promise<boolean> => {
  const resetUrl = `${env.CLIENT_URL}/reset-password?token=${resetToken}`;
  const html = baseHtml(`
    <p>Hi ${name},</p>
    <p>You requested a password reset. Click the button below to set a new password:</p>
    <p style="text-align:center;"><a href="${resetUrl}" class="btn">Reset Password</a></p>
    <p>This link is valid for 1 hour. If you did not request this, please ignore this email.</p>
  `);

  return sendEmail({ to, subject: `Password Reset - ${env.APP_NAME}`, html });
};

export const sendBookingConfirmationEmail = async (
  to: string,
  name: string,
  bookingId: string,
  serviceName: string,
  scheduledAt: Date,
): Promise<boolean> => {
  const html = baseHtml(`
    <p>Hi ${name},</p>
    <p>Your booking has been confirmed!</p>
    <table style="width:100%;border-collapse:collapse;margin:16px 0;">
      <tr><td style="padding:8px;color:#666;">Booking ID</td><td style="padding:8px;font-weight:bold;">${bookingId}</td></tr>
      <tr><td style="padding:8px;color:#666;">Service</td><td style="padding:8px;">${serviceName}</td></tr>
      <tr><td style="padding:8px;color:#666;">Scheduled At</td><td style="padding:8px;">${scheduledAt.toLocaleString()}</td></tr>
    </table>
    <p style="text-align:center;"><a href="${env.CLIENT_URL}/bookings/${bookingId}" class="btn">View Booking</a></p>
  `);

  return sendEmail({ to, subject: `Booking Confirmed - ${serviceName}`, html });
};

export { sendEmail };
export type { EmailOptions };
