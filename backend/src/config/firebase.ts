import admin from 'firebase-admin';
import { env } from './env';
import { logger } from './logger';

let firebaseApp: admin.app.App | null = null;

export const initializeFirebase = (): admin.app.App | null => {
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_PRIVATE_KEY || !env.FIREBASE_CLIENT_EMAIL) {
    logger.warn('Firebase credentials not configured. Push notifications will be disabled.');
    return null;
  }

  if (admin.apps.length > 0) {
    firebaseApp = admin.apps[0] ?? null;
    return firebaseApp;
  }

  try {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.FIREBASE_PROJECT_ID,
        privateKeyId: env.FIREBASE_PRIVATE_KEY_ID,
        privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        clientEmail: env.FIREBASE_CLIENT_EMAIL,
        clientId: env.FIREBASE_CLIENT_ID,
        // @ts-expect-error firebase-admin's ServiceAccount type does not include authUri/tokenUri
        // but the underlying Google credential accepts them. Remove when @firebase/app-types is updated.
        authUri: env.FIREBASE_AUTH_URI,
        tokenUri: env.FIREBASE_TOKEN_URI,
      }),
      databaseURL: env.FIREBASE_DATABASE_URL,
    });

    logger.info('✅ Firebase Admin initialized');
    return firebaseApp;
  } catch (error) {
    logger.error('❌ Firebase initialization failed:', error);
    return null;
  }
};

export const getFirebaseApp = (): admin.app.App | null => firebaseApp;

export const getMessaging = (): admin.messaging.Messaging | null => {
  if (!firebaseApp) return null;
  return admin.messaging(firebaseApp);
};

export const sendPushNotification = async (
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<boolean> => {
  const messaging = getMessaging();
  if (!messaging) return false;

  try {
    await messaging.send({
      token,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    return true;
  } catch (error) {
    logger.error('Push notification failed:', error);
    return false;
  }
};

export const sendMulticastNotification = async (
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<{ successCount: number; failureCount: number }> => {
  const messaging = getMessaging();
  if (!messaging || tokens.length === 0) return { successCount: 0, failureCount: tokens.length };

  try {
    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    logger.error('Multicast notification failed:', error);
    return { successCount: 0, failureCount: tokens.length };
  }
};
