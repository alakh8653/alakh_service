import { QueueEntryStatus } from '@prisma/client';

export interface JoinQueueInput {
  shopId: string;
  serviceId?: string;
}

export interface QueueStatusResponse {
  entryId: string;
  position: number;
  estimatedWaitMinutes: number;
  status: QueueEntryStatus;
  aheadCount: number;
  shopName: string;
  serviceName?: string;
  joinedAt: Date;
}

export interface QueueStats {
  totalWaiting: number;
  totalServing: number;
  totalCompleted: number;
  totalSkipped: number;
  avgWaitMinutes: number;
  currentPosition: number;
  estimatedClearMinutes: number;
}

export interface QueueSettingsInput {
  isActive?: boolean;
  maxCapacity?: number;
  autoAccept?: boolean;
  estimatedServiceTime?: number;
}

export interface QueueEntryWithDetails {
  id: string;
  position: number;
  status: QueueEntryStatus;
  joinedAt: Date;
  calledAt?: Date | null;
  servedAt?: Date | null;
  completedAt?: Date | null;
  user: {
    id: string;
    name: string;
    phone?: string | null;
  };
  service?: {
    id: string;
    name: string;
    duration: number;
  } | null;
  estimatedWaitMinutes?: number;
}

export interface QueueFilters {
  status?: QueueEntryStatus;
  page?: number;
  perPage?: number;
}
