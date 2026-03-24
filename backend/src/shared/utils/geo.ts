import { GeoCoordinates } from '../types';

const EARTH_RADIUS_KM = 6371;

export const degreesToRadians = (degrees: number): number => (degrees * Math.PI) / 180;

export const haversineDistance = (a: GeoCoordinates, b: GeoCoordinates): number => {
  const dLat = degreesToRadians(b.lat - a.lat);
  const dLng = degreesToRadians(b.lng - a.lng);
  const sinDLat = Math.sin(dLat / 2);
  const sinDLng = Math.sin(dLng / 2);

  const haversine =
    sinDLat * sinDLat +
    Math.cos(degreesToRadians(a.lat)) * Math.cos(degreesToRadians(b.lat)) * sinDLng * sinDLng;

  return EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));
};

export const isWithinRadius = (
  center: GeoCoordinates,
  point: GeoCoordinates,
  radiusKm: number,
): boolean => haversineDistance(center, point) <= radiusKm;

export const boundingBox = (
  center: GeoCoordinates,
  radiusKm: number,
): { minLat: number; maxLat: number; minLng: number; maxLng: number } => {
  const latDelta = radiusKm / EARTH_RADIUS_KM * (180 / Math.PI);
  const lngDelta = latDelta / Math.cos(degreesToRadians(center.lat));

  return {
    minLat: center.lat - latDelta,
    maxLat: center.lat + latDelta,
    minLng: center.lng - lngDelta,
    maxLng: center.lng + lngDelta,
  };
};
