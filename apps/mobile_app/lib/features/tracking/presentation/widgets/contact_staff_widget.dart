import 'package:flutter/material.dart';

/// Widget that provides quick call and chat actions for reaching the staff.
///
/// Uses a `tel:` URI for phone calls.
/// TODO: Integrate url_launcher for native dialer support once the package
/// is added to pubspec.yaml:
/// ```dart
/// import 'package:url_launcher/url_launcher.dart';
/// await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
/// ```
class ContactStaffWidget extends StatelessWidget {
  /// The staff member's name.
  final String staffName;

  /// The staff member's phone number.
  final String phoneNumber;

  /// Creates a [ContactStaffWidget].
  const ContactStaffWidget({
    super.key,
    required this.staffName,
    required this.phoneNumber,
  });

  void _onCallPressed(BuildContext context) {
    // TODO: Replace with url_launcher call once integrated.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call $staffName on $phoneNumber')),
    );
  }

  void _onChatPressed(BuildContext context) {
    // TODO: Navigate to in-app chat with the staff member.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat with $staffName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            staffName.isNotEmpty ? staffName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(staffName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                phoneNumber,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Call $staffName',
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () => _onCallPressed(context),
        ),
        IconButton(
          tooltip: 'Chat with $staffName',
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
          onPressed: () => _onChatPressed(context),
        ),
      ],
    );
  }
}
