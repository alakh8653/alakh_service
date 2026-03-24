import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';
import { prisma } from '../config/database';

interface AuditOptions {
  action: string;
  resource: string;
}

export const auditLog = (options: AuditOptions) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const originalJson = res.json.bind(res);

    res.json = function (body: unknown) {
      const statusCode = res.statusCode;
      const success = statusCode >= 200 && statusCode < 300;

      // Fire-and-forget audit log
      if (req.user) {
        prisma.auditLog
          .create({
            data: {
              userId: req.user.id,
              action: options.action,
              resource: options.resource,
              resourceId: req.params['id'] ?? null,
              success,
              statusCode,
              ipAddress: req.ip ?? null,
              userAgent: req.headers['user-agent'] ?? null,
              requestId: req.requestId ?? null,
              metadata: {
                method: req.method,
                path: req.path,
                query: req.query,
              },
            },
          })
          .catch((err) => logger.warn('Audit log failed:', err));
      }

      return originalJson(body);
    };

    next();
  };
};
