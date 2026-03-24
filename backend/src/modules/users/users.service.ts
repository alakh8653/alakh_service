import { Address } from '@prisma/client';
import { prisma } from '../../config/database';
import { BadRequestError, NotFoundError } from '../../shared/errors';
import { PaginationMeta } from '../../shared/types';
import {
  AddressInput,
  AdminUpdateUserInput,
  ProfileCompletion,
  UpdateAddressInput,
  UpdateProfileInput,
  UserActivity,
  UserListFilters,
} from './users.types';
import { usersRepository } from './users.repository';

/** User fields safe to return to clients */
type SafeUser = Omit<
  Awaited<ReturnType<typeof usersRepository.findById>>,
  'passwordHash'
> & { addresses?: Address[] };

class UsersService {
  // ─── Profile ───────────────────────────────────────────────────────────────

  /** Get a user's profile (excluding passwordHash) with addresses. */
  async getProfile(userId: string) {
    const user = await usersRepository.findById(userId);
    if (!user) throw new NotFoundError('User');
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /** Update a user's own profile fields. */
  async updateProfile(userId: string, data: UpdateProfileInput) {
    const update: Record<string, unknown> = { ...data };
    if (typeof data.dateOfBirth === 'string') {
      update.dateOfBirth = new Date(data.dateOfBirth as unknown as string);
    }
    const user = await usersRepository.updateUser(userId, update);
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /**
   * Upload avatar. TODO: integrate S3.
   * For now, stores the local file path as avatarUrl.
   */
  async uploadAvatar(userId: string, file: Express.Multer.File) {
    const avatarUrl = file.filename ?? file.originalname;
    const user = await usersRepository.updateUser(userId, { avatarUrl });
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /**
   * Remove avatar. TODO: delete from S3.
   * Clears avatarUrl in DB.
   */
  async removeAvatar(userId: string) {
    const user = await usersRepository.updateUser(userId, { avatarUrl: null });
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  // ─── Addresses ─────────────────────────────────────────────────────────────

  /** Get all addresses for a user. */
  async getAddresses(userId: string): Promise<Address[]> {
    return usersRepository.getAddresses(userId);
  }

  /** Add a new address for a user. */
  async addAddress(userId: string, data: AddressInput): Promise<Address> {
    return usersRepository.createAddress(userId, data);
  }

  /** Update an address, verifying it belongs to the user. */
  async updateAddress(
    userId: string,
    addressId: string,
    data: UpdateAddressInput,
  ): Promise<Address> {
    const address = await usersRepository.findAddressById(addressId);
    if (!address || address.userId !== userId) throw new NotFoundError('Address');
    return usersRepository.updateAddress(addressId, data);
  }

  /** Delete an address, verifying ownership and that at least 1 remains. */
  async deleteAddress(userId: string, addressId: string): Promise<void> {
    const address = await usersRepository.findAddressById(addressId);
    if (!address || address.userId !== userId) throw new NotFoundError('Address');
    const count = await usersRepository.countAddresses(userId);
    if (count <= 1) throw new BadRequestError('Cannot delete your only address');
    await usersRepository.deleteAddress(addressId);
  }

  /** Set an address as primary, verifying ownership. */
  async setPrimaryAddress(userId: string, addressId: string): Promise<Address> {
    const address = await usersRepository.findAddressById(addressId);
    if (!address || address.userId !== userId) throw new NotFoundError('Address');
    await usersRepository.unsetPrimaryAddresses(userId);
    return usersRepository.setPrimaryAddress(addressId);
  }

  // ─── Completion & Activity ─────────────────────────────────────────────────

  /**
   * Calculate profile completion percentage and steps.
   * Weights: firstName 10%, lastName 10%, avatarUrl 15%,
   * email+emailVerified 15%, phone+phoneVerified 15%,
   * dateOfBirth 10%, bio 10%, address 15%
   */
  async getProfileCompletion(userId: string): Promise<ProfileCompletion> {
    const user = await usersRepository.findById(userId);
    if (!user) throw new NotFoundError('User');

    const steps: Array<{ key: string; weight: number; done: boolean }> = [
      { key: 'firstName', weight: 10, done: !!user.firstName },
      { key: 'lastName', weight: 10, done: !!user.lastName },
      { key: 'avatarUrl', weight: 15, done: !!user.avatarUrl },
      { key: 'email', weight: 15, done: !!(user.email && user.isEmailVerified) },
      { key: 'phone', weight: 15, done: !!(user.phone && user.isPhoneVerified) },
      { key: 'dateOfBirth', weight: 10, done: !!user.dateOfBirth },
      { key: 'bio', weight: 10, done: !!user.bio },
      { key: 'address', weight: 15, done: user.addresses.length > 0 },
    ];

    const completedSteps = steps.filter((s) => s.done).map((s) => s.key);
    const missingSteps = steps.filter((s) => !s.done).map((s) => s.key);
    const percentage = steps.filter((s) => s.done).reduce((sum, s) => sum + s.weight, 0);

    return { percentage, completedSteps, missingSteps };
  }

  /**
   * Soft-delete the account and revoke all refresh tokens.
   */
  async requestAccountDeletion(userId: string): Promise<void> {
    await usersRepository.softDeleteUser(userId);
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /** Return a summary of user activity. Booking/review counts are placeholders. */
  async getActivitySummary(userId: string): Promise<UserActivity> {
    const user = await usersRepository.findById(userId);
    if (!user) throw new NotFoundError('User');
    return {
      bookingsCount: 0,
      reviewsCount: 0,
      memberSince: user.createdAt,
      lastActive: user.lastLoginAt,
    };
  }

  // ─── Admin ─────────────────────────────────────────────────────────────────

  /** List users with filters and pagination meta. */
  async listUsers(
    filters: UserListFilters,
  ): Promise<{ users: SafeUser[]; meta: PaginationMeta }> {
    const page = filters.page ?? 1;
    const perPage = filters.perPage ?? 20;
    const { users, total } = await usersRepository.listUsers(filters);
    const safeUsers = users.map(({ passwordHash: _pw, ...u }) => u);
    const totalPages = Math.ceil(total / perPage);
    const meta: PaginationMeta = {
      page,
      limit: perPage,
      total,
      totalPages,
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1,
    };
    return { users: safeUsers, meta };
  }

  /** Get a user by ID or throw NotFoundError. */
  async getUserById(userId: string) {
    const user = await usersRepository.findUserById(userId);
    if (!user) throw new NotFoundError('User');
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /** Admin update of arbitrary user fields. */
  async updateUser(userId: string, data: AdminUpdateUserInput) {
    const user = await usersRepository.updateUser(userId, data);
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /** Toggle a user's isActive status. */
  async toggleUserStatus(userId: string, isActive: boolean) {
    const user = await usersRepository.updateUser(userId, { isActive });
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }

  /** Change a user's role. */
  async changeUserRole(userId: string, role: string) {
    const user = await usersRepository.updateUser(userId, { role });
    const { passwordHash: _pw, ...safe } = user;
    return safe;
  }
}

export const usersService = new UsersService();
