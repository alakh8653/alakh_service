import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/core/network/shop_api_client.dart';
import 'package:shop_web/core/network/shop_api_endpoints.dart';
import 'package:shop_web/features/queue_control/data/models/queue_item_model.dart';
import 'package:shop_web/features/queue_control/data/models/queue_settings_model.dart';

/// Contract for remote queue-control API calls.
abstract class QueueControlRemoteDataSource {
  Future<List<QueueItemModel>> getLiveQueue();
  Future<QueueItemModel> callNext(String queueItemId);
  Future<void> removeFromQueue(String id);
  Future<List<QueueItemModel>> reorderQueue(List<String> orderedIds);
  Future<QueueSettingsModel> pauseQueue(String reason);
  Future<QueueSettingsModel> resumeQueue();
  Future<QueueSettingsModel> getQueueSettings();
  Future<QueueSettingsModel> updateQueueSettings(QueueSettingsModel settings);
}

/// HTTP implementation of [QueueControlRemoteDataSource].
class QueueControlRemoteDataSourceImpl
    implements QueueControlRemoteDataSource {
  QueueControlRemoteDataSourceImpl(this._apiClient);

  final ShopApiClient _apiClient;

  @override
  Future<List<QueueItemModel>> getLiveQueue() async {
    try {
      final response = await _apiClient.get(ShopApiEndpoints.queue);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<QueueItemModel> callNext(String queueItemId) async {
    try {
      final response = await _apiClient.post(
        ShopApiEndpoints.queueNext,
        data: {'queue_item_id': queueItemId},
      );
      return QueueItemModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<void> removeFromQueue(String id) async {
    try {
      await _apiClient.delete(
        ShopApiEndpoints.queueItem.replaceAll('{id}', id),
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<List<QueueItemModel>> reorderQueue(List<String> orderedIds) async {
    try {
      final response = await _apiClient.post(
        ShopApiEndpoints.queueReorder,
        data: {'ordered_ids': orderedIds},
      );
      final data = response.data as List<dynamic>;
      return data
          .map((e) => QueueItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<QueueSettingsModel> pauseQueue(String reason) async {
    try {
      final response = await _apiClient.post(
        ShopApiEndpoints.queuePause,
        data: {'reason': reason},
      );
      return QueueSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<QueueSettingsModel> resumeQueue() async {
    try {
      final response = await _apiClient.post(ShopApiEndpoints.queueResume);
      return QueueSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<QueueSettingsModel> getQueueSettings() async {
    try {
      final response = await _apiClient.get(ShopApiEndpoints.queueSettings);
      return QueueSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }

  @override
  Future<QueueSettingsModel> updateQueueSettings(
    QueueSettingsModel settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ShopApiEndpoints.queueSettings,
        data: settings.toJson(),
      );
      return QueueSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    }
  }
}
