import { Prisma, Role, User } from '@prisma/client';
import { redis } from '../../config/redis';
import { env } from '../../config/env';
import {
  BadRequestError,
  ConflictError,
  NotFoundError,
  UnauthorizedError,
} from '../../shared/errors';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from '../../shared/utils/jwt';
import { generateOTP, storeOTP, verifyOTP } from '../../shared/utils/otp';
import { comparePassword, hashPassword } from '../../shared/utils/password';
import { authRepository } from './auth.repository';
import {
  AuthResponse,
  ChangePasswordInput,
  ForgotPasswordInput,
  LoginInput,
  OTPInput,
  RegisterInput,
  ResetPasswordInput,
  SafeUser,
  SocialLoginInput,
  TokenPair,
} from './auth.types';

class AuthService {
  // ─────────────────────────────────────────
  // Public methods
  // ─────────────────────────────────────────

  /**
   * Register a new user, send a verification OTP, and return an AuthResponse.
   */
  async register(data: RegisterInput): Promise<AuthResponse> {
    const passwordHash = await hashPassword(data.password);

    let user: User;
    try {
      user = await authRepository.createUser({
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        phone: data.phone,
        passwordHash,
        role: data.role,
      });
    } catch (err) {
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
        throw new ConflictError('Email or phone number is already registered');
      }
      throw err;
    }

    // Store verification OTPs in Redis and (TODO) send them
    const ttl = env.OTP_EXPIRES_IN_MINUTES * 60;
    if (user.email) {
      const otp = generateOTP();
      await redis.set(`verify:email:${user.id}`, otp, 'EX', ttl);
      // TODO: send verification email via nodemailer/SES
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Email verification OTP for ${user.email}: ${otp}`);
      }
    }
    if (user.phone) {
      const otp = generateOTP();
      await redis.set(`verify:phone:${user.id}`, otp, 'EX', ttl);
      // TODO: send verification SMS via Twilio
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Phone verification OTP for ${user.phone}: ${otp}`);
      }
    }

    const tokens = await this.generateTokenPair(user.id, user.role, user.email);
    return { user: this.buildSafeUser(user), tokens };
  }

  /**
   * Authenticate a user with email/phone + password.
   */
  async login(data: LoginInput): Promise<AuthResponse> {
    const user = await this.resolveUser(data.identifier);

    if (!user) {
      throw new UnauthorizedError('Invalid credentials');
    }
    if (!user.passwordHash) {
      throw new UnauthorizedError(
        'This account uses social login or OTP — password login is not available',
      );
    }
    if (!user.isActive) {
      throw new UnauthorizedError('Account is deactivated. Please contact support.');
    }

    const passwordMatch = await comparePassword(data.password, user.passwordHash);
    if (!passwordMatch) {
      throw new UnauthorizedError('Invalid credentials');
    }

    await authRepository.updateLastLogin(user.id);
    const tokens = await this.generateTokenPair(user.id, user.role, user.email);
    return { user: this.buildSafeUser(user), tokens };
  }

  /**
   * Generate and store an OTP for passwordless / OTP-based login.
   * Redis key format: `otp:{type}:{identifier}`
   */
  async sendLoginOTP(data: OTPInput): Promise<void> {
    const { identifier, type } = data;

    // Verify a user exists for this identifier
    const user =
      type === 'email'
        ? await authRepository.findByEmail(identifier)
        : await authRepository.findByPhone(identifier);

    if (!user) {
      throw new NotFoundError('User');
    }

    const otp = generateOTP();
    // storeOTP prepends 'otp:' → key becomes otp:{type}:{identifier}
    await storeOTP(`${type}:${identifier}`, otp);

    if (type === 'email') {
      // TODO: send OTP email via nodemailer/SES
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Login OTP for ${identifier}: ${otp}`);
      }
    } else {
      // TODO: send OTP SMS via Twilio
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Login OTP for ${identifier}: ${otp}`);
      }
    }
  }

  /**
   * Verify a login OTP and return an AuthResponse on success.
   */
  async verifyLoginOTP(data: OTPInput): Promise<AuthResponse> {
    const { identifier, type, otp } = data;

    if (!otp) {
      throw new BadRequestError('OTP is required');
    }

    const isValid = await verifyOTP(`${type}:${identifier}`, otp);
    if (!isValid) {
      throw new UnauthorizedError('Invalid or expired OTP');
    }

    const user =
      type === 'email'
        ? await authRepository.findByEmail(identifier)
        : await authRepository.findByPhone(identifier);

    if (!user) {
      throw new NotFoundError('User');
    }
    if (!user.isActive) {
      throw new UnauthorizedError('Account is deactivated');
    }

    await authRepository.updateLastLogin(user.id);
    const tokens = await this.generateTokenPair(user.id, user.role, user.email);
    return { user: this.buildSafeUser(user), tokens };
  }

  /**
   * Rotate a refresh token — verify, revoke old, issue new pair.
   */
  async refreshToken(refreshToken: string): Promise<TokenPair> {
    let payload: ReturnType<typeof verifyRefreshToken>;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      throw new UnauthorizedError('Invalid or expired refresh token');
    }

    if (payload.type !== 'refresh') {
      throw new UnauthorizedError('Invalid token type');
    }

    const stored = await authRepository.findRefreshToken(refreshToken);
    if (!stored) {
      throw new UnauthorizedError('Refresh token not found');
    }
    if (stored.revokedAt !== null) {
      throw new UnauthorizedError('Refresh token has been revoked');
    }
    if (stored.expiresAt < new Date()) {
      throw new UnauthorizedError('Refresh token has expired');
    }

    // Revoke the consumed token and issue a fresh pair
    await authRepository.revokeRefreshToken(refreshToken);
    return this.generateTokenPair(payload.sub, payload.role);
  }

  /**
   * Revoke a specific refresh token for a user.
   */
  async logout(userId: string, refreshToken: string): Promise<void> {
    const stored = await authRepository.findRefreshToken(refreshToken);
    if (stored && stored.userId === userId) {
      await authRepository.revokeRefreshToken(refreshToken);
    }
  }

  /**
   * Revoke all refresh tokens for a user (sign out everywhere).
   */
  async logoutAll(userId: string): Promise<void> {
    await authRepository.revokeAllRefreshTokens(userId);
  }

  /**
   * Initiate a password reset by sending an OTP.
   * Does not reveal whether the identifier belongs to a registered user.
   */
  async forgotPassword(data: ForgotPasswordInput): Promise<void> {
    const { identifier } = data;
    const user = await this.resolveUser(identifier);

    // Silently succeed when the user is not found to prevent enumeration
    if (!user) return;

    const otp = generateOTP();
    const ttl = env.OTP_EXPIRES_IN_MINUTES * 60;
    await redis.set(`reset:${identifier}`, otp, 'EX', ttl);

    const isEmail = identifier.includes('@');
    if (isEmail) {
      // TODO: send password-reset email via nodemailer/SES
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Password reset OTP for ${identifier}: ${otp}`);
      }
    } else {
      // TODO: send password-reset SMS via Twilio
      if (env.NODE_ENV === 'development') {
        console.log(`[DEV] Password reset OTP for ${identifier}: ${otp}`);
      }
    }
  }

  /**
   * Reset a user's password after verifying the OTP.
   */
  async resetPassword(data: ResetPasswordInput): Promise<void> {
    const { identifier, otp, newPassword } = data;

    const storedOtp = await redis.get(`reset:${identifier}`);
    if (!storedOtp || storedOtp !== otp) {
      throw new UnauthorizedError('Invalid or expired OTP');
    }

    const user = await this.resolveUser(identifier);
    if (!user) {
      throw new NotFoundError('User');
    }

    const passwordHash = await hashPassword(newPassword);
    await authRepository.updatePassword(user.id, passwordHash);
    await redis.del(`reset:${identifier}`);

    // Invalidate all sessions after a password reset
    await authRepository.revokeAllRefreshTokens(user.id);
  }

  /**
   * Change the password of an authenticated user.
   */
  async changePassword(userId: string, data: ChangePasswordInput): Promise<void> {
    const { currentPassword, newPassword } = data;

    const user = await authRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User');
    }
    if (!user.passwordHash) {
      throw new BadRequestError('No password is set for this account');
    }

    const isValid = await comparePassword(currentPassword, user.passwordHash);
    if (!isValid) {
      throw new UnauthorizedError('Current password is incorrect');
    }

    const passwordHash = await hashPassword(newPassword);
    await authRepository.updatePassword(userId, passwordHash);
  }

  /**
   * Verify a user's email address using the OTP stored at `verify:email:{userId}`.
   */
  async verifyEmail(userId: string, otp: string): Promise<void> {
    const key = `verify:email:${userId}`;
    const storedOtp = await redis.get(key);

    if (!storedOtp || storedOtp !== otp) {
      throw new BadRequestError('Invalid or expired verification OTP');
    }

    await authRepository.updateVerification(userId, 'email');
    await redis.del(key);
  }

  /**
   * Verify a user's phone number using the OTP stored at `verify:phone:{userId}`.
   */
  async verifyPhone(userId: string, otp: string): Promise<void> {
    const key = `verify:phone:${userId}`;
    const storedOtp = await redis.get(key);

    if (!storedOtp || storedOtp !== otp) {
      throw new BadRequestError('Invalid or expired verification OTP');
    }

    await authRepository.updateVerification(userId, 'phone');
    await redis.del(key);
  }

  /**
   * Authenticate via a social provider (Google / Apple).
   * TODO: integrate provider token verification libraries.
   */
  async socialLogin(data: SocialLoginInput): Promise<AuthResponse> {
    // TODO: verify token with the provider's SDK/API
    //   - Google: use google-auth-library to verify id_token
    //   - Apple: verify with Apple's public key
    // For now we throw to signal the feature is not yet configured.
    throw new BadRequestError(
      `Social login via ${data.provider} is not yet configured`,
    );
  }

  /**
   * Return the safe profile of the currently authenticated user.
   */
  async getMe(userId: string): Promise<SafeUser> {
    const user = await authRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User');
    }
    return this.buildSafeUser(user);
  }

  // ─────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────

  /**
   * Find a user by email or phone number.
   * Returns null when neither matches.
   */
  private async resolveUser(identifier: string): Promise<User | null> {
    const byEmail = await authRepository.findByEmail(identifier);
    if (byEmail) return byEmail;
    return authRepository.findByPhone(identifier);
  }

  /**
   * Create a signed access/refresh token pair and persist the refresh token.
   */
  private async generateTokenPair(
    userId: string,
    role: Role,
    email?: string | null,
  ): Promise<TokenPair> {
    const accessToken = generateAccessToken(userId, role, email);
    const refreshToken = generateRefreshToken(userId, role);
    const expiresAt = this.expiryStringToDate(env.JWT_REFRESH_EXPIRES_IN);
    const expiresIn = this.expiryStringToSeconds(env.JWT_ACCESS_EXPIRES_IN);

    await authRepository.createRefreshToken(userId, refreshToken, expiresAt);

    return { accessToken, refreshToken, expiresIn };
  }

  /**
   * Strip sensitive / relational fields and return a SafeUser.
   */
  private buildSafeUser(user: User): SafeUser {
    return {
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isActive: user.isActive,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      trustScore: user.trustScore,
      lastLoginAt: user.lastLoginAt,
      deletedAt: user.deletedAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  /** Convert a JWT expiry string (e.g. "7d", "15m") to a future Date. */
  private expiryStringToDate(expiry: string): Date {
    return new Date(Date.now() + this.expiryStringToMs(expiry));
  }

  /** Convert a JWT expiry string to seconds (used for expiresIn). */
  private expiryStringToSeconds(expiry: string): number {
    return Math.floor(this.expiryStringToMs(expiry) / 1000);
  }

  private expiryStringToMs(expiry: string): number {
    const match = expiry.match(/^(\d+)([smhd])$/);
    if (!match) return 15 * 60 * 1000; // default 15 min
    const value = parseInt(match[1], 10);
    const unit = match[2];
    const multipliers: Record<string, number> = {
      s: 1_000,
      m: 60_000,
      h: 3_600_000,
      d: 86_400_000,
    };
    return value * (multipliers[unit] ?? 1_000);
  }
}

export const authService = new AuthService();
