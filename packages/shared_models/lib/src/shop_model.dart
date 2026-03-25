import 'package:freezed_annotation/freezed_annotation.dart';
import 'address_model.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

@freezed
class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    required String category,
    @Default(0.0) double rating,
    AddressModel? address,
    @Default(true) bool isActive,
  }) = _ShopModel;

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);
}
