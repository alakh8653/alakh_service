import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response_model.freezed.dart';
part 'api_response_model.g.dart';

@freezed
class ApiResponseModel<T> with _$ApiResponseModel<T> {
  const factory ApiResponseModel({
    required bool success,
    required String message,
    T? data,
  }) = _ApiResponseModel<T>;

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);
}

@freezed
class PaginatedResponseModel<T> with _$PaginatedResponseModel<T> {
  const factory PaginatedResponseModel({
    required List<T> data,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _PaginatedResponseModel<T>;

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedResponseModelFromJson(json, fromJsonT);
}
