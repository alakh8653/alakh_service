import '../../domain/repositories/discovery_repository.dart';
import 'service_model.dart';
import 'shop_model.dart';

/// JSON-serialisable model for [SearchResult].
class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.shops,
    required super.services,
    required super.totalCount,
  });

  /// Constructs a [SearchResultModel] from a JSON [map].
  factory SearchResultModel.fromJson(Map<String, dynamic> map) {
    final rawShops = map['shops'] as List? ?? [];
    final rawServices = map['services'] as List? ?? [];
    return SearchResultModel(
      shops: rawShops
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: rawServices
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: map['total_count'] as int? ?? 0,
    );
  }

  /// Converts this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'shops': shops.map((s) => (s as ShopModel).toJson()).toList(),
      'services': services.map((s) => (s as ServiceModel).toJson()).toList(),
      'total_count': totalCount,
    };
  }
}
