/// Enhanced list tile with leading, title, subtitle, trailing, and callbacks.
library;

import 'package:flutter/material.dart';

/// A styled list tile with a leading icon/widget, title, subtitle, and
/// optional trailing widget.
///
/// ### Usage:
/// ```dart
/// AppListTile(
///   leading: const Icon(Icons.location_on_outlined),
///   title: 'Home',
///   subtitle: '123 Main Street',
///   trailing: const Icon(Icons.chevron_right),
///   onTap: () {},
/// )
/// ```
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.dense = false,
    this.isThreeLine = false,
    this.leadingFilled = false,
    this.contentPadding,
    this.minLeadingWidth,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.tileColor,
    this.selectedTileColor,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;
  final bool dense;
  final bool isThreeLine;

  /// When `true`, wraps the [leading] widget in a filled circle.
  final bool leadingFilled;

  final EdgeInsetsGeometry? contentPadding;
  final double? minLeadingWidth;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final Color? selectedTileColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? leadingWidget = leading;
    if (leadingFilled && leading != null) {
      leadingWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: theme.colorScheme.primary,
              size: 20,
            ),
            child: leading!,
          ),
        ),
      );
    }

    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: titleStyle ?? theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: subtitleStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              maxLines: isThreeLine ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      selected: selected,
      enabled: enabled,
      dense: dense,
      isThreeLine: isThreeLine,
      contentPadding: contentPadding,
      minLeadingWidth: minLeadingWidth,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor ??
          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : null,
    );
  }
}
