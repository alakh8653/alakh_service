import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/referral_code.dart';

/// A modal bottom sheet that provides share-action options for the user's
/// referral code.
///
/// Shows dedicated buttons for WhatsApp and a generic "More" option, plus a
/// "Copy Link" action.  Call [ShareReferralSheet.show] to present the sheet.
class ShareReferralSheet extends StatelessWidget {
  /// Creates a [ShareReferralSheet].
  const ShareReferralSheet({
    super.key,
    required this.referralCode,
    required this.shareContent,
    required this.onShareViaWhatsApp,
    required this.onShareMore,
  });

  /// The referral code used to populate the copy-link action.
  final ReferralCode referralCode;

  /// Pre-generated share content string (deep-link + message).
  final String shareContent;

  /// Callback when the user taps "Share via WhatsApp".
  final VoidCallback onShareViaWhatsApp;

  /// Callback when the user taps the generic "More" share option.
  final VoidCallback onShareMore;

  /// Convenience method to show the sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required ReferralCode referralCode,
    required String shareContent,
    required VoidCallback onShareViaWhatsApp,
    required VoidCallback onShareMore,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ShareReferralSheet(
        referralCode: referralCode,
        shareContent: shareContent,
        onShareViaWhatsApp: onShareViaWhatsApp,
        onShareMore: onShareMore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Your Code',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Invite friends and earn rewards when they book.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.chat_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.of(context).pop();
                    onShareViaWhatsApp();
                  },
                ),
                _ShareOption(
                  icon: Icons.link_rounded,
                  label: 'Copy Link',
                  color: theme.colorScheme.primary,
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: referralCode.deepLink));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  color: theme.colorScheme.secondary,
                  onTap: () {
                    Navigator.of(context).pop();
                    onShareMore();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shareContent,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareContent));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message copied!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
