/// Reusable bottom sheet with drag handle and scrollable content.
library;

import 'package:flutter/material.dart';

/// Shows a styled modal bottom sheet with a drag handle and scrollable content.
///
/// Returns the value passed to [Navigator.pop], or `null` if dismissed.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? title,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  double? maxHeightFraction,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AppBottomSheet(
        title: title,
        maxHeightFraction: maxHeightFraction,
        child: builder(ctx),
      ),
    );

/// A pre-styled bottom sheet container used inside [showAppBottomSheet].
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeightFraction,
    this.padding,
    this.showDragHandle = true,
    this.showCloseButton = false,
  });

  final Widget child;
  final String? title;
  final double? maxHeightFraction;
  final EdgeInsetsGeometry? padding;
  final bool showDragHandle;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * (maxHeightFraction ?? 0.9);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (showDragHandle)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Title row
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: padding ??
                  EdgeInsets.fromLTRB(
                    16,
                    title == null ? 8 : 0,
                    16,
                    mediaQuery.viewPadding.bottom + 16,
                  ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
