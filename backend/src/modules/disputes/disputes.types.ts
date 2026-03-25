/**
 * @module disputes/types
 * @description TypeScript interfaces and type aliases for the Disputes module.
 */

// ─── Enum-style Union Types ──────────────────────────────────────────────────

/** Categories a dispute can be classified under. */
export type DisputeType =
  | 'SERVICE_QUALITY'
  | 'OVERCHARGE'
  | 'NO_SHOW'
  | 'WRONG_SERVICE'
  | 'DAMAGED_PROPERTY'
  | 'UNPROFESSIONAL'
  | 'OTHER';

/** Lifecycle states of a dispute. */
export type DisputeStatus =
  | 'SUBMITTED'
  | 'UNDER_REVIEW'
  | 'AWAITING_RESPONSE'
  | 'ESCALATED'
  | 'RESOLVED'
  | 'CLOSED';

/** Urgency level assigned by admins to prioritise the review queue. */
export type DisputePriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';

/** Final determination made when resolving a dispute. */
export type DisputeOutcome =
  | 'CUSTOMER_FAVORED'
  | 'SHOP_FAVORED'
  | 'COMPROMISE'
  | 'DISMISSED';

/** Enforcement action taken against the shop after resolution. */
export type PenaltyAction = 'NONE' | 'WARN' | 'SUSPEND' | 'BAN';

/** Media/document type for evidence attached to a dispute. */
export type EvidenceType = 'PHOTO' | 'VIDEO' | 'TEXT' | 'DOCUMENT';

/** Role label for participants sending messages inside a dispute thread. */
export type MessageSenderRole = 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN' | 'MEDIATOR';

// ─── Input DTOs ──────────────────────────────────────────────────────────────

/**
 * Payload supplied by a customer when opening a new dispute.
 */
export interface FileDisputeInput {
  /** UUID of the booking that the dispute relates to. */
  bookingId: string;
  /** Classification of the problem encountered. */
  type: DisputeType;
  /** Short summary of the complaint (≤ 200 chars). */
  reason: string;
  /** Full description of the incident (≤ 5000 chars). */
  description: string;
}

/**
 * Payload for attaching evidence to an existing dispute.
 */
export interface EvidenceUpload {
  /** UUID of the dispute being evidenced. */
  disputeId: string;
  /** UUID of the user uploading the file. */
  uploadedBy: string;
  /** Publicly accessible URL returned after uploading to S3. */
  fileUrl: string;
  /** Nature of the file being uploaded. */
  fileType: EvidenceType;
  /** Optional human-readable description of what the file shows. */
  description?: string;
}

/**
 * Resolution details provided by an admin when closing a dispute.
 */
export interface DisputeResolution {
  /** Verdict reached after mediation. */
  outcome: DisputeOutcome;
  /** Fixed monetary refund amount (mutually exclusive with refundPercentage). */
  refundAmount?: number;
  /** Percentage of the booking total to refund (0–100). */
  refundPercentage?: number;
  /** Enforcement action to apply to the service provider. */
  penaltyAction?: PenaltyAction;
  /** Internal notes justifying the decision. */
  notes: string;
}

// ─── Rich Return Types ───────────────────────────────────────────────────────

/**
 * Full dispute record including all joined relations,
 * returned to controllers from the repository layer.
 */
export interface DisputeWithDetails {
  id: string;
  bookingId: string;
  customerId: string;
  providerId: string;
  type: DisputeType;
  status: DisputeStatus;
  priority: DisputePriority;
  reason: string;
  description: string;
  shopResponse?: string | null;
  shopRespondedAt?: Date | null;
  shopProposedResolution?: Record<string, unknown> | null;
  mediatorId?: string | null;
  assignedAt?: Date | null;
  escalatedAt?: Date | null;
  escalationReason?: string | null;
  resolvedAt?: Date | null;
  closedAt?: Date | null;
  outcome?: DisputeOutcome | null;
  refundAmount?: number | null;
  refundPercentage?: number | null;
  penaltyAction?: PenaltyAction | null;
  resolutionNotes?: string | null;
  refundProcessed?: boolean;
  refundProcessedAt?: Date | null;
  createdAt: Date;
  updatedAt: Date;
  /** Minimal booking details for context. */
  booking?: {
    id: string;
    bookingNumber: string;
    totalAmount: number;
    scheduledAt: Date;
    status: string;
  } | null;
  /** Customer who filed the dispute. */
  customer?: {
    id: string;
    name: string;
    email?: string | null;
    phone?: string | null;
  } | null;
  /** Provider being disputed. */
  provider?: {
    id: string;
    businessName?: string | null;
    user?: { id: string; name: string; email?: string | null } | null;
  } | null;
  /** Mediator assigned by admin (if any). */
  mediator?: {
    id: string;
    name: string;
    email?: string | null;
  } | null;
  /** Evidence files attached by any party. */
  evidence?: EvidenceRecord[];
  /** Message thread between parties. */
  messages?: DisputeMessage[];
}

/**
 * A single piece of evidence attached to a dispute.
 */
export interface EvidenceRecord {
  id: string;
  disputeId: string;
  uploadedBy: string;
  fileUrl: string;
  fileType: EvidenceType;
  description?: string | null;
  createdAt: Date;
  uploader?: { id: string; name: string; role: string } | null;
}

/**
 * A message sent within a dispute thread.
 */
export interface DisputeMessage {
  id: string;
  disputeId: string;
  senderId: string;
  senderRole: MessageSenderRole;
  content: string;
  createdAt: Date;
  sender?: { id: string; name: string } | null;
}

/**
 * A single entry on the dispute's audit/activity timeline.
 */
export interface DisputeTimeline {
  /** Human-readable label for the event (e.g. "Status changed to ESCALATED"). */
  event: string;
  /** When the event occurred. */
  timestamp: Date;
  /** UUID of the user who caused the event, if applicable. */
  actorId?: string;
  /** Display name of that user. */
  actorName?: string;
  /** Extra context about the event. */
  details?: string;
}

// ─── Statistics ──────────────────────────────────────────────────────────────

/**
 * Aggregated statistics surfaced on the admin dashboard.
 */
export interface DisputeStats {
  /** Disputes currently open (not RESOLVED or CLOSED). */
  openCount: number;
  /** Disputes that have reached RESOLVED or CLOSED state. */
  resolvedCount: number;
  /** Mean time from SUBMITTED to RESOLVED, in hours. */
  avgResolutionTimeHours: number;
  /** Count of disputes broken down by type. */
  byType: Record<DisputeType, number>;
  /** Ratio of ESCALATED disputes to total disputes (0–1). */
  escalationRate: number;
  /**
   * Proxy for customer satisfaction: ratio of CUSTOMER_FAVORED outcomes
   * to all resolved disputes (0–1).
   */
  customerSatisfaction: number;
}

// ─── Filter / Query Types ────────────────────────────────────────────────────

/**
 * Filters accepted by the admin dispute queue endpoint.
 */
export interface DisputeQueueFilters {
  status?: DisputeStatus;
  type?: DisputeType;
  priority?: DisputePriority;
  /** UUID of the mediator/admin the dispute is assigned to. */
  assigneeId?: string;
  startDate?: Date;
  endDate?: Date;
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}
