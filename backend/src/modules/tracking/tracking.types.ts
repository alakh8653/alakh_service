export interface UpdateLocationInput {
  latitude: number;
  longitude: number;
  heading?: number;
  speed?: number;
  accuracy?: number;
}

export interface LiveLocation {
  dispatchId: string;
  latitude: number;
  longitude: number;
  heading?: number;
  speed?: number;
  accuracy?: number;
  recordedAt: Date;
  staffId: string;
  staffName: string;
}

export interface LocationHistoryEntry {
  id: string;
  dispatchId: string;
  latitude: number;
  longitude: number;
  heading?: number | null;
  speed?: number | null;
  accuracy?: number | null;
  recordedAt: Date;
}

export interface TrackingSession {
  dispatchId: string;
  staffId: string;
  customerId: string;
  status: string;
  currentLocation?: LiveLocation;
  destinationLatitude?: number | null;
  destinationLongitude?: number | null;
  estimatedArrival?: Date | null;
}

export interface LocationHistoryFilters {
  startDate?: string;
  endDate?: string;
  page?: number;
  perPage?: number;
}
