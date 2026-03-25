import { DispatchStatus } from '@prisma/client';
import { dispatchRepository } from './dispatch.repository';
import {
  CreateDispatchInput,
  UpdateDispatchLocationInput,
  DispatchFilters,
  DispatchStats,
  NearestStaffResult,
} from './dispatch.types';
import { buildPaginatedResponse, getPaginationParams } from '../../shared/utils/pagination';
import {
  BadRequestError,
  NotFoundError,
  ForbiddenError,
  ConflictError,
} from '../../shared/errors/AppError';
import { prisma } from '../../config/database';

/**
 * Calculate the Haversine distance between two geographic coordinates.
 * Returns distance in kilometres.
 */
function haversineDistanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

/** Rough ETA in minutes based on distance and average urban speed (30 km/h). */
function estimateEtaMinutes(distanceKm: number, avgSpeedKmh = 30): number {
  return Math.ceil((distanceKm / avgSpeedKmh) * 60);
}

/**
 * Dispatch service — encapsulates all business logic for the dispatch module.
 */
export const dispatchService = {
  /**
   * Create a dispatch assignment for a booking.
   * Validates booking ownership, staff availability, and prevents double dispatch.
   */
  async createDispatch(shopId: string, ownerId: string, data: CreateDispatchInput) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const booking = await prisma.booking.findFirst({
      where: { id: data.bookingId, shopId },
    });
    if (!booking) throw new NotFoundError('Booking not found in this shop');

    // Prevent double dispatch
    const existing = await dispatchRepository.findByBookingId(data.bookingId);
    if (existing && existing.status !== DispatchStatus.CANCELLED) {
      throw new ConflictError('A dispatch already exists for this booking');
    }

    const staff = await prisma.user.findFirst({
      where: { id: data.staffId, isActive: true },
    });
    if (!staff) throw new NotFoundError('Staff member not found');

    const dispatch = await dispatchRepository.create({
      booking: { connect: { id: data.bookingId } },
      staff: { connect: { id: data.staffId } },
      customer: { connect: { id: booking.customerId } },
      shop: { connect: { id: shopId } },
      status: DispatchStatus.PENDING,
      destinationLatitude: data.destinationLatitude,
      destinationLongitude: data.destinationLongitude,
    });

    // TODO: Send push notification to staff member about new assignment
    // TODO: Schedule Bull job for auto-reject if no response within X minutes
    // TODO: Emit dispatch.created WebSocket event

    return dispatch;
  },

  /** Get a dispatch by ID (validates user access). */
  async getDispatchById(dispatchId: string, userId: string, role?: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAdmin = role === 'ADMIN';
    const isCustomer = dispatch.customerId === userId;
    const isStaff = dispatch.staffId === userId;
    const isShopOwner = await prisma.shop.findFirst({
      where: { id: dispatch.shopId, ownerId: userId },
    });

    if (!isAdmin && !isCustomer && !isStaff && !isShopOwner) {
      throw new ForbiddenError('You do not have access to this dispatch');
    }

    return dispatch;
  },

  /** Staff accepts a pending dispatch. */
  async acceptDispatch(dispatchId: string, staffId: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.PENDING) {
      throw new BadRequestError(`Cannot accept dispatch with status: ${dispatch.status}`);
    }

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.ACCEPTED, {
      acceptedAt: new Date(),
    });

    // TODO: Notify customer that staff has accepted
    // TODO: Cancel Bull auto-reject job
    // TODO: Emit dispatch.accepted WebSocket event

    return updated;
  },

  /** Staff rejects a pending dispatch. */
  async rejectDispatch(dispatchId: string, staffId: string, reason?: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.PENDING) {
      throw new BadRequestError(`Cannot reject dispatch with status: ${dispatch.status}`);
    }

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.REJECTED, {
      rejectionReason: reason,
    });

    // TODO: Notify shop owner of rejection so they can reassign
    // TODO: Emit dispatch.rejected WebSocket event
    // TODO: Auto-reassign to next available staff

    return updated;
  },

  /** Staff marks as en route (ACCEPTED → EN_ROUTE). */
  async markEnRoute(dispatchId: string, staffId: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.ACCEPTED) {
      throw new BadRequestError(`Cannot go en-route from status: ${dispatch.status}`);
    }

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.EN_ROUTE, {
      startedAt: new Date(),
    });

    // TODO: Emit dispatch.en_route WebSocket event to customer
    return updated;
  },

  /** Staff marks as arrived at customer location (EN_ROUTE → ARRIVED). */
  async markArrived(dispatchId: string, staffId: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.EN_ROUTE) {
      throw new BadRequestError(`Cannot mark arrived from status: ${dispatch.status}`);
    }

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.ARRIVED, {
      arrivedAt: new Date(),
    });

    // TODO: Emit dispatch.arrived WebSocket event to customer
    return updated;
  },

  /** Staff starts the service (ARRIVED → IN_PROGRESS). */
  async startService(dispatchId: string, staffId: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.ARRIVED) {
      throw new BadRequestError(`Cannot start service from status: ${dispatch.status}`);
    }

    return dispatchRepository.updateStatus(dispatchId, DispatchStatus.IN_PROGRESS);
  },

  /** Staff completes the dispatch (IN_PROGRESS → COMPLETED). */
  async completeDispatch(dispatchId: string, staffId: string) {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');
    if (dispatch.status !== DispatchStatus.IN_PROGRESS) {
      throw new BadRequestError(`Cannot complete dispatch from status: ${dispatch.status}`);
    }

    const now = new Date();
    const startedAt = dispatch.startedAt ?? dispatch.assignedAt;
    const durationMinutes = Math.round((now.getTime() - startedAt.getTime()) / 60000);

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.COMPLETED, {
      completedAt: now,
      actualDuration: durationMinutes,
    });

    // TODO: Trigger payment capture
    // TODO: Emit dispatch.completed WebSocket event
    return updated;
  },

  /** Cancel a dispatch (shop owner or admin). */
  async cancelDispatch(
    dispatchId: string,
    shopId: string,
    ownerId: string,
    reason?: string,
  ) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.shopId !== shopId) throw new ForbiddenError('Access denied');

    const nonCancellable: DispatchStatus[] = [
      DispatchStatus.COMPLETED,
      DispatchStatus.CANCELLED,
    ];
    if (nonCancellable.includes(dispatch.status)) {
      throw new BadRequestError(`Cannot cancel dispatch with status: ${dispatch.status}`);
    }

    const updated = await dispatchRepository.updateStatus(dispatchId, DispatchStatus.CANCELLED, {
      cancellationReason: reason,
      cancelledAt: new Date(),
    });

    // TODO: Notify staff and customer of cancellation
    return updated;
  },

  /** Reassign a dispatch to a different staff member. */
  async reassignDispatch(
    dispatchId: string,
    shopId: string,
    ownerId: string,
    newStaffId: string,
  ) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.shopId !== shopId) throw new ForbiddenError('Access denied');

    const reassignable: DispatchStatus[] = [
      DispatchStatus.PENDING,
      DispatchStatus.REJECTED,
    ];
    if (!reassignable.includes(dispatch.status)) {
      throw new BadRequestError(`Cannot reassign dispatch with status: ${dispatch.status}`);
    }

    const staff = await prisma.user.findFirst({ where: { id: newStaffId, isActive: true } });
    if (!staff) throw new NotFoundError('Staff member not found');

    const updated = await dispatchRepository.update(dispatchId, {
      staff: { connect: { id: newStaffId } },
      status: DispatchStatus.PENDING,
      rejectionReason: null,
    });

    // TODO: Send notification to new staff member
    return updated;
  },

  /** Get dispatches for a shop (shop owner). */
  async getShopDispatches(shopId: string, ownerId: string, filters: DispatchFilters) {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await dispatchRepository.findByShop(shopId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Get dispatches assigned to a staff member. */
  async getStaffDispatches(staffId: string, filters: DispatchFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await dispatchRepository.findByStaff(staffId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Get dispatches for a customer. */
  async getCustomerDispatches(customerId: string, filters: DispatchFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await dispatchRepository.findByCustomer(customerId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /** Get dispatch statistics for a shop. */
  async getDispatchStats(shopId: string, ownerId: string, period = '30d'): Promise<DispatchStats> {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    const days = parseInt(period) || 30;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const { counts, avgDurationMinutes } = await dispatchRepository.getStats(
      shopId,
      startDate,
      endDate,
    );

    const total = Object.values(counts).reduce((a, b) => a + b, 0);
    const completed = counts[DispatchStatus.COMPLETED] ?? 0;
    const cancelled = counts[DispatchStatus.CANCELLED] ?? 0;
    const rejected = counts[DispatchStatus.REJECTED] ?? 0;

    return {
      totalDispatches: total,
      completedDispatches: completed,
      cancelledDispatches: cancelled,
      rejectedDispatches: rejected,
      avgDurationMinutes,
      completionRate: total > 0 ? (completed / total) * 100 : 0,
      periodStart: startDate.toISOString(),
      periodEnd: endDate.toISOString(),
    };
  },

  /**
   * Find the nearest available staff members to a given location.
   * Uses Haversine formula for distance calculation.
   * TODO: Replace with PostGIS ST_Distance for production accuracy.
   */
  async findNearestStaff(
    shopId: string,
    ownerId: string,
    latitude: number,
    longitude: number,
    radiusKm = 10,
  ): Promise<NearestStaffResult[]> {
    const shop = await prisma.shop.findFirst({ where: { id: shopId, ownerId } });
    if (!shop) throw new ForbiddenError('Access denied');

    // Get staff with active (non-terminal) dispatches to find their last known position
    const activeDispatches = await prisma.dispatch.findMany({
      where: {
        shopId,
        status: { in: [DispatchStatus.ACCEPTED, DispatchStatus.EN_ROUTE] },
        staffLatitude: { not: null },
        staffLongitude: { not: null },
      },
      select: {
        staffId: true,
        staffLatitude: true,
        staffLongitude: true,
        staff: { select: { id: true, name: true } },
      },
    });

    const results: NearestStaffResult[] = activeDispatches
      .filter((d) => d.staffLatitude !== null && d.staffLongitude !== null)
      .map((d) => {
        const distanceKm = haversineDistanceKm(
          latitude,
          longitude,
          d.staffLatitude!,
          d.staffLongitude!,
        );
        return {
          staffId: d.staffId,
          name: d.staff.name,
          distanceKm,
          latitude: d.staffLatitude!,
          longitude: d.staffLongitude!,
        };
      })
      .filter((r) => r.distanceKm <= radiusKm)
      .sort((a, b) => a.distanceKm - b.distanceKm);

    return results;
  },

  /**
   * Calculate the estimated time of arrival for a dispatch.
   * TODO: Integrate Google Maps Directions API for real-world routing.
   */
  async calculateEta(dispatchId: string, userId: string): Promise<{ etaMinutes: number; distanceKm: number }> {
    const dispatch = await dispatchRepository.findById(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAuthorized =
      dispatch.staffId === userId ||
      dispatch.customerId === userId ||
      (await prisma.shop.findFirst({ where: { id: dispatch.shopId, ownerId: userId } }));

    if (!isAuthorized) throw new ForbiddenError('Access denied');

    if (
      !dispatch.staffLatitude ||
      !dispatch.staffLongitude ||
      !dispatch.destinationLatitude ||
      !dispatch.destinationLongitude
    ) {
      throw new BadRequestError('Location data not available for ETA calculation');
    }

    const distanceKm = haversineDistanceKm(
      dispatch.staffLatitude,
      dispatch.staffLongitude,
      dispatch.destinationLatitude,
      dispatch.destinationLongitude,
    );

    const etaMinutes = estimateEtaMinutes(distanceKm);

    // Update estimatedArrival on the dispatch
    await dispatchRepository.update(dispatchId, {
      estimatedArrival: new Date(Date.now() + etaMinutes * 60 * 1000),
    });

    return { etaMinutes, distanceKm };
  },

  // ─── Admin Methods ─────────────────────────────────────────────────────

  /** List all dispatches platform-wide (admin). */
  async listAllDispatches(filters: DispatchFilters & { shopId?: string }) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await dispatchRepository.findAll(filters);
    return buildPaginatedResponse(items, total, pagination);
  },
};
