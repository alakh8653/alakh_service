import { Prisma, RefreshToken, Role, User } from '@prisma/client';
import { prisma } from '../../config/database';

/** Data required to create a new user */
export interface CreateUserData {
  firstName: string;
  lastName: string;
  email?: string;
  phone?: string;
  passwordHash: string;
  role: Role;
}

/** User record joined with its refresh tokens */
export type UserWithRefreshTokens = User & { refreshTokens: RefreshToken[] };

class AuthRepository {
  /**
   * Create a new user record.
   */
  async createUser(data: CreateUserData): Promise<User> {
    return prisma.user.create({ data });
  }

  /**
   * Find a user by email address, including their refresh tokens.
   */
  async findByEmail(email: string): Promise<UserWithRefreshTokens | null> {
    return prisma.user.findUnique({
      where: { email },
      include: { refreshTokens: true },
    });
  }

  /**
   * Find a user by phone number.
   */
  async findByPhone(phone: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { phone } });
  }

  /**
   * Find a user by primary key.
   */
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  /**
   * Update a user's password hash.
   */
  async updatePassword(userId: string, passwordHash: string): Promise<User> {
    return prisma.user.update({ where: { id: userId }, data: { passwordHash } });
  }

  /**
   * Update arbitrary user fields.
   */
  async updateUser(userId: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id: userId }, data });
  }

  /**
   * Mark the user's email or phone as verified.
   */
  async updateVerification(userId: string, type: 'email' | 'phone'): Promise<User> {
    const data =
      type === 'email' ? { isEmailVerified: true } : { isPhoneVerified: true };
    return prisma.user.update({ where: { id: userId }, data });
  }

  /**
   * Set lastLoginAt to the current timestamp.
   */
  async updateLastLogin(userId: string): Promise<User> {
    return prisma.user.update({
      where: { id: userId },
      data: { lastLoginAt: new Date() },
    });
  }

  /**
   * Persist a new refresh token for the given user.
   */
  async createRefreshToken(
    userId: string,
    token: string,
    expiresAt: Date,
  ): Promise<RefreshToken> {
    return prisma.refreshToken.create({ data: { userId, token, expiresAt } });
  }

  /**
   * Find an active (non-revoked, non-expired) refresh token by its value.
   */
  async findRefreshToken(token: string): Promise<RefreshToken | null> {
    return prisma.refreshToken.findUnique({ where: { token } });
  }

  /**
   * Set revokedAt on a single refresh token.
   */
  async revokeRefreshToken(token: string): Promise<RefreshToken> {
    return prisma.refreshToken.update({
      where: { token },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Revoke every active refresh token belonging to a user.
   */
  async revokeAllRefreshTokens(userId: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Soft-delete a user by setting deletedAt.
   */
  async softDeleteUser(userId: string): Promise<User> {
    return prisma.user.update({
      where: { id: userId },
      data: { deletedAt: new Date() },
    });
  }
}

export const authRepository = new AuthRepository();
