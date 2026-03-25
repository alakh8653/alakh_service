import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/referral_code.dart';

/// A styled card that prominently displays the user's referral code along with
/// Copy and Share action buttons.
///
/// Tapping "Copy" writes the [ReferralCode.code] to the clipboard and shows a
/// [SnackBar] confirmation.  Tapping "Share" invokes the [onShare] callback so
/// that the parent widget can trigger the platform share sheet.
class ReferralCodeCard extends StatelessWidget {
  /// Creates a [ReferralCodeCard].
  const ReferralCodeCard({
    super.key,
    required this.referralCode,
    required this.onShare,
  });

  /// The referral code entity to display.
  final ReferralCode referralCode;

  /// Callback invoked when the user taps the Share button.
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Referral Code',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colorScheme.onPrimary.withOpacity(0.4)),
                    ),
                    child: Text(
                      referralCode.code,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _IconActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onPressed: () => _copyCode(context),
                  foregroundColor: colorScheme.onPrimary,
                ),
              ],
            ),
            if (referralCode.usesRemaining != null) ...[
              const SizedBox(height: 12),
              Text(
                '${referralCode.usesRemaining} uses remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share with Friends'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary,
                  side: BorderSide(color: colorScheme.onPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code "${referralCode.code}" copied!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Small icon button used inside [ReferralCodeCard].
class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foregroundColor, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: foregroundColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
