/// Request model for OTP verification API call.
class OtpRequestModel {
  final String phone;
  final String otp;

  const OtpRequestModel({
    required this.phone,
    required this.otp,
  });

  /// Converts this request to a JSON map for the API call.
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
    };
  }

  /// Creates a copy of this model with updated fields.
  OtpRequestModel copyWith({
    String? phone,
    String? otp,
  }) {
    return OtpRequestModel(
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
    );
  }
}
