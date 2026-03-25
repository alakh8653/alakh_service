import { trackingRepository } from './tracking.repository';
import {
  UpdateLocationInput,
  LiveLocation,
  TrackingSession,
  LocationHistoryFilters,
} from './tracking.types';
import { buildPaginatedResponse, getPaginationParams } from '../../shared/utils/pagination';
import { BadRequestError, ForbiddenError, NotFoundError } from '../../shared/errors/AppError';
import { prisma } from '../../config/database';

/**
 * Redis key prefix for live location cache.
 * Key pattern: tracking:location:{dispatchId}
 */
const LOCATION_CACHE_PREFIX = 'tracking:location:';
const LOCATION_CACHE_TTL_SECONDS = 30;

/**
 * Tracking service — manages real-time location updates, Redis caching, and WebSocket emission.
 *
 * Dependencies:
 *   - Redis client (ioredis) for caching live locations
 *   - Socket.IO server for broadcasting location updates to connected clients
 *
 * Both are injected at startup via module-level setters to avoid circular imports.
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let redisClient: any = null;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
let socketIoServer: any = null;

/** Inject the Redis client at application startup. */
export function setRedisClient(client: unknown): void {
  redisClient = client;
}

/** Inject the Socket.IO server at application startup. */
export function setSocketIoServer(io: unknown): void {
  socketIoServer = io;
}

export const trackingService = {
  /**
   * Update the live location for a staff member on an active dispatch.
   * Persists to DB, caches in Redis, and broadcasts via WebSocket.
   */
  async updateLocation(dispatchId: string, staffId: string, data: UpdateLocationInput) {
    const dispatch = await trackingRepository.findDispatch(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');
    if (dispatch.staffId !== staffId) throw new ForbiddenError('Access denied');

    const trackableStatuses = ['ACCEPTED', 'EN_ROUTE', 'ARRIVED', 'IN_PROGRESS'];
    if (!trackableStatuses.includes(dispatch.status)) {
      throw new BadRequestError(`Cannot update location for dispatch with status: ${dispatch.status}`);
    }

    // Persist to location_history table
    const entry = await trackingRepository.addLocation({ dispatchId, ...data });

    // Update staff position on the dispatch record
    await trackingRepository.updateDispatchLocation(dispatchId, data.latitude, data.longitude);

    const liveLocation: LiveLocation = {
      dispatchId,
      latitude: data.latitude,
      longitude: data.longitude,
      heading: data.heading,
      speed: data.speed,
      accuracy: data.accuracy,
      recordedAt: entry.recordedAt,
      staffId: dispatch.staffId,
      staffName: dispatch.staff.name,
    };

    // Cache the latest location in Redis (TTL = 30 s)
    if (redisClient) {
      try {
        await redisClient.setex(
          `${LOCATION_CACHE_PREFIX}${dispatchId}`,
          LOCATION_CACHE_TTL_SECONDS,
          JSON.stringify(liveLocation),
        );
      } catch {
        // Non-fatal: cache failure should not block the request
      }
    }

    // Broadcast via WebSocket to rooms: dispatch:{id}, customer:{customerId}
    if (socketIoServer) {
      socketIoServer.to(`dispatch:${dispatchId}`).emit('location:update', liveLocation);
      socketIoServer.to(`customer:${dispatch.customerId}`).emit('location:update', liveLocation);
    }

    return liveLocation;
  },

  /**
   * Get the live location for a dispatch.
   * Returns cached Redis value if available, otherwise queries the DB.
   */
  async getLiveLocation(dispatchId: string, userId: string): Promise<LiveLocation | null> {
    const dispatch = await trackingRepository.findDispatch(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAuthorized =
      dispatch.staffId === userId ||
      dispatch.customerId === userId ||
      (await prisma.shop.findFirst({ where: { id: dispatch.shopId, ownerId: userId } }));

    if (!isAuthorized) throw new ForbiddenError('Access denied');

    // Try Redis cache first
    if (redisClient) {
      try {
        const cached = await redisClient.get(`${LOCATION_CACHE_PREFIX}${dispatchId}`);
        if (cached) return JSON.parse(cached) as LiveLocation;
      } catch {
        // Cache miss — fall through to DB
      }
    }

    // Fall back to latest DB entry
    const latest = await trackingRepository.getLatestLocation(dispatchId);
    if (!latest) return null;

    return {
      dispatchId,
      latitude: latest.latitude,
      longitude: latest.longitude,
      heading: latest.heading ?? undefined,
      speed: latest.speed ?? undefined,
      accuracy: latest.accuracy ?? undefined,
      recordedAt: latest.recordedAt,
      staffId: dispatch.staffId,
      staffName: dispatch.staff.name,
    };
  },

  /** Get a tracking session overview for a dispatch. */
  async getTrackingSession(dispatchId: string, userId: string): Promise<TrackingSession> {
    const dispatch = await trackingRepository.findDispatch(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAuthorized =
      dispatch.staffId === userId ||
      dispatch.customerId === userId ||
      (await prisma.shop.findFirst({ where: { id: dispatch.shopId, ownerId: userId } }));

    if (!isAuthorized) throw new ForbiddenError('Access denied');

    const currentLocation = await this.getLiveLocation(dispatchId, userId).catch(() => null);

    return {
      dispatchId: dispatch.id,
      staffId: dispatch.staffId,
      customerId: dispatch.customerId,
      status: dispatch.status,
      currentLocation: currentLocation ?? undefined,
      destinationLatitude: dispatch.destinationLatitude,
      destinationLongitude: dispatch.destinationLongitude,
      estimatedArrival: dispatch.estimatedArrival,
    };
  },

  /** Get paginated location history for a dispatch. */
  async getLocationHistory(
    dispatchId: string,
    userId: string,
    filters: LocationHistoryFilters,
  ) {
    const dispatch = await trackingRepository.findDispatch(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAuthorized =
      dispatch.staffId === userId ||
      dispatch.customerId === userId ||
      (await prisma.shop.findFirst({ where: { id: dispatch.shopId, ownerId: userId } }));

    if (!isAuthorized) throw new ForbiddenError('Access denied');

    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });
    const { items, total } = await trackingRepository.getHistory(dispatchId, filters);
    return buildPaginatedResponse(items, total, pagination);
  },

  /**
   * Subscribe a socket connection to a dispatch tracking room.
   * Called from the WebSocket connection handler.
   * TODO: Validate the socket user's JWT before joining the room.
   */
  async subscribeToDispatch(socketId: string, dispatchId: string, userId: string): Promise<void> {
    const dispatch = await trackingRepository.findDispatch(dispatchId);
    if (!dispatch) throw new NotFoundError('Dispatch not found');

    const isAuthorized =
      dispatch.staffId === userId ||
      dispatch.customerId === userId ||
      (await prisma.shop.findFirst({ where: { id: dispatch.shopId, ownerId: userId } }));

    if (!isAuthorized) throw new ForbiddenError('Access denied');

    if (socketIoServer) {
      const socket = socketIoServer.sockets.sockets.get(socketId);
      if (socket) {
        await socket.join(`dispatch:${dispatchId}`);
      }
    }
  },

  /**
   * Invalidate the cached location for a dispatch (e.g., on completion).
   */
  async invalidateCache(dispatchId: string): Promise<void> {
    if (redisClient) {
      try {
        await redisClient.del(`${LOCATION_CACHE_PREFIX}${dispatchId}`);
      } catch {
        // Non-fatal
      }
    }
  },
};
