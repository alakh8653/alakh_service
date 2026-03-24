/**
 * @module disputes/service
 * @description Business-logic layer for the Disputes module.
 *
 * All public methods throw typed `AppError` subclasses on failure so that the
 * global error-handler middleware can respond with the correct HTTP status code.
 */

import { prisma } from '../../config/database';
import {
  NotFoundError,
  ForbiddenError,
  BadRequestError,
  ConflictError,
} from '../../shared/errors';
import { buildPaginationMeta } from '../../shared/utils/pagination';
import { uploadFile } from '../../shared/utils/upload';
import { disputeRepository } from './disputes.repository';
import {
  DisputeType,
  DisputeStatus,
  DisputeResolution,
  DisputeStats,
  DisputeQueueFilters,
  DisputeWithDetails,
  MessageSenderRole,
  DisputePriority,
} from './disputes.types';

// ─── Internal Helpers ─────────────────────────────────────────────────────────

/** Statuses that are considered "terminal" — no further action is allowed. */
const TERMINAL_STATUSES: DisputeStatus[] = ['RESOLVED', 'CLOSED'];

/** Active (non-terminal) dispute statuses. */
const ACTIVE_STATUSES: DisputeStatus[] = [
  'SUBMITTED',
  'UNDER_REVIEW',
  'AWAITING_RESPONSE',
  'ESCALATED',
];

/**
 * Classifies a dispute's initial priority based on its type and the
 * booking amount.
 */
function derivePriority(type: DisputeType, bookingAmount: number): DisputePriority {
  if (type === 'DAMAGED_PROPERTY' || bookingAmount >= 5000) return 'HIGH';
  if (type === 'NO_SHOW' || type === 'OVERCHARGE') return 'MEDIUM';
  return 'LOW';
}

/**
 * Ensures a dispute exists and is accessible to the requesting user.
 * Admins may access any dispute.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the requesting user.
 * @param userRole - Role of the requesting user.
 * @throws {NotFoundError} if the dispute does not exist.
 * @throws {ForbiddenError} if the user is not a party to the dispute.
 */
async function assertDisputeAccess(
  disputeId: string,
  userId: string,
  userRole: string,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);

  const isAdmin = userRole === 'ADMIN' || userRole === 'SUPER_ADMIN';
  if (isAdmin) return dispute;

  const isParty =
    dispute.customerId === userId || dispute.provider?.userId === userId;
  if (!isParty) throw new ForbiddenError('You are not authorised to access this dispute');

  return dispute;
}

/**
 * Derives the `MessageSenderRole` for a given user in the context of a dispute.
 */
function senderRoleForUser(userId: string, userRole: string, dispute: any): MessageSenderRole {
  if (userRole === 'ADMIN' || userRole === 'SUPER_ADMIN') {
    if (dispute.mediatorId === userId) return 'MEDIATOR';
    return 'ADMIN';
  }
  if (dispute.customerId === userId) return 'CUSTOMER';
  return 'SHOP_OWNER';
}

// ─── Customer-facing Methods ──────────────────────────────────────────────────

/**
 * Creates a new dispute for the specified booking.
 *
 * Business rules:
 * - The booking must exist and belong to the requesting customer.
 * - The booking must be COMPLETED (disputes cannot be raised on open bookings).
 * - Only one open dispute is allowed per booking.
 *
 * @param userId - UUID of the authenticated customer.
 * @param data - Validated `FileDisputeInput` payload.
 * @returns The newly-created dispute record.
 */
export async function fileDispute(
  userId: string,
  data: { bookingId: string; type: DisputeType; reason: string; description: string },
): Promise<DisputeWithDetails> {
  const booking = await (prisma as any).booking.findUnique({
    where: { id: data.bookingId },
    include: { provider: true },
  });

  if (!booking) throw new NotFoundError('Booking', data.bookingId);
  if (booking.customerId !== userId) {
    throw new ForbiddenError('You can only file disputes for your own bookings');
  }
  if (booking.status !== 'COMPLETED') {
    throw new BadRequestError('Disputes can only be filed for completed bookings');
  }

  // Guard: only one active dispute per booking
  const existingDispute = await (prisma as any).dispute.findFirst({
    where: { bookingId: data.bookingId, status: { in: ACTIVE_STATUSES } },
  });
  if (existingDispute) {
    throw new ConflictError('An active dispute already exists for this booking');
  }

  const priority = derivePriority(data.type, booking.totalAmount ?? 0);

  const dispute = await disputeRepository.create({
    bookingId: data.bookingId,
    customerId: userId,
    providerId: booking.providerId,
    type: data.type,
    reason: data.reason,
    description: data.description,
    status: 'SUBMITTED',
    priority,
  });

  // TODO: emit 'dispute.filed' event to notification service so that
  //       the provider and admin receive push / email alerts.

  return dispute as DisputeWithDetails;
}

/**
 * Retrieves a paginated list of disputes filed by the authenticated customer.
 *
 * @param userId - UUID of the customer.
 * @param filters - Optional status / type filters.
 * @param pagination - Page, limit, sort options.
 * @returns Paginated result set with metadata.
 */
export async function getUserDisputes(
  userId: string,
  filters: { status?: DisputeStatus; type?: DisputeType },
  pagination: { page: number; limit: number; sortBy?: string; sortOrder?: 'asc' | 'desc' },
): Promise<{ data: DisputeWithDetails[]; meta: ReturnType<typeof buildPaginationMeta> }> {
  const page = Math.max(1, pagination.page ?? 1);
  const limit = Math.min(100, Math.max(1, pagination.limit ?? 20));
  const skip = (page - 1) * limit;

  const { data, total } = await disputeRepository.findByUserId(
    userId,
    filters,
    { skip, limit, sortBy: pagination.sortBy ?? 'createdAt', sortOrder: pagination.sortOrder ?? 'desc' },
  );

  return { data: data as DisputeWithDetails[], meta: buildPaginationMeta(total, page, limit) };
}

/**
 * Retrieves a single dispute by ID, ensuring the requesting user is a party.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the requesting user.
 * @param userRole - Role of the requesting user.
 * @returns The dispute record with relations.
 */
export async function getDisputeById(
  disputeId: string,
  userId: string,
  userRole: string,
): Promise<DisputeWithDetails> {
  const dispute = await assertDisputeAccess(disputeId, userId, userRole);
  return dispute as DisputeWithDetails;
}

/**
 * Uploads a file as evidence for an existing dispute.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the uploader.
 * @param userRole - Role of the uploader.
 * @param file - Multer file buffer from the request.
 * @param description - Optional human-readable description of the evidence.
 * @returns The created evidence record.
 */
export async function uploadEvidence(
  disputeId: string,
  userId: string,
  userRole: string,
  file: Express.Multer.File,
  description?: string,
): Promise<any> {
  const dispute = await assertDisputeAccess(disputeId, userId, userRole);

  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError('Evidence cannot be added to a resolved or closed dispute');
  }

  // TODO: Replace uploadFile with the project's S3 utility once storage
  //       bucket policies for dispute evidence are configured.
  const fileUrl = await uploadFile(
    file.buffer,
    file.originalname,
    file.mimetype,
    'disputes/evidence',
  );

  const mimeToEvidenceType = (mime: string) => {
    if (mime.startsWith('image/')) return 'PHOTO' as const;
    if (mime.startsWith('video/')) return 'VIDEO' as const;
    if (mime === 'application/pdf' || mime.startsWith('application/')) return 'DOCUMENT' as const;
    return 'TEXT' as const;
  };

  const evidence = await disputeRepository.createEvidence({
    disputeId,
    uploadedBy: userId,
    fileUrl,
    fileType: mimeToEvidenceType(file.mimetype),
    description,
  });

  return evidence;
}

/**
 * Sends a message within the dispute thread.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the sender.
 * @param userRole - Role of the sender.
 * @param content - Message text (max 2000 chars, already validated).
 * @returns The created message record.
 */
export async function sendDisputeMessage(
  disputeId: string,
  userId: string,
  userRole: string,
  content: string,
): Promise<any> {
  const dispute = await assertDisputeAccess(disputeId, userId, userRole);

  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError('Messages cannot be sent on a resolved or closed dispute');
  }

  const role = senderRoleForUser(userId, userRole, dispute);

  return disputeRepository.createMessage({ disputeId, senderId: userId, senderRole: role, content });
}

/**
 * Retrieves paginated messages for a dispute thread.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the requesting user.
 * @param userRole - Role of the requesting user.
 * @param pagination - Page & limit values.
 */
export async function getDisputeMessages(
  disputeId: string,
  userId: string,
  userRole: string,
  pagination: { page: number; limit: number },
): Promise<{ data: any[]; meta: ReturnType<typeof buildPaginationMeta> }> {
  await assertDisputeAccess(disputeId, userId, userRole);

  const page = Math.max(1, pagination.page ?? 1);
  const limit = Math.min(100, Math.max(1, pagination.limit ?? 50));
  const skip = (page - 1) * limit;

  const { data, total } = await disputeRepository.findMessages(disputeId, { skip, limit });
  return { data, meta: buildPaginationMeta(total, page, limit) };
}

/**
 * Cancels a dispute filed by the requesting customer.
 *
 * @param disputeId - UUID of the dispute.
 * @param userId - UUID of the customer requesting cancellation.
 * @throws {ForbiddenError} if the user did not file the dispute.
 * @throws {BadRequestError} if the dispute cannot be cancelled in its current state.
 */
export async function cancelDispute(disputeId: string, userId: string): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);

  if (dispute.customerId !== userId) {
    throw new ForbiddenError('You can only cancel disputes that you filed');
  }

  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Dispute cannot be cancelled when status is ${dispute.status}`);
  }

  if (dispute.status === 'ESCALATED') {
    throw new BadRequestError('Escalated disputes cannot be cancelled — please contact support');
  }

  return disputeRepository.update(disputeId, {
    status: 'CLOSED',
    closedAt: new Date(),
    resolutionNotes: 'Cancelled by customer',
  });
}

// ─── Shop / Provider-facing Methods ──────────────────────────────────────────

/**
 * Returns a paginated list of disputes for a specific provider shop,
 * verifying that the requesting user owns the shop.
 *
 * @param shopId - UUID of the provider.
 * @param ownerId - UUID of the authenticated provider user.
 * @param filters - Status / type filters.
 * @param pagination - Page, limit, sort options.
 */
export async function getShopDisputes(
  shopId: string,
  ownerId: string,
  filters: { status?: DisputeStatus; type?: DisputeType },
  pagination: { page: number; limit: number; sortBy?: string; sortOrder?: 'asc' | 'desc' },
): Promise<{ data: DisputeWithDetails[]; meta: ReturnType<typeof buildPaginationMeta> }> {
  await assertShopOwner(shopId, ownerId);

  const page = Math.max(1, pagination.page ?? 1);
  const limit = Math.min(100, Math.max(1, pagination.limit ?? 20));
  const skip = (page - 1) * limit;

  const { data, total } = await disputeRepository.findByShopId(
    shopId,
    filters,
    { skip, limit, sortBy: pagination.sortBy ?? 'createdAt', sortOrder: pagination.sortOrder ?? 'desc' },
  );

  return { data: data as DisputeWithDetails[], meta: buildPaginationMeta(total, page, limit) };
}

/**
 * Retrieves a single dispute on behalf of a shop owner.
 */
export async function getShopDisputeById(
  shopId: string,
  ownerId: string,
  disputeId: string,
): Promise<DisputeWithDetails> {
  await assertShopOwner(shopId, ownerId);

  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.providerId !== shopId) {
    throw new ForbiddenError('This dispute does not belong to your shop');
  }

  return dispute as DisputeWithDetails;
}

/**
 * Records the shop's official response to a dispute and advances
 * the status to `UNDER_REVIEW`.
 *
 * @param shopId - UUID of the provider.
 * @param ownerId - UUID of the authenticated provider user.
 * @param disputeId - UUID of the dispute.
 * @param response - The shop's written response.
 */
export async function shopRespondToDispute(
  shopId: string,
  ownerId: string,
  disputeId: string,
  response: string,
): Promise<any> {
  await assertShopOwner(shopId, ownerId);

  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.providerId !== shopId) {
    throw new ForbiddenError('This dispute does not belong to your shop');
  }
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Cannot respond to a ${dispute.status} dispute`);
  }
  if (dispute.shopResponse) {
    throw new ConflictError('You have already submitted a response for this dispute');
  }

  const updated = await disputeRepository.update(disputeId, {
    shopResponse: response,
    shopRespondedAt: new Date(),
    status: 'UNDER_REVIEW',
  });

  // TODO: Notify customer and admin that the shop has responded.

  return updated;
}

/**
 * Allows a shop to upload evidence files.
 * Re-uses the same evidence upload flow as the customer.
 */
export async function shopUploadEvidence(
  shopId: string,
  ownerId: string,
  disputeId: string,
  file: Express.Multer.File,
  description?: string,
): Promise<any> {
  await assertShopOwner(shopId, ownerId);

  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.providerId !== shopId) {
    throw new ForbiddenError('This dispute does not belong to your shop');
  }

  return uploadEvidence(disputeId, ownerId, 'PROVIDER', file, description);
}

/**
 * Records the shop's voluntary acceptance of fault along with a proposed
 * resolution, then notifies the admin team for final approval.
 *
 * @param shopId - UUID of the provider.
 * @param ownerId - UUID of the authenticated provider user.
 * @param disputeId - UUID of the dispute.
 * @param proposedResolution - The shop's proposed remedy.
 */
export async function shopAcceptFault(
  shopId: string,
  ownerId: string,
  disputeId: string,
  proposedResolution: { refundAmount?: number; action?: string; notes?: string },
): Promise<any> {
  await assertShopOwner(shopId, ownerId);

  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.providerId !== shopId) {
    throw new ForbiddenError('This dispute does not belong to your shop');
  }
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Cannot accept fault on a ${dispute.status} dispute`);
  }

  const updated = await disputeRepository.update(disputeId, {
    shopProposedResolution: proposedResolution,
    status: 'UNDER_REVIEW',
  });

  // TODO: Notify admin that the shop has accepted fault and proposed a resolution.

  return updated;
}

// ─── Admin Methods ────────────────────────────────────────────────────────────

/**
 * Returns the admin moderation queue with filtering and pagination.
 *
 * @param filters - Full set of admin queue filters.
 * @param pagination - Page, limit, sort options.
 */
export async function getDisputeQueue(
  filters: DisputeQueueFilters,
  pagination: { page: number; limit: number; sortBy?: string; sortOrder?: 'asc' | 'desc' },
): Promise<{ data: DisputeWithDetails[]; meta: ReturnType<typeof buildPaginationMeta> }> {
  const page = Math.max(1, pagination.page ?? 1);
  const limit = Math.min(100, Math.max(1, pagination.limit ?? 20));
  const skip = (page - 1) * limit;

  const { data, total } = await disputeRepository.findQueue(filters, {
    skip,
    limit,
    sortBy: pagination.sortBy ?? 'createdAt',
    sortOrder: pagination.sortOrder ?? 'asc',
  });

  return { data: data as DisputeWithDetails[], meta: buildPaginationMeta(total, page, limit) };
}

/**
 * Retrieves the full dispute record including the message thread for admin use.
 *
 * @param disputeId - UUID of the dispute.
 */
export async function getDisputeDetailAdmin(disputeId: string): Promise<DisputeWithDetails> {
  const dispute = await disputeRepository.findByIdWithFullDetails(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  return dispute as DisputeWithDetails;
}

/**
 * Assigns a mediator (admin user) to a dispute and transitions
 * status to `AWAITING_RESPONSE`.
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin performing the assignment.
 * @param mediatorId - UUID of the user to assign as mediator.
 */
export async function assignMediator(
  disputeId: string,
  adminId: string,
  mediatorId: string,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Cannot assign mediator to a ${dispute.status} dispute`);
  }

  // Verify mediator exists and is an admin-level user
  const mediator = await (prisma as any).user.findUnique({ where: { id: mediatorId } });
  if (!mediator) throw new NotFoundError('User (mediator)', mediatorId);
  if (mediator.role !== 'ADMIN' && mediator.role !== 'SUPER_ADMIN') {
    throw new BadRequestError('Mediator must be an ADMIN or SUPER_ADMIN user');
  }

  const updated = await disputeRepository.update(disputeId, {
    mediatorId,
    assignedAt: new Date(),
    status: 'AWAITING_RESPONSE',
  });

  // TODO: Notify mediator via push / email.

  return updated;
}

/**
 * Escalates a dispute and records the reason.
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin performing the escalation.
 * @param reason - Textual justification for the escalation.
 */
export async function escalateDispute(
  disputeId: string,
  adminId: string,
  reason: string,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Cannot escalate a ${dispute.status} dispute`);
  }
  if (dispute.status === 'ESCALATED') {
    throw new ConflictError('Dispute is already escalated');
  }

  const updated = await disputeRepository.update(disputeId, {
    status: 'ESCALATED',
    priority: 'URGENT',
    escalatedAt: new Date(),
    escalationReason: reason,
  });

  // TODO: Notify senior admin team.

  return updated;
}

/**
 * Resolves a dispute with a final outcome and optional refund / penalty details.
 * Does NOT process refunds — use `processDisputeRefund` for that.
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin resolving the dispute.
 * @param resolution - Resolution payload.
 */
export async function resolveDispute(
  disputeId: string,
  adminId: string,
  resolution: DisputeResolution,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError(`Dispute is already ${dispute.status}`);
  }

  const updated = await disputeRepository.update(disputeId, {
    status: 'RESOLVED',
    outcome: resolution.outcome,
    refundAmount: resolution.refundAmount ?? null,
    refundPercentage: resolution.refundPercentage ?? null,
    penaltyAction: resolution.penaltyAction ?? 'NONE',
    resolutionNotes: resolution.notes,
    resolvedAt: new Date(),
  });

  // TODO: Notify customer and provider of the resolution outcome.
  // TODO: If penaltyAction is SUSPEND or BAN, trigger provider account action.

  return updated;
}

/**
 * Closes a dispute without a formal resolution (e.g. withdrawn, stale).
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin performing the close.
 */
export async function closeDispute(disputeId: string, adminId: string): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.status === 'CLOSED') {
    throw new ConflictError('Dispute is already closed');
  }

  return disputeRepository.update(disputeId, {
    status: 'CLOSED',
    closedAt: new Date(),
  });
}

/**
 * Marks a refund as processed for a resolved dispute.
 *
 * NOTE: This method records that a refund was processed but does NOT
 * initiate the actual payment gateway call — that should be handled
 * by the payments module / Razorpay refund flow.
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin processing the refund.
 * @param amount - The actual refund amount (may differ from the determined amount).
 */
export async function processDisputeRefund(
  disputeId: string,
  adminId: string,
  amount: number,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (dispute.status !== 'RESOLVED') {
    throw new BadRequestError('Refund can only be processed for RESOLVED disputes');
  }
  if (dispute.refundProcessed) {
    throw new ConflictError('Refund has already been processed for this dispute');
  }
  if (amount <= 0) {
    throw new BadRequestError('Refund amount must be greater than zero');
  }

  // TODO: Initiate Razorpay refund via the payments module.
  //       await paymentsService.issueRefund(dispute.bookingId, amount);

  return disputeRepository.update(disputeId, {
    refundProcessed: true,
    refundProcessedAt: new Date(),
    refundAmount: amount,
  });
}

/**
 * Allows an admin or mediator to send a message in the dispute thread.
 *
 * @param disputeId - UUID of the dispute.
 * @param adminId - UUID of the admin sending the message.
 * @param content - Message content.
 */
export async function adminSendMessage(
  disputeId: string,
  adminId: string,
  content: string,
): Promise<any> {
  const dispute = await disputeRepository.findById(disputeId);
  if (!dispute) throw new NotFoundError('Dispute', disputeId);
  if (TERMINAL_STATUSES.includes(dispute.status)) {
    throw new BadRequestError('Messages cannot be sent on a closed dispute');
  }

  const role: MessageSenderRole =
    dispute.mediatorId === adminId ? 'MEDIATOR' : 'ADMIN';

  return disputeRepository.createMessage({
    disputeId,
    senderId: adminId,
    senderRole: role,
    content,
  });
}

/**
 * Computes and returns aggregated dispute statistics for a given period.
 *
 * @param period - Optional date range. Falls back to all-time if not provided.
 */
export async function getDisputeStats(period?: {
  startDate?: Date;
  endDate?: Date;
}): Promise<DisputeStats> {
  const raw = await disputeRepository.getStats(period?.startDate, period?.endDate);

  // Average resolution time in hours
  let avgResolutionTimeHours = 0;
  const timed = raw.resolvedWithTimings.filter((r: any) => r.resolvedAt != null);
  if (timed.length > 0) {
    const totalMs = timed.reduce((sum: number, r: any) => {
      return sum + (new Date(r.resolvedAt).getTime() - new Date(r.createdAt).getTime());
    }, 0);
    avgResolutionTimeHours = totalMs / timed.length / (1000 * 60 * 60);
  }

  const escalationRate = raw.total > 0 ? raw.escalatedCount / raw.total : 0;

  const customerFavored = raw.byOutcome['CUSTOMER_FAVORED'] ?? 0;
  const totalOutcomes = Object.values(raw.byOutcome as Record<string, number>).reduce(
    (sum: number, v: number) => sum + v,
    0,
  );
  const customerSatisfaction = totalOutcomes > 0 ? customerFavored / totalOutcomes : 0;

  return {
    openCount: raw.openCount,
    resolvedCount: raw.resolvedCount,
    avgResolutionTimeHours: Math.round(avgResolutionTimeHours * 100) / 100,
    byType: raw.byType as Record<DisputeType, number>,
    escalationRate: Math.round(escalationRate * 10000) / 10000,
    customerSatisfaction: Math.round(customerSatisfaction * 10000) / 10000,
  };
}

// ─── Private Helpers ──────────────────────────────────────────────────────────

/**
 * Verifies that `ownerId` is the user associated with the given provider record.
 *
 * @throws {NotFoundError} if the provider does not exist.
 * @throws {ForbiddenError} if the authenticated user does not own the shop.
 */
async function assertShopOwner(shopId: string, ownerId: string): Promise<void> {
  const provider = await (prisma as any).provider.findUnique({
    where: { id: shopId },
    select: { id: true, userId: true },
  });

  if (!provider) throw new NotFoundError('Provider', shopId);
  if (provider.userId !== ownerId) {
    throw new ForbiddenError('You do not own this shop');
  }
}
