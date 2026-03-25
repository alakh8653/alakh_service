import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dispute_model.dart';

abstract class DisputeLocalDataSource {
  Future<void> cacheDisputes(List<DisputeModel> disputes);
  Future<List<DisputeModel>> getCachedDisputes();
  Future<void> cacheDisputeDetails(DisputeModel dispute);
  Future<DisputeModel?> getCachedDisputeDetails(String disputeId);
  Future<void> clearCache();
}

class DisputeLocalDataSourceImpl implements DisputeLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _disputesKey = 'cached_disputes';
  static const String _disputeDetailPrefix = 'cached_dispute_';

  const DisputeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheDisputes(List<DisputeModel> disputes) async {
    final jsonList = disputes.map((d) => d.toJson()).toList();
    await sharedPreferences.setString(_disputesKey, jsonEncode(jsonList));
  }

  @override
  Future<List<DisputeModel>> getCachedDisputes() async {
    final jsonString = sharedPreferences.getString(_disputesKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheDisputeDetails(DisputeModel dispute) async {
    await sharedPreferences.setString(
      '$_disputeDetailPrefix${dispute.id}',
      jsonEncode(dispute.toJson()),
    );
  }

  @override
  Future<DisputeModel?> getCachedDisputeDetails(String disputeId) async {
    final jsonString =
        sharedPreferences.getString('$_disputeDetailPrefix$disputeId');
    if (jsonString == null) return null;
    return DisputeModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences
        .getKeys()
        .where((k) => k == _disputesKey || k.startsWith(_disputeDetailPrefix))
        .toList();
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
