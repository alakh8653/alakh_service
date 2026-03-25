import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile_app/core/error/failures.dart';

import '../entities/app_notification.dart';
import '../entities/notification_category.dart';
import '../repositories/notification_repository.dart';

/// Parameters for [GetNotificationsUseCase].
class GetNotificationsParams extends Equatable {
  /// 1-based page index.
  final int page;

  /// Maximum number of results per page.
  final int limit;

  /// Optional category filter.
  final NotificationCategory? category;

  /// Creates [GetNotificationsParams].
  const GetNotificationsParams({
    this.page = 1,
    this.limit = 20,
    this.category,
  });

  @override
  List<Object?> get props => [page, limit, category];
}

/// Fetches a paginated list of notifications, with optional category filter.
class GetNotificationsUseCase {
  /// Creates [GetNotificationsUseCase].
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  /// Executes the use case.
  Future<Either<Failure, List<AppNotification>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(
      page: params.page,
      limit: params.limit,
      category: params.category,
    );
  }
}
