import { Gender, Role } from '@prisma/client';

/** Input for user registration */
export interface RegisterInput {
  firstName: string;
  lastName: string;
  email?: string;
  phone?: string;
  password: string;
  role: Role;
}

/** Input for password-based login */
export interface LoginInput {
  /** Email address or phone number */
  identifier: string;
  password: string;
}

/** Input for OTP-related operations */
export interface OTPInput {
  /** Email address or phone number */
  identifier: string;
  type: 'email' | 'phone';
  otp?: string;
}

/** Input for token refresh */
export interface RefreshTokenInput {
  refreshToken: string;
}

/** Input for forgot-password flow */
export interface ForgotPasswordInput {
  /** Email address or phone number */
  identifier: string;
}

/** Input for resetting a password via OTP */
export interface ResetPasswordInput {
  /** Email address or phone number */
  identifier: string;
  otp: string;
  newPassword: string;
}

/** Input for changing a password while authenticated */
export interface ChangePasswordInput {
  currentPassword: string;
  newPassword: string;
}

/** Input for social (OAuth) login */
export interface SocialLoginInput {
  provider: 'google' | 'apple';
  /** Provider-issued id_token or access_token */
  token: string;
}

/** Access/refresh token pair returned to the client */
export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  /** Access token lifetime in seconds */
  expiresIn: number;
}

/** User object safe to return to clients (no passwordHash) */
export interface SafeUser {
  id: string;
  firstName: string;
  lastName: string;
  email: string | null;
  phone: string | null;
  role: Role;
  isActive: boolean;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  avatarUrl: string | null;
  bio: string | null;
  dateOfBirth: Date | null;
  gender: Gender | null;
  trustScore: number;
  lastLoginAt: Date | null;
  deletedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

/** Full auth response with user profile and token pair */
export interface AuthResponse {
  user: SafeUser;
  tokens: TokenPair;
}
