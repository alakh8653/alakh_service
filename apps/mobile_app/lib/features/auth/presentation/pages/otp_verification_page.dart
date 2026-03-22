import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// OTP verification page for phone number confirmation.
class OtpVerificationPage extends StatefulWidget {
  /// The phone number that received the OTP.
  final String phone;

  const OtpVerificationPage({super.key, required this.phone});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  String _otp = '';
  bool _canResend = false;
  int _resendCountdownSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdownSeconds > 0) {
          _resendCountdownSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onVerify() {
    if (_otp.length == 6) {
      context.read<AuthBloc>().add(
            OtpVerifyRequested(phone: widget.phone, otp: _otp),
          );
    }
  }

  void _onResendOtp() {
    // TODO: Implement resend OTP via your backend API.
    setState(() {
      _canResend = false;
      _resendCountdownSeconds = 60;
    });
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            // TODO: Navigate to home or next onboarding step.
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  AuthHeader(
                    title: 'Enter OTP',
                    subtitle:
                        'A 6-digit code was sent to\n${widget.phone}',
                  ),
                  const SizedBox(height: 40),
                  OtpInputField(
                    onCompleted: (otp) {
                      setState(() => _otp = otp);
                      _onVerify();
                    },
                    onChanged: (otp) => setState(() => _otp = otp),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed:
                        (isLoading || _otp.length < 6) ? null : _onVerify,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Didn't receive the code?",
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: _canResend ? _onResendOtp : null,
                        child: Text(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend in ${_resendCountdownSeconds}s',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
