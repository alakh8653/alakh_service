import 'package:equatable/equatable.dart';

import 'notification_category.dart';
import 'notification_type.dart';

/// Domain entity representing a single in-app / push notification.
///
/// This is a pure Dart class with no framework dependencies so it can be
/// shared between any layer of the application.
class AppNotification extends Equatable {
  /// Unique identifier of the notification.
  final String id;

  /// Semantic type that drives routing and icon selection.
  final NotificationType type;

  /// Short headline shown in the notification tile.
  final String title;

  /// Body copy providing more detail.
  final String body;

  /// Arbitrary key-value payload attached by the backend.
  final Map<String, dynamic>? data;

  /// Optional remote image URL displayed next to the notification.
  final String? imageUrl;

  /// Whether the user has already viewed this notification.
  final bool isRead;

  /// Server-side creation timestamp.
  final DateTime createdAt;

  /// Deep-link or in-app route to navigate to on tap.
  final String? actionUrl;

  /// High-level grouping used for preference management.
  final NotificationCategory category;

  /// Creates an [AppNotification].
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
    required this.category,
  });

  /// Returns a copy of this notification with optional field overrides.
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool? isRead,
    DateTime? createdAt,
    String? actionUrl,
    NotificationCategory? category,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionUrl: actionUrl ?? this.actionUrl,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        data,
        imageUrl,
        isRead,
        createdAt,
        actionUrl,
        category,
      ];
}
