import 'package:flutter/material.dart';

/// A widget that displays social login buttons (Google, Apple, Facebook).
class SocialLoginButtons extends StatelessWidget {
  /// Callback when the Google sign-in button is tapped.
  final VoidCallback? onGoogleTap;

  /// Callback when the Apple sign-in button is tapped.
  final VoidCallback? onAppleTap;

  /// Callback when the Facebook sign-in button is tapped.
  final VoidCallback? onFacebookTap;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onAppleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (onGoogleTap != null)
          _SocialButton(
            label: 'Continue with Google',
            // TODO: Replace with actual Google logo asset: 'assets/icons/google.png'
            icon: Icons.g_mobiledata,
            onTap: onGoogleTap!,
            backgroundColor: Colors.white,
            textColor: Colors.black87,
            borderColor: Colors.grey.shade300,
          ),
        if (onAppleTap != null) ...[
          const SizedBox(height: 12),
          _SocialButton(
            label: 'Continue with Apple',
            // TODO: Replace with Apple logo asset when on iOS.
            icon: Icons.apple,
            onTap: onAppleTap!,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          ),
        ],
        if (onFacebookTap != null) ...[
          const SizedBox(height: 12),
          _SocialButton(
            label: 'Continue with Facebook',
            // TODO: Replace with Facebook logo asset.
            icon: Icons.facebook,
            onTap: onFacebookTap!,
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
