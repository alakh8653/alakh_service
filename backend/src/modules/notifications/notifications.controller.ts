import { Request, Response, NextFunction } from 'express';
import { NotificationsService } from './notifications.service';
import { HttpStatus } from '../../shared/errors/AppError';

const service = new NotificationsService();

/** GET /api/v1/notifications */
export async function getUserNotifications(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { category, isRead, page, perPage } = req.query as Record<
      string,
      string
    >;
    const result = await service.getUserNotifications(req.user!.userId, {
      category: category as never,
      isRead: isRead !== undefined ? isRead === 'true' : undefined,
      page: parseInt(page ?? '1', 10),
      perPage: parseInt(perPage ?? '20', 10),
    });
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/notifications/unread-count */
export async function getUnreadCount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const count = await service.getUnreadCount(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: { count } });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/notifications/:id/read */
export async function markAsRead(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.markAsRead(req.user!.userId, req.params.id);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/notifications/read-all */
export async function markAllRead(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.markAllRead(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/notifications/:id */
export async function deleteNotification(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.deleteNotification(req.user!.userId, req.params.id);
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/notifications/clear */
export async function clearNotifications(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.clearReadNotifications(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/notifications/preferences */
export async function getPreferences(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getPreferences(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/notifications/preferences */
export async function updatePreferences(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.updatePreferences(
      req.user!.userId,
      req.body.preferences,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/notifications/fcm-token */
export async function registerFCMToken(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.registerFCMToken(req.user!.userId, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/notifications/fcm-token */
export async function removeFCMToken(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.removeFCMToken(req.user!.userId, req.body.token);
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

// ─── Admin handlers ───────────────────────────────────────────────────────────

/** POST /api/v1/admin/notifications/send */
export async function adminSendNotification(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.sendNotification(req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/admin/notifications/broadcast */
export async function adminBroadcast(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.broadcastNotification(req.body);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/admin/notifications/stats */
export async function adminGetStats(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const period = parseInt((req.query.period as string) ?? '30', 10);
    const result = await service.getDeliveryStats(period);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}
