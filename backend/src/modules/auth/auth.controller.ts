import { Request, Response } from 'express';
import { AppError } from '../../shared/errors';
import { sendError, sendSuccess } from '../../shared/response';
import { RequestWithUser } from '../../shared/types';
import { authService } from './auth.service';
import {
  ChangePasswordInput,
  ForgotPasswordInput,
  LoginInput,
  OTPInput,
  RefreshTokenInput,
  RegisterInput,
  ResetPasswordInput,
  SocialLoginInput,
} from './auth.types';

function handleError(res: Response, error: unknown): void {
  if (error instanceof AppError) {
    sendError(res, error.message, error.code, error.statusCode);
  } else {
    sendError(res, 'An unexpected error occurred', 'INTERNAL_ERROR', 500);
  }
}

/** POST /register */
async function register(req: Request, res: Response): Promise<void> {
  try {
    const result = await authService.register(req.body as RegisterInput);
    sendSuccess(res, result, 'Registration successful', 201);
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /login */
async function login(req: Request, res: Response): Promise<void> {
  try {
    const result = await authService.login(req.body as LoginInput);
    sendSuccess(res, result, 'Login successful');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /login/otp/send */
async function sendLoginOTP(req: Request, res: Response): Promise<void> {
  try {
    await authService.sendLoginOTP(req.body as OTPInput);
    sendSuccess(res, null, 'OTP sent successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /login/otp/verify */
async function verifyLoginOTP(req: Request, res: Response): Promise<void> {
  try {
    const result = await authService.verifyLoginOTP(req.body as OTPInput);
    sendSuccess(res, result, 'OTP verified successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /refresh */
async function refreshToken(req: Request, res: Response): Promise<void> {
  try {
    const { refreshToken: token } = req.body as RefreshTokenInput;
    const tokens = await authService.refreshToken(token);
    sendSuccess(res, tokens, 'Token refreshed successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /logout — requires authenticate middleware */
async function logout(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    const { refreshToken: token } = req.body as { refreshToken?: string };
    if (!token) {
      sendError(res, 'Refresh token is required', 'BAD_REQUEST', 400);
      return;
    }
    await authService.logout(userId, token);
    sendSuccess(res, null, 'Logged out successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /logout/all — requires authenticate middleware */
async function logoutAll(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    await authService.logoutAll(userId);
    sendSuccess(res, null, 'Logged out from all devices');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /forgot-password */
async function forgotPassword(req: Request, res: Response): Promise<void> {
  try {
    await authService.forgotPassword(req.body as ForgotPasswordInput);
    // Always respond with the same message to prevent user enumeration
    sendSuccess(res, null, 'If an account exists, a reset OTP has been sent');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /reset-password */
async function resetPassword(req: Request, res: Response): Promise<void> {
  try {
    await authService.resetPassword(req.body as ResetPasswordInput);
    sendSuccess(res, null, 'Password reset successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /change-password — requires authenticate middleware */
async function changePassword(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    await authService.changePassword(userId, req.body as ChangePasswordInput);
    sendSuccess(res, null, 'Password changed successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /verify-email — requires authenticate middleware */
async function verifyEmail(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    const { otp } = req.body as { otp?: string };
    if (!otp) {
      sendError(res, 'OTP is required', 'BAD_REQUEST', 400);
      return;
    }
    await authService.verifyEmail(userId, otp);
    sendSuccess(res, null, 'Email verified successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /verify-phone — requires authenticate middleware */
async function verifyPhone(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    const { otp } = req.body as { otp?: string };
    if (!otp) {
      sendError(res, 'OTP is required', 'BAD_REQUEST', 400);
      return;
    }
    await authService.verifyPhone(userId, otp);
    sendSuccess(res, null, 'Phone number verified successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /resend-otp */
async function resendOTP(req: Request, res: Response): Promise<void> {
  try {
    await authService.sendLoginOTP(req.body as OTPInput);
    sendSuccess(res, null, 'OTP resent successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** GET /me — requires authenticate middleware */
async function getMe(req: Request, res: Response): Promise<void> {
  try {
    const { id: userId } = (req as RequestWithUser).user;
    const user = await authService.getMe(userId);
    sendSuccess(res, user, 'Profile retrieved successfully');
  } catch (error) {
    handleError(res, error);
  }
}

/** POST /social/:provider */
async function socialLogin(req: Request, res: Response): Promise<void> {
  try {
    const body = req.body as SocialLoginInput;
    const result = await authService.socialLogin(body);
    sendSuccess(res, result, 'Social login successful');
  } catch (error) {
    handleError(res, error);
  }
}

export const authController = {
  register,
  login,
  sendLoginOTP,
  verifyLoginOTP,
  refreshToken,
  logout,
  logoutAll,
  forgotPassword,
  resetPassword,
  changePassword,
  verifyEmail,
  verifyPhone,
  resendOTP,
  getMe,
  socialLogin,
};
