import 'package:flutter/material.dart';
import '../../domain/entities/verification.dart';
import '../../domain/entities/verification_status.dart';

class VerificationStatusTile extends StatelessWidget {
  final Verification verification;
  final VoidCallback? onTap;

  const VerificationStatusTile({
    super.key,
    required this.verification,
    this.onTap,
  });

  Color _statusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified: return Colors.green;
      case VerificationStatus.pending: return Colors.orange;
      case VerificationStatus.inReview: return Colors.blue;
      case VerificationStatus.rejected: return Colors.red;
      case VerificationStatus.expired: return Colors.grey;
      case VerificationStatus.notStarted: return Colors.grey;
    }
  }

  IconData _statusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified: return Icons.verified;
      case VerificationStatus.pending: return Icons.hourglass_empty;
      case VerificationStatus.inReview: return Icons.search;
      case VerificationStatus.rejected: return Icons.cancel;
      case VerificationStatus.expired: return Icons.timer_off;
      case VerificationStatus.notStarted: return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(verification.status);
    return ListTile(
      leading: Text(
        verification.type.icon,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(verification.type.displayName),
      subtitle: Text(verification.status.displayName),
      trailing: Icon(_statusIcon(verification.status), color: color),
      onTap: onTap,
    );
  }
}
