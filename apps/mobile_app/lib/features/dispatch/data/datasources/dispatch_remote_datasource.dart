import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/dispatch_assignment_model.dart';
import '../models/dispatch_job_model.dart';
import '../models/dispatch_route_model.dart';
import '../../domain/entities/dispatch_status.dart';

/// Abstract contract for the remote dispatch data source.
abstract class DispatchRemoteDataSource {
  /// Sends an accept request for [jobId].
  Future<void> acceptDispatch(String jobId);

  /// Sends a reject request for [jobId] with an optional [reason].
  Future<void> rejectDispatch(String jobId, {String? reason});

  /// Fetches the active dispatch job for the staff member.
  ///
  /// Returns `null` when no active job exists.
  Future<DispatchJobModel?> getActiveDispatch();

  /// Updates the status of [jobId] to [status].
  Future<void> updateDispatchStatus(String jobId, DispatchStatus status);

  /// Fetches the route details for [jobId].
  Future<DispatchRouteModel> getDispatchRoute(String jobId);

  /// Returns a real-time stream of [DispatchJobModel] updates for [staffId].
  ///
  // TODO: Replace polling with a WebSocket connection for real-time assignments.
  Stream<DispatchJobModel> watchDispatchUpdates(String staffId);

  /// Fetches a paginated page of dispatch history.
  Future<List<DispatchJobModel>> getDispatchHistory({int page = 1});
}

/// Dio-based implementation of [DispatchRemoteDataSource].
class DispatchRemoteDataSourceImpl implements DispatchRemoteDataSource {
  final Dio _dio;

  const DispatchRemoteDataSourceImpl(this._dio);

  @override
  Future<void> acceptDispatch(String jobId) async {
    try {
      await _dio.post('/dispatch/jobs/$jobId/accept');
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.message ?? 'Failed to accept dispatch job.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  @override
  Future<void> rejectDispatch(String jobId, {String? reason}) async {
    try {
      await _dio.post(
        '/dispatch/jobs/$jobId/reject',
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.message ?? 'Failed to reject dispatch job.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  @override
  Future<DispatchJobModel?> getActiveDispatch() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/dispatch/jobs/active');
      if (response.data == null || response.statusCode == 204) return null;
      return DispatchJobModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ServerFailure(
        message: e.message ?? 'Failed to load active job.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  @override
  Future<void> updateDispatchStatus(String jobId, DispatchStatus status) async {
    try {
      await _dio.patch(
        '/dispatch/jobs/$jobId/status',
        data: {'status': status.name},
      );
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.message ?? 'Failed to update job status.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  @override
  Future<DispatchRouteModel> getDispatchRoute(String jobId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/dispatch/jobs/$jobId/route');
      return DispatchRouteModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.message ?? 'Failed to load route.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }

  @override
  Stream<DispatchJobModel> watchDispatchUpdates(String staffId) async* {
    // TODO: Replace this polling stub with a WebSocket or SSE connection.
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 5));
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '/dispatch/jobs/active',
          queryParameters: {'staff_id': staffId},
        );
        if (response.data != null) {
          yield DispatchJobModel.fromJson(response.data!);
        }
      } on DioException catch (e) {
        throw ServerFailure(
          message: e.message ?? 'Stream error.',
          statusCode: e.response?.statusCode,
          cause: e,
        );
      }
    }
  }

  @override
  Future<List<DispatchJobModel>> getDispatchHistory({int page = 1}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/dispatch/jobs/history',
        queryParameters: {'page': page},
      );
      return (response.data ?? [])
          .map((e) => DispatchJobModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(
        message: e.message ?? 'Failed to load history.',
        statusCode: e.response?.statusCode,
        cause: e,
      );
    }
  }
}
