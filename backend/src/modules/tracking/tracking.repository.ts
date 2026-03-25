import { prisma } from '../../config/database';
import { LocationHistoryEntry, LocationHistoryFilters } from './tracking.types';
import { getSkip, getPaginationParams } from '../../shared/utils/pagination';

/**
 * Tracking repository — all Prisma data access for the tracking module.
 */
export const trackingRepository = {
  /** Append a location point to the history for a dispatch. */
  async addLocation(data: {
    dispatchId: string;
    latitude: number;
    longitude: number;
    heading?: number;
    speed?: number;
    accuracy?: number;
  }): Promise<LocationHistoryEntry> {
    return prisma.locationHistory.create({ data }) as Promise<LocationHistoryEntry>;
  },

  /** Get the most recent location entry for a dispatch. */
  async getLatestLocation(dispatchId: string): Promise<LocationHistoryEntry | null> {
    return prisma.locationHistory.findFirst({
      where: { dispatchId },
      orderBy: { recordedAt: 'desc' },
    }) as Promise<LocationHistoryEntry | null>;
  },

  /** Get paginated location history for a dispatch. */
  async getHistory(dispatchId: string, filters: LocationHistoryFilters) {
    const pagination = getPaginationParams({ page: filters.page, perPage: filters.perPage });

    const where = {
      dispatchId,
      ...(filters.startDate || filters.endDate
        ? {
            recordedAt: {
              ...(filters.startDate && { gte: new Date(filters.startDate) }),
              ...(filters.endDate && { lte: new Date(filters.endDate) }),
            },
          }
        : {}),
    };

    const [items, total] = await Promise.all([
      prisma.locationHistory.findMany({
        where,
        skip: getSkip(pagination),
        take: pagination.perPage,
        orderBy: { recordedAt: 'asc' },
      }),
      prisma.locationHistory.count({ where }),
    ]);

    return { items, total };
  },

  /** Update staffLatitude/staffLongitude on the dispatch record. */
  async updateDispatchLocation(
    dispatchId: string,
    latitude: number,
    longitude: number,
  ): Promise<void> {
    await prisma.dispatch.update({
      where: { id: dispatchId },
      data: { staffLatitude: latitude, staffLongitude: longitude },
    });
  },

  /** Fetch the dispatch with staff and customer for access checks. */
  async findDispatch(dispatchId: string) {
    return prisma.dispatch.findUnique({
      where: { id: dispatchId },
      select: {
        id: true,
        staffId: true,
        customerId: true,
        shopId: true,
        status: true,
        destinationLatitude: true,
        destinationLongitude: true,
        estimatedArrival: true,
        staff: { select: { id: true, name: true } },
      },
    });
  },
};
