import { Router } from 'express';
import { authenticate } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate.middleware';
import {
  createConversationSchema,
  sendMessageSchema,
  messagesQuerySchema,
  reportConversationSchema,
} from './chat.validators';
import * as ctrl from './chat.controller';

const router = Router();

/** All chat routes require authentication */
router.use(authenticate);

/** List user's conversations */
router.get('/chat/conversations', ctrl.getConversations);

/** Create / get a direct conversation */
router.post(
  '/chat/conversations',
  validate(createConversationSchema),
  ctrl.createConversation,
);

/** Create / get booking conversation */
router.post(
  '/chat/conversations/booking/:bookingId',
  ctrl.createBookingConversation,
);

/** Get total unread count */
router.get('/chat/unread-count', ctrl.getUnreadCount);

/** Get conversation details */
router.get('/chat/conversations/:id', ctrl.getConversationById);

/** Get messages (cursor-based pagination) */
router.get(
  '/chat/conversations/:id/messages',
  validate(messagesQuerySchema, 'query'),
  ctrl.getMessages,
);

/** Send a text message */
router.post(
  '/chat/conversations/:id/messages',
  validate(sendMessageSchema),
  ctrl.sendMessage,
);

/** Send an image */
router.post('/chat/conversations/:id/messages/image', ctrl.sendImageMessage);

/** Send a file */
router.post('/chat/conversations/:id/messages/file', ctrl.sendFileMessage);

/** Send a voice message */
router.post('/chat/conversations/:id/messages/voice', ctrl.sendVoiceMessage);

/** Mark conversation as read */
router.put('/chat/conversations/:id/read', ctrl.markAsRead);

/** Delete a message */
router.delete(
  '/chat/conversations/:id/messages/:messageId',
  ctrl.deleteMessage,
);

/** Archive conversation */
router.put('/chat/conversations/:id/archive', ctrl.archiveConversation);

/** Unarchive conversation */
router.put('/chat/conversations/:id/unarchive', ctrl.unarchiveConversation);

/** Get shared media */
router.get('/chat/conversations/:id/media', ctrl.getSharedMedia);

/** Report conversation */
router.post(
  '/chat/conversations/:id/report',
  validate(reportConversationSchema),
  ctrl.reportConversation,
);

export default router;
