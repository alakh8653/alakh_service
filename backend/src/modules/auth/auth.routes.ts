import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { authenticate } from '../../middleware/authenticate';
import { validate } from '../../middleware/validate';
import { authController } from './auth.controller';
import {
  changePasswordSchema,
  forgotPasswordSchema,
  loginSchema,
  refreshTokenSchema,
  registerSchema,
  resetPasswordSchema,
  sendOTPSchema,
  socialLoginSchema,
  verifyOTPSchema,
} from './auth.validators';

const router = Router();

// ─── Route-level rate limiters ────────────────────────────────────────────────

/** Strict limiter for credential-submission endpoints (login, register). */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many attempts, please try again later.' },
});

/** Very strict limiter for OTP endpoints to prevent enumeration / SMS abuse. */
const otpLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many OTP requests, please wait before retrying.' },
});

/** Moderate limiter for token refresh and password-reset flows. */
const tokenLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});

/** Limiter for authenticated session-management endpoints. */
const sessionLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});

// ─── Public routes ───────────────────────────────────────────────────────────

router.post('/register', authLimiter, validate(registerSchema), authController.register);
router.post('/login', authLimiter, validate(loginSchema), authController.login);
router.post('/login/otp/send', otpLimiter, validate(sendOTPSchema), authController.sendLoginOTP);
router.post('/login/otp/verify', otpLimiter, validate(verifyOTPSchema), authController.verifyLoginOTP);
router.post('/refresh', tokenLimiter, validate(refreshTokenSchema), authController.refreshToken);
router.post('/forgot-password', otpLimiter, validate(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', otpLimiter, validate(resetPasswordSchema), authController.resetPassword);
router.post('/resend-otp', otpLimiter, validate(sendOTPSchema), authController.resendOTP);
router.post('/social/:provider', authLimiter, validate(socialLoginSchema), authController.socialLogin);

// ─── Protected routes (require valid access token) ───────────────────────────

router.post('/logout', sessionLimiter, authenticate, authController.logout);
router.post('/logout/all', sessionLimiter, authenticate, authController.logoutAll);
router.post('/change-password', sessionLimiter, authenticate, validate(changePasswordSchema), authController.changePassword);
router.post('/verify-email', sessionLimiter, authenticate, authController.verifyEmail);
router.post('/verify-phone', sessionLimiter, authenticate, authController.verifyPhone);
router.get('/me', sessionLimiter, authenticate, authController.getMe);

export default router;
