import { z } from 'zod';
import { ConversationType, MessageType } from '@prisma/client';

/** Create or get a direct conversation */
export const createConversationSchema = z.object({
  participantId: z.string().uuid('Invalid participant ID'),
  type: z.nativeEnum(ConversationType).optional(),
});

/** Send a text message */
export const sendMessageSchema = z.object({
  content: z.string().min(1).max(5000),
  type: z.nativeEnum(MessageType).optional().default('TEXT'),
  metadata: z.record(z.unknown()).optional(),
});

/** Cursor-based message pagination */
export const messagesQuerySchema = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(30),
});

/** Report a conversation / user */
export const reportConversationSchema = z.object({
  reason: z.string().min(5, 'Please provide a reason').max(200),
  details: z.string().max(1000).optional(),
});

export type CreateConversationDto = z.infer<typeof createConversationSchema>;
export type SendMessageDto = z.infer<typeof sendMessageSchema>;
export type MessagesQueryDto = z.infer<typeof messagesQuerySchema>;
export type ReportConversationDto = z.infer<typeof reportConversationSchema>;
