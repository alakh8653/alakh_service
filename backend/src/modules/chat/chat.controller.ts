import { Request, Response, NextFunction } from 'express';
import { ChatService } from './chat.service';
import { HttpStatus } from '../../shared/errors/AppError';

const service = new ChatService();

/** GET /api/v1/chat/conversations */
export async function getConversations(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const page = parseInt((req.query.page as string) ?? '1', 10);
    const perPage = parseInt((req.query.perPage as string) ?? '20', 10);
    const result = await service.getConversations(
      req.user!.userId,
      page,
      perPage,
    );
    res.status(HttpStatus.OK).json({ success: true, ...result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations */
export async function createConversation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.createOrGetConversation(
      req.user!.userId,
      req.body.participantId,
      req.body.type,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/chat/conversations/:id */
export async function getConversationById(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getConversationById(
      req.params.id,
      req.user!.userId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/chat/conversations/:id/messages */
export async function getMessages(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const cursor = req.query.cursor as string | undefined;
    const limit = parseInt((req.query.limit as string) ?? '30', 10);
    const result = await service.getMessages(
      req.params.id,
      req.user!.userId,
      cursor,
      limit,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/:id/messages */
export async function sendMessage(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.sendMessage(
      req.params.id,
      req.user!.userId,
      req.body,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/:id/messages/image */
export async function sendImageMessage(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    // TODO: Handle multipart/form-data via multer middleware
    const { fileUrl, fileName, fileSize, mimeType } = req.body as {
      fileUrl: string;
      fileName: string;
      fileSize: number;
      mimeType: string;
    };
    const result = await service.sendMediaMessage(
      req.params.id,
      req.user!.userId,
      fileUrl,
      fileName,
      fileSize,
      mimeType,
      'IMAGE',
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/:id/messages/file */
export async function sendFileMessage(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { fileUrl, fileName, fileSize, mimeType } = req.body as {
      fileUrl: string;
      fileName: string;
      fileSize: number;
      mimeType: string;
    };
    const result = await service.sendMediaMessage(
      req.params.id,
      req.user!.userId,
      fileUrl,
      fileName,
      fileSize,
      mimeType,
      'FILE',
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/:id/messages/voice */
export async function sendVoiceMessage(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const { fileUrl, fileName, fileSize, mimeType } = req.body as {
      fileUrl: string;
      fileName: string;
      fileSize: number;
      mimeType: string;
    };
    const result = await service.sendMediaMessage(
      req.params.id,
      req.user!.userId,
      fileUrl,
      fileName,
      fileSize,
      mimeType,
      'VOICE',
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/chat/conversations/:id/read */
export async function markAsRead(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    await service.markAsRead(req.params.id, req.user!.userId);
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/v1/chat/conversations/:id/messages/:messageId */
export async function deleteMessage(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.deleteMessage(
      req.params.id,
      req.user!.userId,
      req.params.messageId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/chat/conversations/:id/archive */
export async function archiveConversation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.archiveConversation(
      req.params.id,
      req.user!.userId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** PUT /api/v1/chat/conversations/:id/unarchive */
export async function unarchiveConversation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.unarchiveConversation(
      req.params.id,
      req.user!.userId,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/chat/conversations/:id/media */
export async function getSharedMedia(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const page = parseInt((req.query.page as string) ?? '1', 10);
    const perPage = parseInt((req.query.perPage as string) ?? '20', 10);
    const result = await service.getSharedMedia(
      req.params.id,
      req.user!.userId,
      page,
      perPage,
    );
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** GET /api/v1/chat/unread-count */
export async function getUnreadCount(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.getUnreadCount(req.user!.userId);
    res.status(HttpStatus.OK).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/booking/:bookingId */
export async function createBookingConversation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.createBookingConversation(
      req.user!.userId,
      req.params.bookingId,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

/** POST /api/v1/chat/conversations/:id/report */
export async function reportConversation(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const result = await service.reportConversation(
      req.params.id,
      req.user!.userId,
      req.body.reason,
      req.body.details,
    );
    res.status(HttpStatus.CREATED).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}
