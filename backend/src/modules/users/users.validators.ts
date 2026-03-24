import { z } from 'zod';
import { Gender, Role } from '@prisma/client';

export const updateProfileSchema = z.object({
  firstName: z.string().min(2, 'First name must be at least 2 characters').optional(),
  lastName: z.string().min(2, 'Last name must be at least 2 characters').optional(),
  bio: z.string().max(500, 'Bio must not exceed 500 characters').optional(),
  dateOfBirth: z.string().optional(),
  gender: z.nativeEnum(Gender).optional(),
});

export const addressSchema = z.object({
  label: z.string().min(1, 'Label is required'),
  addressLine1: z.string().min(1, 'Address line 1 is required'),
  addressLine2: z.string().optional(),
  city: z.string().min(1, 'City is required'),
  state: z.string().min(1, 'State is required'),
  country: z.string().min(1, 'Country is required'),
  postalCode: z.string().min(1, 'Postal code is required'),
  lat: z.number().optional(),
  lng: z.number().optional(),
});

export const updateAddressSchema = addressSchema.partial();

export const listUsersQuerySchema = z.object({
  search: z.string().optional(),
  role: z.nativeEnum(Role).optional(),
  isActive: z.coerce.boolean().optional(),
  page: z.coerce.number().int().min(1).default(1).optional(),
  perPage: z.coerce.number().int().min(1).max(100).default(20).optional(),
});

export const updateUserStatusSchema = z.object({
  isActive: z.boolean(),
});

export const changeRoleSchema = z.object({
  role: z.nativeEnum(Role),
});
