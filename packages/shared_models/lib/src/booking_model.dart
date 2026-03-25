import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums/booking_status.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String shopId,
    required String serviceId,
    @Default(BookingStatus.pending) BookingStatus status,
    required DateTime scheduledAt,
    required double amount,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}
