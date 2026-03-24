import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import morgan from 'morgan';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';

import { errorHandler } from './shared/errors/AppError';
import paymentsRouter from './modules/payments/payments.routes';
import reviewsRouter from './modules/reviews/reviews.routes';
import chatRouter from './modules/chat/chat.routes';
import notificationsRouter from './modules/notifications/notifications.routes';

const app = express();
const httpServer = createServer(app);

// ─── Socket.IO setup ──────────────────────────────────────────────────────────

const io = new SocketServer(httpServer, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') ?? '*',
    methods: ['GET', 'POST'],
  },
});

io.on('connection', (socket) => {
  const userId = socket.handshake.auth?.userId as string | undefined;
  if (userId) {
    socket.join(`user:${userId}`);
  }

  socket.on('join_conversation', (conversationId: string) => {
    socket.join(`conversation:${conversationId}`);
  });

  socket.on('leave_conversation', (conversationId: string) => {
    socket.leave(`conversation:${conversationId}`);
  });

  socket.on('disconnect', () => {
    // TODO: Update Redis presence key on disconnect
  });
});

// ─── Express middleware ───────────────────────────────────────────────────────

app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN?.split(',') ?? '*',
    credentials: true,
  }),
);
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// ─── Health check ─────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── API Routes ───────────────────────────────────────────────────────────────

const API_PREFIX = process.env.API_PREFIX ?? '/api/v1';

app.use(API_PREFIX, paymentsRouter);
app.use(API_PREFIX, reviewsRouter);
app.use(API_PREFIX, chatRouter);
app.use(API_PREFIX, notificationsRouter);

// ─── Global error handler ─────────────────────────────────────────────────────

app.use(errorHandler);

// ─── Start server ─────────────────────────────────────────────────────────────

const PORT = parseInt(process.env.PORT ?? '3000', 10);

httpServer.listen(PORT, () => {
  console.info(`🚀 Alakh Service API running on http://localhost:${PORT}${API_PREFIX}`);
  console.info(`🔌 Socket.IO listening on port ${PORT}`);
});

export { app, io };
