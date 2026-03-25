import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../models/queue_entry_model.dart';
import '../models/queue_model.dart';
import '../models/queue_status_model.dart';

/// Abstract contract for all remote queue data operations.
abstract class QueueRemoteDataSource {
  /// Joins the queue for [shopId] and returns the created [QueueEntryModel].
  Future<QueueEntryModel> joinQueue(String shopId, {String? serviceId});

  /// Cancels/leaves the entry identified by [entryId].
  Future<void> leaveQueue(String entryId);

  /// Fetches the current [QueueModel] for [shopId].
  Future<QueueModel> getQueueStatus(String shopId);

  /// Fetches the caller's own [QueueEntryModel] within [queueId].
  Future<QueueEntryModel> getMyQueuePosition(String queueId);

  /// Returns a stream of [QueueStatusModel] updates for [entryId].
  Stream<QueueStatusModel> watchQueueUpdates(String entryId);

  /// Fetches the authenticated user's historical [QueueEntryModel] list.
  Future<List<QueueEntryModel>> getQueueHistory();
}

/// Concrete [QueueRemoteDataSource] implementation that communicates with the
/// backend REST API via [Dio].
///
/// All endpoints follow the convention `{baseUrl}/api/v1/queues/...`.
class QueueRemoteDataSourceImpl implements QueueRemoteDataSource {
  /// The Dio HTTP client used for all requests.
  final Dio dio;

  /// Creates a [QueueRemoteDataSourceImpl] with the given [dio] client.
  const QueueRemoteDataSourceImpl({required this.dio});

  // ---------------------------------------------------------------------------
  // Join queue
  // ---------------------------------------------------------------------------

  @override
  Future<QueueEntryModel> joinQueue(String shopId, {String? serviceId}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/queues/join',
        data: {
          'shop_id': shopId,
          if (serviceId != null) 'service_id': serviceId,
        },
      );
      return QueueEntryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Leave queue
  // ---------------------------------------------------------------------------

  @override
  Future<void> leaveQueue(String entryId) async {
    try {
      await dio.delete<void>('/api/v1/queues/entries/$entryId');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Queue status
  // ---------------------------------------------------------------------------

  @override
  Future<QueueModel> getQueueStatus(String shopId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/queues/shops/$shopId/status',
      );
      return QueueModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // My queue position
  // ---------------------------------------------------------------------------

  @override
  Future<QueueEntryModel> getMyQueuePosition(String queueId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/queues/$queueId/my-position',
      );
      return QueueEntryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Watch queue updates (real-time)
  // ---------------------------------------------------------------------------

  @override
  Stream<QueueStatusModel> watchQueueUpdates(String entryId) {
    // TODO: Replace with a real WebSocket or SSE connection.
    //
    // Example WebSocket integration:
    //   final channel = WebSocketChannel.connect(
    //     Uri.parse('wss://api.example.com/ws/queues/entries/$entryId'),
    //   );
    //   return channel.stream
    //       .map((data) => QueueStatusModel.fromJson(
    //             jsonDecode(data as String) as Map<String, dynamic>,
    //           ));
    //
    // The current implementation falls back to HTTP polling every 5 seconds.
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/queues/entries/$entryId/status',
      );
      return QueueStatusModel.fromJson(response.data!);
    });
  }

  // ---------------------------------------------------------------------------
  // Queue history
  // ---------------------------------------------------------------------------

  @override
  Future<List<QueueEntryModel>> getQueueHistory() async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/api/v1/queues/history',
      );
      return (response.data!)
          .map(
            (e) => QueueEntryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Maps a [DioException] to an appropriate [Failure] subclass.
  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkFailure(cause: e);
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return UnauthorisedFailure(cause: e);
    }
    if (statusCode == 404) {
      return NotFoundFailure(cause: e);
    }
    final message =
        (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
            e.message ??
            'An unexpected server error occurred.';
    return ServerFailure(message: message, statusCode: statusCode, cause: e);
  }
}
