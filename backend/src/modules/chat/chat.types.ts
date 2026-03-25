import { ConversationType, MessageType } from '@prisma/client';

// ─── Input types ──────────────────────────────────────────────────────────────

/** Input for creating / retrieving a conversation */
export interface CreateConversationInput {
  participantId: string;
  type?: ConversationType;
}

/** Input for sending a message */
export interface SendMessageInput {
  content: string;
  type?: MessageType;
  metadata?: Record<string, unknown>;
}

// ─── Output types ─────────────────────────────────────────────────────────────

/** Conversation with last message, unread count, and participant info */
export interface ConversationWithDetails {
  id: string;
  type: ConversationType;
  bookingId?: string;
  lastMessageAt?: Date;
  participants: Array<{
    userId: string;
    lastReadAt?: Date;
    isArchived: boolean;
    user: { id: string; name: string };
  }>;
  lastMessage?: {
    id: string;
    content?: string;
    type: MessageType;
    senderId: string;
    createdAt: Date;
  } | null;
  unreadCount: number;
}

/** Message with sender info and attachments */
export interface MessageWithSender {
  id: string;
  conversationId: string;
  senderId: string;
  content?: string;
  type: MessageType;
  metadata?: Record<string, unknown>;
  deletedAt?: Date;
  createdAt: Date;
  sender: { id: string; name: string };
  attachments: Array<{
    id: string;
    url: string;
    type: string;
    name?: string;
    size?: number;
    mimeType?: string;
    thumbnail?: string;
  }>;
}

/** Shared media item in a conversation */
export interface ChatMediaItem {
  id: string;
  messageId: string;
  url: string;
  type: string;
  name?: string;
  size?: number;
  mimeType?: string;
  thumbnail?: string;
  createdAt: Date;
}

/** Total unread counts across all conversations */
export interface UnreadCounts {
  total: number;
  byConversation: Record<string, number>;
}

/** Cursor-based pagination for messages */
export interface MessagesPagination {
  cursor?: string;
  limit?: number;
}
