import { BookingStatus, PaymentStatus } from '@prisma/client';

export interface CreateBookingInput {
  shopId: string;
  serviceId: string;
  staffId?: string;
  scheduledDate: string;
  scheduledTime: string;
  notes?: string;
}

export interface BookingFilters {
  status?: BookingStatus;
  startDate?: string;
  endDate?: string;
  search?: string;
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface BookingCalendarView {
  view: 'day' | 'week' | 'month';
  startDate: string;
  endDate: string;
  days: Array<{
    date: string;
    bookings: BookingWithDetails[];
  }>;
}

export interface BookingStats {
  totalBookings: number;
  completedBookings: number;
  cancelledBookings: number;
  noShowBookings: number;
  completionRate: number;
  cancellationRate: number;
  revenue: number;
  avgBookingsPerDay: number;
  periodStart: string;
  periodEnd: string;
}

export interface AvailabilitySlot {
  time: string;
  available: boolean;
  remainingCapacity?: number;
}

export interface BookingReceipt {
  bookingId: string;
  bookingDate: Date;
  service: {
    name: string;
    duration: number;
    price: number;
  };
  shop: {
    name: string;
    address: string;
    phone?: string;
  };
  customer: {
    name: string;
    email?: string;
    phone?: string;
  };
  staff?: {
    name: string;
  };
  scheduledDate: Date;
  scheduledTime: string;
  totalAmount: number;
  paymentStatus: PaymentStatus;
  status: BookingStatus;
}

export interface BookingWithDetails {
  id: string;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  scheduledDate: Date;
  scheduledTime: string;
  totalPrice: number;
  notes?: string | null;
  createdAt: Date;
  customer?: {
    id: string;
    name: string;
    email?: string | null;
    phone?: string | null;
  };
  shop: {
    id: string;
    name: string;
    address: string;
  };
  service: {
    id: string;
    name: string;
    duration: number;
    price: number;
  };
  staff?: {
    id: string;
    name: string;
  } | null;
}
