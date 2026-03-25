import prisma from '../../config/database';
import { Message, Prisma } from '@prisma/client';

/**
 * Data-access layer for the chat module.
 */
export class ChatRepository {
  // ─── Conversations ──────────────────────────────────────────────────────────

  /** List all conversations for a user, including participants and last message */
  async listUserConversations(userId: string, page: number, perPage: number) {
    // Fetch participant records for the user
    const participantRecords = await prisma.conversationParticipant.findMany({
      where: { userId, isArchived: false },
      orderBy: { conversation: { lastMessageAt: 'desc' } },
      skip: (page - 1) * perPage,
      take: perPage,
      include: {
        conversation: {
          include: {
            participants: {
              include: { user: { select: { id: true, name: true } } },
            },
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
            },
          },
        },
      },
    });

    const total = await prisma.conversationParticipant.count({
      where: { userId, isArchived: false },
    });

    return {
      data: participantRecords.map((pr) => pr.conversation),
      total,
      page,
      perPage,
      totalPages: Math.ceil(total / perPage),
    };
  }

  /** Find a direct conversation between two users */
  async findDirectConversation(userA: string, userB: string) {
    return prisma.conversation.findFirst({
      where: {
        type: 'DIRECT',
        participants: {
          every: {
            userId: { in: [userA, userB] },
          },
        },
      },
      include: {
        participants: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
    });
  }

  /** Find a booking conversation */
  async findBookingConversation(bookingId: string) {
    return prisma.conversation.findUnique({
      where: { bookingId },
      include: {
        participants: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
    });
  }

  /** Create a conversation with initial participants */
  async createConversation(
    data: Prisma.ConversationCreateInput,
    participantIds: string[],
  ) {
    return prisma.conversation.create({
      data: {
        ...data,
        participants: {
          create: participantIds.map((userId) => ({ userId })),
        },
      },
      include: {
        participants: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
    });
  }

  /** Get full conversation detail for a participant */
  async findConversationById(id: string) {
    return prisma.conversation.findUnique({
      where: { id },
      include: {
        participants: {
          include: { user: { select: { id: true, name: true } } },
        },
      },
    });
  }

  /** Verify that a user is a participant in a conversation */
  async findParticipant(conversationId: string, userId: string) {
    return prisma.conversationParticipant.findUnique({
      where: { conversationId_userId: { conversationId, userId } },
    });
  }

  /** Update a participant record */
  async updateParticipant(
    conversationId: string,
    userId: string,
    data: Prisma.ConversationParticipantUpdateInput,
  ) {
    return prisma.conversationParticipant.update({
      where: { conversationId_userId: { conversationId, userId } },
      data,
    });
  }

  /** Update conversation metadata (e.g., lastMessageAt) */
  async updateConversation(
    id: string,
    data: Prisma.ConversationUpdateInput,
  ) {
    return prisma.conversation.update({ where: { id }, data });
  }

  // ─── Messages ───────────────────────────────────────────────────────────────

  /**
   * Cursor-based message pagination (newest-first within the cursor window).
   * @param conversationId  - Conversation to load messages for
   * @param cursor          - Message ID to start *before* (for older messages)
   * @param limit           - Number of messages per page
   */
  async getMessages(
    conversationId: string,
    cursor: string | undefined,
    limit: number,
  ): Promise<Message[]> {
    const cursorWhere: Prisma.MessageWhereInput = cursor
      ? { id: { lt: cursor } } // messages with IDs less than cursor (older)
      : {};

    return prisma.message.findMany({
      where: { conversationId, ...cursorWhere },
      orderBy: { createdAt: 'desc' },
      take: limit,
      include: {
        sender: { select: { id: true, name: true } },
        attachments: true,
      },
    });
  }

  /** Create a message */
  async createMessage(data: Prisma.MessageCreateInput): Promise<Message> {
    return prisma.message.create({
      data,
      include: {
        sender: { select: { id: true, name: true } },
        attachments: true,
      },
    });
  }

  /** Find a message by ID */
  async findMessageById(id: string): Promise<Message | null> {
    return prisma.message.findUnique({
      where: { id },
      include: { attachments: true },
    });
  }

  /** Soft-delete a message (clear content, set deletedAt) */
  async softDeleteMessage(id: string): Promise<Message> {
    return prisma.message.update({
      where: { id },
      data: {
        deletedAt: new Date(),
        content: 'This message was deleted',
      },
    });
  }

  /** Add an attachment to a message */
  async createAttachment(
    data: Prisma.MessageAttachmentCreateInput,
  ) {
    return prisma.messageAttachment.create({ data });
  }

  // ─── Media ──────────────────────────────────────────────────────────────────

  /** Get all media attachments in a conversation */
  async getSharedMedia(
    conversationId: string,
    page: number,
    perPage: number,
  ) {
    const where: Prisma.MessageAttachmentWhereInput = {
      message: {
        conversationId,
        deletedAt: null,
        type: { in: ['IMAGE', 'FILE', 'VOICE'] },
      },
    };

    const [data, total] = await prisma.$transaction([
      prisma.messageAttachment.findMany({
        where,
        skip: (page - 1) * perPage,
        take: perPage,
        orderBy: { message: { createdAt: 'desc' } },
        include: { message: { select: { createdAt: true } } },
      }),
      prisma.messageAttachment.count({ where }),
    ]);

    return { data, total, page, perPage, totalPages: Math.ceil(total / perPage) };
  }

  // ─── Unread (DB fallback) ───────────────────────────────────────────────────

  /**
   * Count messages after a user's lastReadAt in a conversation.
   * Used as a fallback when Redis is unavailable.
   */
  async countUnreadInConversation(
    conversationId: string,
    userId: string,
  ): Promise<number> {
    const participant = await this.findParticipant(conversationId, userId);
    if (!participant) return 0;

    return prisma.message.count({
      where: {
        conversationId,
        senderId: { not: userId },
        deletedAt: null,
        ...(participant.lastReadAt
          ? { createdAt: { gt: participant.lastReadAt } }
          : {}),
      },
    });
  }

  // ─── Reports ────────────────────────────────────────────────────────────────

  /** Create a conversation report */
  async createConversationReport(
    conversationId: string,
    reporterId: string,
    reason: string,
    details?: string,
  ) {
    return prisma.conversationReport.create({
      data: { conversationId, reporterId, reason, details },
    });
  }
}
