import { DispatchStatus } from '@prisma/client';

export interface CreateDispatchInput {
  bookingId: string;
  staffId: string;
  destinationLatitude?: number;
  destinationLongitude?: number;
}

export interface UpdateDispatchLocationInput {
  latitude: number;
  longitude: number;
  heading?: number;
  speed?: number;
  accuracy?: number;
}

export interface DispatchFilters {
  status?: DispatchStatus;
  startDate?: string;
  endDate?: string;
  staffId?: string;
  page?: number;
  perPage?: number;
}

export interface NearestStaffResult {
  staffId: string;
  name: string;
  distanceKm: number;
  latitude: number;
  longitude: number;
}

export interface DispatchStats {
  totalDispatches: number;
  completedDispatches: number;
  cancelledDispatches: number;
  rejectedDispatches: number;
  avgDurationMinutes: number;
  completionRate: number;
  periodStart: string;
  periodEnd: string;
}

export interface DispatchWithDetails {
  id: string;
  status: DispatchStatus;
  assignedAt: Date;
  acceptedAt?: Date | null;
  startedAt?: Date | null;
  arrivedAt?: Date | null;
  completedAt?: Date | null;
  staffLatitude?: number | null;
  staffLongitude?: number | null;
  destinationLatitude?: number | null;
  destinationLongitude?: number | null;
  estimatedArrival?: Date | null;
  actualDuration?: number | null;
  booking: {
    id: string;
    scheduledDate: Date;
    scheduledTime: string;
  };
  staff: {
    id: string;
    name: string;
    phone?: string | null;
  };
  customer: {
    id: string;
    name: string;
    phone?: string | null;
  };
  shop: {
    id: string;
    name: string;
    address: string;
  };
}
