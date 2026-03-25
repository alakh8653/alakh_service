import { Gender, Role } from '@prisma/client';

/** Input for updating a user's own profile */
export interface UpdateProfileInput {
  firstName?: string;
  lastName?: string;
  bio?: string;
  dateOfBirth?: Date;
  gender?: Gender;
}

/** Input for creating a new address */
export interface AddressInput {
  label: string;
  addressLine1: string;
  addressLine2?: string;
  city: string;
  state: string;
  country: string;
  postalCode: string;
  lat?: number;
  lng?: number;
}

/** Input for partially updating an address */
export type UpdateAddressInput = Partial<AddressInput>;

/** Profile completion breakdown */
export interface ProfileCompletion {
  percentage: number;
  completedSteps: string[];
  missingSteps: string[];
}

/** Summary of user activity */
export interface UserActivity {
  bookingsCount: number;
  reviewsCount: number;
  memberSince: Date;
  lastActive: Date | null;
}

/** Filters for admin user listing */
export interface UserListFilters {
  search?: string;
  role?: Role;
  isActive?: boolean;
  page?: number;
  perPage?: number;
}

/** Admin input for updating any user */
export interface AdminUpdateUserInput {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  isActive?: boolean;
  role?: Role;
}
