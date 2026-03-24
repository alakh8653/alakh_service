/**
 * @module disputes/controller
 * @description Thin request-handler layer for the Disputes module.
 *
 * Each controller extracts validated data from the request, delegates to the
 * service layer, and sends a typed HTTP response via the shared response helpers.
 * All errors are forwarded to the global error-handler via `next(err)`.
 */

import { Request, Response, NextFunction } from 'express';
import {
  sendSuccess,
  sendCreated,
  sendPaginated,
  sendNoContent,
} from '../../shared/utils/response';
import * as disputeService from './disputes.service';

// ─── Customer Controllers ─────────────────────────────────────────────────────

/**
 * @swagger
 * /disputes:
 *   post:
 *     summary: File a new dispute
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [bookingId, type, reason, description]
 *             properties:
 *               bookingId:
 *                 type: string
 *                 format: uuid
 *               type:
 *                 type: string
 *                 enum: [SERVICE_QUALITY, OVERCHARGE, NO_SHOW, WRONG_SERVICE, DAMAGED_PROPERTY, UNPROFESSIONAL, OTHER]
 *               reason:
 *                 type: string
 *                 maxLength: 200
 *               description:
 *                 type: string
 *                 maxLength: 5000
 *     responses:
 *       201:
 *         description: Dispute filed successfully
 *       400:
 *         description: Invalid request or booking not in COMPLETED state
 *       409:
 *         description: Active dispute already exists for this booking
 */
export const fileDispute = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.fileDispute(req.user!.id, req.body);
    sendCreated(res, result, 'Dispute filed successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes:
 *   get:
 *     summary: List the authenticated customer's disputes
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *       - in: query
 *         name: status
 *         schema: { type: string }
 *       - in: query
 *         name: type
 *         schema: { type: string }
 *       - in: query
 *         name: sortOrder
 *         schema: { type: string, enum: [asc, desc], default: desc }
 *     responses:
 *       200:
 *         description: Paginated list of disputes
 */
export const getUserDisputes = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const { page, limit, status, type, sortBy, sortOrder } = req.query as Record<string, any>;
    const { data, meta } = await disputeService.getUserDisputes(
      req.user!.id,
      { status, type },
      { page: Number(page) || 1, limit: Number(limit) || 20, sortBy, sortOrder },
    );
    sendPaginated(res, data, meta, 'Disputes retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes/{id}:
 *   get:
 *     summary: Get a single dispute by ID
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Dispute detail
 *       403:
 *         description: Not a party to this dispute
 *       404:
 *         description: Dispute not found
 */
export const getDisputeById = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const dispute = await disputeService.getDisputeById(
      req.params.id,
      req.user!.id,
      req.user!.role,
    );
    sendSuccess(res, dispute, 'Dispute retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes/{id}/evidence:
 *   post:
 *     summary: Upload evidence for a dispute
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *               description:
 *                 type: string
 *                 maxLength: 500
 *     responses:
 *       201:
 *         description: Evidence uploaded successfully
 *       400:
 *         description: No file provided or dispute is closed
 */
export const uploadEvidence = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'No file provided' });
      return;
    }
    const evidence = await disputeService.uploadEvidence(
      req.params.id,
      req.user!.id,
      req.user!.role,
      req.file,
      req.body.description,
    );
    sendCreated(res, evidence, 'Evidence uploaded successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes/{id}/messages:
 *   post:
 *     summary: Send a message in the dispute thread
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [content]
 *             properties:
 *               content:
 *                 type: string
 *                 maxLength: 2000
 *     responses:
 *       201:
 *         description: Message sent
 *       400:
 *         description: Dispute is closed
 */
export const sendMessage = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const message = await disputeService.sendDisputeMessage(
      req.params.id,
      req.user!.id,
      req.user!.role,
      req.body.content,
    );
    sendCreated(res, message, 'Message sent successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes/{id}/messages:
 *   get:
 *     summary: List messages in a dispute thread
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 50 }
 *     responses:
 *       200:
 *         description: Paginated message list
 */
export const getMessages = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const { page, limit } = req.query as Record<string, any>;
    const { data, meta } = await disputeService.getDisputeMessages(
      req.params.id,
      req.user!.id,
      req.user!.role,
      { page: Number(page) || 1, limit: Number(limit) || 50 },
    );
    sendPaginated(res, data, meta, 'Messages retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /disputes/{id}/cancel:
 *   put:
 *     summary: Cancel an open dispute
 *     tags: [Disputes - Customer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Dispute cancelled
 *       400:
 *         description: Dispute cannot be cancelled in its current state
 *       403:
 *         description: Not the dispute owner
 */
export const cancelDispute = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.cancelDispute(req.params.id, req.user!.id);
    sendSuccess(res, result, 'Dispute cancelled successfully');
  } catch (err) {
    next(err);
  }
};

// ─── Shop / Provider Controllers ──────────────────────────────────────────────

/**
 * @swagger
 * /shops/{shopId}/disputes:
 *   get:
 *     summary: List disputes for a shop
 *     tags: [Disputes - Shop]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shopId
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Paginated list of shop disputes
 */
export const getShopDisputes = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const { page, limit, status, type, sortBy, sortOrder } = req.query as Record<string, any>;
    const { data, meta } = await disputeService.getShopDisputes(
      req.params.shopId,
      req.user!.id,
      { status, type },
      { page: Number(page) || 1, limit: Number(limit) || 20, sortBy, sortOrder },
    );
    sendPaginated(res, data, meta, 'Shop disputes retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /shops/{shopId}/disputes/{id}:
 *   get:
 *     summary: Get a single dispute for a shop
 *     tags: [Disputes - Shop]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shopId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Dispute detail
 */
export const getShopDisputeById = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const dispute = await disputeService.getShopDisputeById(
      req.params.shopId,
      req.user!.id,
      req.params.id,
    );
    sendSuccess(res, dispute, 'Dispute retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /shops/{shopId}/disputes/{id}/respond:
 *   post:
 *     summary: Submit shop's official response to a dispute
 *     tags: [Disputes - Shop]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shopId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [response]
 *             properties:
 *               response:
 *                 type: string
 *                 maxLength: 5000
 *     responses:
 *       200:
 *         description: Response submitted and dispute moved to UNDER_REVIEW
 *       409:
 *         description: Response already submitted
 */
export const shopRespond = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.shopRespondToDispute(
      req.params.shopId,
      req.user!.id,
      req.params.id,
      req.body.response,
    );
    sendSuccess(res, result, 'Response submitted successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /shops/{shopId}/disputes/{id}/evidence:
 *   post:
 *     summary: Upload evidence from the shop side
 *     tags: [Disputes - Shop]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shopId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *               description:
 *                 type: string
 *     responses:
 *       201:
 *         description: Evidence uploaded successfully
 */
export const shopUploadEvidence = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'No file provided' });
      return;
    }
    const evidence = await disputeService.shopUploadEvidence(
      req.params.shopId,
      req.user!.id,
      req.params.id,
      req.file,
      req.body.description,
    );
    sendCreated(res, evidence, 'Evidence uploaded successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /shops/{shopId}/disputes/{id}/accept:
 *   post:
 *     summary: Shop voluntarily accepts fault and proposes a resolution
 *     tags: [Disputes - Shop]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: shopId
 *         required: true
 *         schema: { type: string, format: uuid }
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [proposedResolution]
 *             properties:
 *               proposedResolution:
 *                 type: object
 *                 properties:
 *                   refundAmount: { type: number }
 *                   action: { type: string }
 *                   notes: { type: string }
 *     responses:
 *       200:
 *         description: Fault acceptance recorded
 */
export const shopAcceptFault = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.shopAcceptFault(
      req.params.shopId,
      req.user!.id,
      req.params.id,
      req.body.proposedResolution,
    );
    sendSuccess(res, result, 'Fault acceptance recorded successfully');
  } catch (err) {
    next(err);
  }
};

// ─── Admin Controllers ────────────────────────────────────────────────────────

/**
 * @swagger
 * /admin/disputes/stats:
 *   get:
 *     summary: Get aggregated dispute statistics
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: startDate
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: endDate
 *         schema: { type: string, format: date }
 *     responses:
 *       200:
 *         description: Dispute statistics
 */
export const getDisputeStats = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const { startDate, endDate } = req.query as Record<string, any>;
    const stats = await disputeService.getDisputeStats({
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });
    sendSuccess(res, stats, 'Dispute statistics retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes:
 *   get:
 *     summary: Get the admin dispute moderation queue
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema: { type: string }
 *       - in: query
 *         name: type
 *         schema: { type: string }
 *       - in: query
 *         name: priority
 *         schema: { type: string }
 *       - in: query
 *         name: assigneeId
 *         schema: { type: string, format: uuid }
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *     responses:
 *       200:
 *         description: Paginated dispute queue
 */
export const getAdminQueue = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const { page, limit, status, type, priority, assigneeId, startDate, endDate, sortBy, sortOrder } =
      req.query as Record<string, any>;

    const { data, meta } = await disputeService.getDisputeQueue(
      {
        status,
        type,
        priority,
        assigneeId,
        startDate: startDate ? new Date(startDate) : undefined,
        endDate: endDate ? new Date(endDate) : undefined,
      },
      { page: Number(page) || 1, limit: Number(limit) || 20, sortBy, sortOrder },
    );
    sendPaginated(res, data, meta, 'Dispute queue retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}:
 *   get:
 *     summary: Get full dispute details (admin view)
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Full dispute record including messages and evidence
 *       404:
 *         description: Dispute not found
 */
export const getAdminDisputeDetail = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const dispute = await disputeService.getDisputeDetailAdmin(req.params.id);
    sendSuccess(res, dispute, 'Dispute retrieved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/assign:
 *   put:
 *     summary: Assign a mediator to a dispute
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [mediatorId]
 *             properties:
 *               mediatorId:
 *                 type: string
 *                 format: uuid
 *     responses:
 *       200:
 *         description: Mediator assigned
 */
export const assignMediator = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.assignMediator(
      req.params.id,
      req.user!.id,
      req.body.mediatorId,
    );
    sendSuccess(res, result, 'Mediator assigned successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/escalate:
 *   put:
 *     summary: Escalate a dispute to URGENT priority
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [reason]
 *             properties:
 *               reason:
 *                 type: string
 *                 maxLength: 1000
 *     responses:
 *       200:
 *         description: Dispute escalated
 */
export const escalateDispute = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.escalateDispute(
      req.params.id,
      req.user!.id,
      req.body.reason,
    );
    sendSuccess(res, result, 'Dispute escalated successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/resolve:
 *   put:
 *     summary: Resolve a dispute with a final outcome
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [outcome, notes]
 *             properties:
 *               outcome:
 *                 type: string
 *                 enum: [CUSTOMER_FAVORED, SHOP_FAVORED, COMPROMISE, DISMISSED]
 *               refundAmount:
 *                 type: number
 *               refundPercentage:
 *                 type: number
 *               penaltyAction:
 *                 type: string
 *                 enum: [NONE, WARN, SUSPEND, BAN]
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dispute resolved
 */
export const resolveDispute = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.resolveDispute(
      req.params.id,
      req.user!.id,
      req.body,
    );
    sendSuccess(res, result, 'Dispute resolved successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/close:
 *   put:
 *     summary: Close a dispute without formal resolution
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     responses:
 *       200:
 *         description: Dispute closed
 */
export const closeDispute = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.closeDispute(req.params.id, req.user!.id);
    sendSuccess(res, result, 'Dispute closed successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/refund:
 *   post:
 *     summary: Mark a refund as processed for a resolved dispute
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [amount]
 *             properties:
 *               amount:
 *                 type: number
 *     responses:
 *       200:
 *         description: Refund processed
 */
export const processRefund = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const result = await disputeService.processDisputeRefund(
      req.params.id,
      req.user!.id,
      Number(req.body.amount),
    );
    sendSuccess(res, result, 'Refund processed successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * @swagger
 * /admin/disputes/{id}/messages:
 *   post:
 *     summary: Send a message from admin/mediator in a dispute thread
 *     tags: [Disputes - Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string, format: uuid }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [content]
 *             properties:
 *               content:
 *                 type: string
 *                 maxLength: 2000
 *     responses:
 *       201:
 *         description: Message sent
 */
export const adminSendMessage = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  try {
    const message = await disputeService.adminSendMessage(
      req.params.id,
      req.user!.id,
      req.body.content,
    );
    sendCreated(res, message, 'Message sent successfully');
  } catch (err) {
    next(err);
  }
};
