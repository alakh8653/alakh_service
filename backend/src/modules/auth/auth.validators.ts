import { z } from 'zod';

const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .regex(/[0-9]/, 'Password must contain at least one number')
  .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character');

/** Schema for new user registration. Requires at least one of email or phone. */
export const registerSchema = z
  .object({
    firstName: z.string().min(2, 'First name must be at least 2 characters'),
    lastName: z.string().min(2, 'Last name must be at least 2 characters'),
    email: z.string().email('Invalid email address').optional(),
    phone: z.string().min(10, 'Phone must be at least 10 characters').optional(),
    password: passwordSchema,
    role: z.enum(['CUSTOMER', 'SHOP_OWNER'], {
      errorMap: () => ({ message: 'Role must be CUSTOMER or SHOP_OWNER' }),
    }),
  })
  .refine((data) => data.email !== undefined || data.phone !== undefined, {
    message: 'At least one of email or phone is required',
    path: ['email'],
  });

/** Schema for password-based login */
export const loginSchema = z.object({
  identifier: z.string().min(1, 'Identifier is required'),
  password: z.string().min(1, 'Password is required'),
});

/** Schema for sending an OTP to email or phone */
export const sendOTPSchema = z.object({
  identifier: z.string().min(1, 'Identifier is required'),
  type: z.enum(['email', 'phone'], {
    errorMap: () => ({ message: 'Type must be email or phone' }),
  }),
});

/** Schema for verifying an OTP */
export const verifyOTPSchema = z.object({
  identifier: z.string().min(1, 'Identifier is required'),
  type: z.enum(['email', 'phone'], {
    errorMap: () => ({ message: 'Type must be email or phone' }),
  }),
  otp: z
    .string()
    .length(6, 'OTP must be exactly 6 digits')
    .regex(/^\d{6}$/, 'OTP must contain only digits'),
});

/** Schema for refreshing tokens */
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

/** Schema for initiating a password reset */
export const forgotPasswordSchema = z.object({
  identifier: z.string().min(1, 'Identifier is required'),
});

/** Schema for completing a password reset via OTP */
export const resetPasswordSchema = z.object({
  identifier: z.string().min(1, 'Identifier is required'),
  otp: z
    .string()
    .length(6, 'OTP must be exactly 6 digits')
    .regex(/^\d{6}$/, 'OTP must contain only digits'),
  newPassword: passwordSchema,
});

/** Schema for changing password while authenticated */
export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: passwordSchema,
});

/** Schema for social/OAuth login */
export const socialLoginSchema = z.object({
  provider: z.enum(['google', 'apple'], {
    errorMap: () => ({ message: 'Provider must be google or apple' }),
  }),
  token: z.string().min(1, 'Token is required'),
});
