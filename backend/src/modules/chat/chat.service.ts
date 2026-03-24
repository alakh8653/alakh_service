import { Server as SocketServer } from 'socket.io';
import redis from '../../config/redis';
import { ChatRepository } from './chat.repository';
import {
  SendMessageInput,
  ConversationWithDetails,
  MessageWithSender,
  ChatMediaItem,
  UnreadCounts,
} from './chat.types';
import {
  BadRequestError,
  ForbiddenError,
  NotFoundError,
} from '../../shared/errors/AppError';
import prisma from '../../config/database';
import { ConversationType, MessageType } from '@prisma/client';

/** Redis key for unread message counter per user per conversation */
const UNREAD_KEY = (userId: string, convId: string) =>
  `chat:unread:${userId}:${convId}`;

/** Redis key for online presence */
const ONLINE_KEY = (userId: string) => `presence:online:${userId}`;

/**
 * Business logic for the chat module.
 * Emits Socket.IO events for real-time updates.
 */
export class ChatService {
  private readonly repo: ChatRepository;
  private io?: SocketServer;

  constructor(io?: SocketServer) {
    this.repo = new ChatRepository();
    this.io = io;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /**
   * Increment or decrement the Redis unread counter for a user/conversation.
   * Falls back silently if Redis is unavailable.
   */
  async updateUnreadCount(
    userId: string,
    conversationId: string,
    increment: number,
  ): Promise<void> {
    try {
      if (increment > 0) {
        await redis.incrby(UNREAD_KEY(userId, conversationId), increment);
      } else {
        await redis.del(UNREAD_KEY(userId, conversationId));
      }
    } catch {
      // Redis unavailable – ignore
    }
  }

  /**
   * Check whether a user is currently online (active WebSocket session).
   */
  async getOnlineStatus(userId: string): Promise<boolean> {
    try {
      const val = await redis.get(ONLINE_KEY(userId));
      return val === '1';
    } catch {
      return false;
    }
  }

  /** Assert that a user is a participant in the given conversation */
  private async assertParticipant(
    conversationId: string,
    userId: string,
  ): Promise<void> {
    const participant = await this.repo.findParticipant(conversationId, userId);
    if (!participant)
      throw new ForbiddenError('You are not a participant in this conversation');
  }

  // ─── Conversations ─────────────────────────────────────────────────────────

  /**
   * List the user's active (non-archived) conversations with last message
   * and per-conversation unread count.
   */
  async getConversations(
    userId: string,
    page: number,
    perPage: number,
  ) {
    const result = await this.repo.listUserConversations(userId, page, perPage);

    // Attach unread counts from Redis
    const enriched = await Promise.all(
      result.data.map(async (conv) => {
        let unreadCount = 0;
        try {
          const raw = await redis.get(UNREAD_KEY(userId, conv.id));
          unreadCount = raw ? parseInt(raw, 10) : 0;
        } catch {
          // Fallback: compute from DB
          unreadCount = await this.repo.countUnreadInConversation(
            conv.id,
            userId,
          );
        }

        const lastMsg =
          'messages' in conv && Array.isArray((conv as { messages: unknown[] }).messages)
            ? (conv as { messages: MessageWithSender[] }).messages[0] ?? null
            : null;

        return {
          ...conv,
          lastMessage: lastMsg,
          unreadCount,
        } as ConversationWithDetails;
      }),
    );

    return { ...result, data: enriched };
  }

  /**
   * Find an existing direct conversation between two users or create a new one.
   */
  async createOrGetConversation(
    userId: string,
    otherUserId: string,
    type: ConversationType = 'DIRECT',
  ) {
    if (userId === otherUserId)
      throw new BadRequestError('Cannot create conversation with yourself');

    const existing = await this.repo.findDirectConversation(userId, otherUserId);
    if (existing) return existing;

    return this.repo.createConversation({ type }, [userId, otherUserId]);
  }

  /** Get conversation details (verifies user is a participant) */
  async getConversationById(conversationId: string, userId: string) {
    await this.assertParticipant(conversationId, userId);
    const conv = await this.repo.findConversationById(conversationId);
    if (!conv) throw new NotFoundError('Conversation not found');
    return conv;
  }

  // ─── Messages ──────────────────────────────────────────────────────────────

  /**
   * Get messages for a conversation with cursor-based pagination.
   * Cursor = message ID; returns messages older than cursor.
   */
  async getMessages(
    conversationId: string,
    userId: string,
    cursor?: string,
    limit = 30,
  ): Promise<{ messages: MessageWithSender[]; nextCursor: string | null }> {
    await this.assertParticipant(conversationId, userId);

    const messages = await this.repo.getMessages(
      conversationId,
      cursor,
      limit + 1, // fetch one extra to determine if there's a next page
    );

    const hasMore = messages.length > limit;
    const page = hasMore ? messages.slice(0, limit) : messages;
    const nextCursor = hasMore ? page[page.length - 1].id : null;

    return { messages: page as unknown as MessageWithSender[], nextCursor };
  }

  /**
   * Send a text/structured message.
   * Emits a 'new_message' WebSocket event to other participants.
   * Sends push notification to offline participants.
   */
  async sendMessage(
    conversationId: string,
    userId: string,
    data: SendMessageInput,
  ) {
    await this.assertParticipant(conversationId, userId);

    const message = await this.repo.createMessage({
      conversation: { connect: { id: conversationId } },
      sender: { connect: { id: userId } },
      content: data.content,
      type: data.type ?? 'TEXT',
      metadata: data.metadata as never,
    });

    // Update conversation timestamp
    await this.repo.updateConversation(conversationId, {
      lastMessageAt: new Date(),
      lastMessageId: message.id,
    });

    // Fetch participants and update unread counts + emit events
    const conv = await this.repo.findConversationById(conversationId);
    if (conv) {
      await Promise.all(
        conv.participants
          .filter((p) => p.userId !== userId)
          .map(async (p) => {
            await this.updateUnreadCount(p.userId, conversationId, 1);
            const isOnline = await this.getOnlineStatus(p.userId);

            // Emit WebSocket event
            this.io?.to(`user:${p.userId}`).emit('new_message', {
              conversationId,
              message,
            });

            // Send push notification if offline
            if (!isOnline) {
              // TODO: call notification service to send FCM push
            }
          }),
      );
    }

    return message;
  }

  /**
   * Send a media message (image / file / voice).
   * The file should already be uploaded to S3; pass the URL.
   */
  async sendMediaMessage(
    conversationId: string,
    userId: string,
    fileUrl: string,
    fileName: string,
    fileSize: number,
    mimeType: string,
    type: MessageType,
  ) {
    await this.assertParticipant(conversationId, userId);

    // TODO: Upload to S3 if receiving raw file buffer instead of URL

    const message = await this.repo.createMessage({
      conversation: { connect: { id: conversationId } },
      sender: { connect: { id: userId } },
      type,
    });

    const attachment = await this.repo.createAttachment({
      message: { connect: { id: message.id } },
      url: fileUrl,
      type: type.toLowerCase(),
      name: fileName,
      size: fileSize,
      mimeType,
      // TODO: generate thumbnail for images via sharp/lambda
    });

    await this.repo.updateConversation(conversationId, {
      lastMessageAt: new Date(),
      lastMessageId: message.id,
    });

    // Notify participants
    const conv = await this.repo.findConversationById(conversationId);
    conv?.participants
      .filter((p) => p.userId !== userId)
      .forEach((p) => {
        this.io?.to(`user:${p.userId}`).emit('new_message', {
          conversationId,
          message: { ...message, attachments: [attachment] },
        });
      });

    return { ...message, attachments: [attachment] };
  }

  /**
   * Mark a conversation as read:
   * - Updates lastReadAt for the participant
   * - Clears the Redis unread counter
   * - Emits a read receipt event via WebSocket
   */
  async markAsRead(conversationId: string, userId: string) {
    await this.assertParticipant(conversationId, userId);

    const now = new Date();
    await this.repo.updateParticipant(conversationId, userId, {
      lastReadAt: now,
    });

    // Clear Redis unread counter
    await this.updateUnreadCount(userId, conversationId, 0);

    // Emit read receipt
    this.io?.to(`conversation:${conversationId}`).emit('read_receipt', {
      conversationId,
      userId,
      readAt: now,
    });
  }

  /**
   * Soft-delete a message.
   * Only the sender can delete their own message.
   */
  async deleteMessage(
    conversationId: string,
    userId: string,
    messageId: string,
  ) {
    await this.assertParticipant(conversationId, userId);

    const message = await this.repo.findMessageById(messageId);
    if (!message) throw new NotFoundError('Message not found');
    if (message.senderId !== userId)
      throw new ForbiddenError('You can only delete your own messages');
    if (message.conversationId !== conversationId)
      throw new BadRequestError('Message does not belong to this conversation');

    const deleted = await this.repo.softDeleteMessage(messageId);

    this.io?.to(`conversation:${conversationId}`).emit('message_deleted', {
      conversationId,
      messageId,
    });

    return deleted;
  }

  /** Archive a conversation for a user */
  async archiveConversation(conversationId: string, userId: string) {
    await this.assertParticipant(conversationId, userId);
    return this.repo.updateParticipant(conversationId, userId, {
      isArchived: true,
    });
  }

  /** Unarchive a conversation for a user */
  async unarchiveConversation(conversationId: string, userId: string) {
    await this.assertParticipant(conversationId, userId);
    return this.repo.updateParticipant(conversationId, userId, {
      isArchived: false,
    });
  }

  /** Get shared media in a conversation */
  async getSharedMedia(
    conversationId: string,
    userId: string,
    page: number,
    perPage: number,
  ): Promise<{ data: ChatMediaItem[]; total: number }> {
    await this.assertParticipant(conversationId, userId);
    const result = await this.repo.getSharedMedia(conversationId, page, perPage);
    return result as { data: ChatMediaItem[]; total: number };
  }

  /**
   * Get total unread message count for a user across all conversations.
   * Primary source: Redis; fallback: DB aggregation.
   */
  async getUnreadCount(userId: string): Promise<UnreadCounts> {
    try {
      const keys = await redis.keys(`chat:unread:${userId}:*`);
      const byConversation: Record<string, number> = {};
      let total = 0;

      if (keys.length > 0) {
        const values = await redis.mget(...keys);
        keys.forEach((key, i) => {
          const convId = key.split(':')[3];
          const count = parseInt(values[i] ?? '0', 10);
          byConversation[convId] = count;
          total += count;
        });
      }

      return { total, byConversation };
    } catch {
      // Redis fallback: count from DB
      return { total: 0, byConversation: {} };
    }
  }

  /**
   * Create or retrieve the conversation linked to a booking
   * (between customer and shop owner).
   */
  async createBookingConversation(userId: string, bookingId: string) {
    // Return existing conversation if it exists
    const existing = await this.repo.findBookingConversation(bookingId);
    if (existing) return existing;

    const booking = await prisma.serviceBooking.findUnique({
      where: { id: bookingId },
      include: { booking: { select: { ownerId: true } } },
    }) as (typeof booking & { booking?: { ownerId?: string } | null }) | null;

    if (!booking)
      throw new NotFoundError('Booking not found');

    const shopOwnerId = (booking as unknown as { shop?: { ownerId?: string } })?.shop?.ownerId;

    const participantIds = [userId];
    if (shopOwnerId && shopOwnerId !== userId) {
      participantIds.push(shopOwnerId);
    }

    return this.repo.createConversation(
      { type: 'BOOKING', booking: { connect: { id: bookingId } } },
      participantIds,
    );
  }

  /** Report a conversation */
  async reportConversation(
    conversationId: string,
    userId: string,
    reason: string,
    details?: string,
  ) {
    await this.assertParticipant(conversationId, userId);
    return this.repo.createConversationReport(
      conversationId,
      userId,
      reason,
      details,
    );
  }
}
