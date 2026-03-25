import { Address, Role, User } from '@prisma/client';
import { prisma } from '../../config/database';
import { AddressInput, UserListFilters } from './users.types';

/** User with all their addresses */
export type UserWithAddresses = User & { addresses: Address[] };

class UsersRepository {
  /**
   * Find a user by ID, including their addresses.
   */
  async findById(userId: string): Promise<UserWithAddresses | null> {
    return prisma.user.findUnique({
      where: { id: userId },
      include: { addresses: true },
    });
  }

  /**
   * Partially update a user record.
   */
  async updateUser(userId: string, data: object): Promise<User> {
    return prisma.user.update({ where: { id: userId }, data });
  }

  /**
   * Get all addresses for a user, ordered by isPrimary descending.
   */
  async getAddresses(userId: string): Promise<Address[]> {
    return prisma.address.findMany({
      where: { userId },
      orderBy: { isPrimary: 'desc' },
    });
  }

  /**
   * Find a specific address by its ID.
   */
  async findAddressById(addressId: string): Promise<Address | null> {
    return prisma.address.findUnique({ where: { id: addressId } });
  }

  /**
   * Create a new address for a user. If it is the user's first address, set isPrimary = true.
   */
  async createAddress(userId: string, data: AddressInput): Promise<Address> {
    const count = await this.countAddresses(userId);
    return prisma.address.create({
      data: {
        ...data,
        userId,
        isPrimary: count === 0,
      },
    });
  }

  /**
   * Update an address with partial data.
   */
  async updateAddress(addressId: string, data: Partial<AddressInput>): Promise<Address> {
    return prisma.address.update({ where: { id: addressId }, data });
  }

  /**
   * Delete an address by ID.
   */
  async deleteAddress(addressId: string): Promise<void> {
    await prisma.address.delete({ where: { id: addressId } });
  }

  /**
   * Set isPrimary = false for all addresses of a user.
   */
  async unsetPrimaryAddresses(userId: string): Promise<void> {
    await prisma.address.updateMany({
      where: { userId },
      data: { isPrimary: false },
    });
  }

  /**
   * Set isPrimary = true for a specific address.
   */
  async setPrimaryAddress(addressId: string): Promise<Address> {
    return prisma.address.update({ where: { id: addressId }, data: { isPrimary: true } });
  }

  /**
   * Count the number of addresses for a user.
   */
  async countAddresses(userId: string): Promise<number> {
    return prisma.address.count({ where: { userId } });
  }

  /**
   * Soft-delete a user by setting deletedAt and isActive = false.
   */
  async softDeleteUser(userId: string): Promise<User> {
    return prisma.user.update({
      where: { id: userId },
      data: { deletedAt: new Date(), isActive: false },
    });
  }

  /**
   * List users with optional filters, search, and pagination.
   */
  async listUsers(
    filters: UserListFilters,
  ): Promise<{ users: UserWithAddresses[]; total: number }> {
    const { search, role, isActive, page = 1, perPage = 20 } = filters;

    const where: {
      deletedAt: null;
      role?: Role;
      isActive?: boolean;
      OR?: Array<{
        firstName?: { contains: string; mode: 'insensitive' };
        lastName?: { contains: string; mode: 'insensitive' };
        email?: { contains: string; mode: 'insensitive' };
      }>;
    } = { deletedAt: null };

    if (role !== undefined) where.role = role;
    if (isActive !== undefined) where.isActive = isActive;

    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [users, total] = await prisma.$transaction([
      prisma.user.findMany({
        where,
        include: { addresses: true },
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count({ where }),
    ]);

    return { users, total };
  }

  /**
   * Admin version: find a user by ID, including addresses.
   */
  async findUserById(userId: string): Promise<UserWithAddresses | null> {
    return prisma.user.findUnique({
      where: { id: userId },
      include: { addresses: true },
    });
  }
}

export const usersRepository = new UsersRepository();
