import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';

class ShopDocumentModel {
  final String id;
  final ShopDocumentType type;
  final String url;
  final DateTime uploadedAt;
  final bool verified;

  const ShopDocumentModel({
    required this.id,
    required this.type,
    required this.url,
    required this.uploadedAt,
    required this.verified,
  });

  factory ShopDocumentModel.fromJson(Map<String, dynamic> json) {
    return ShopDocumentModel(
      id: json['id'] as String,
      type: ShopDocumentType.fromString(json['type'] as String),
      url: json['url'] as String,
      uploadedAt: DateTime.parse(
          json['uploadedAt'] as String? ?? json['uploaded_at'] as String),
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'url': url,
        'uploadedAt': uploadedAt.toIso8601String(),
        'verified': verified,
      };

  ShopDocument toEntity() => ShopDocument(
        id: id,
        type: type,
        url: url,
        uploadedAt: uploadedAt,
        verified: verified,
      );
}

class ShopApprovalModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String category;
  final String address;
  final String city;
  final String state;
  final String? gstNumber;
  final String? licenseNumber;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final ShopStatus status;
  final String? rejectionReason;
  final List<ShopDocumentModel> documents;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalReviews;

  const ShopApprovalModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.category,
    required this.address,
    required this.city,
    required this.state,
    this.gstNumber,
    this.licenseNumber,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    required this.status,
    this.rejectionReason,
    required this.documents,
    this.latitude,
    this.longitude,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  factory ShopApprovalModel.fromJson(Map<String, dynamic> json) {
    return ShopApprovalModel(
      id: json['id'] as String,
      shopName: json['shopName'] as String? ?? json['shop_name'] as String,
      ownerName: json['ownerName'] as String? ?? json['owner_name'] as String,
      ownerPhone:
          json['ownerPhone'] as String? ?? json['owner_phone'] as String,
      ownerEmail:
          json['ownerEmail'] as String? ?? json['owner_email'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      gstNumber: json['gstNumber'] as String? ?? json['gst_number'] as String?,
      licenseNumber: json['licenseNumber'] as String? ??
          json['license_number'] as String?,
      submittedAt: DateTime.parse(
          json['submittedAt'] as String? ?? json['submitted_at'] as String),
      reviewedAt: json['reviewedAt'] != null || json['reviewed_at'] != null
          ? DateTime.parse(
              json['reviewedAt'] as String? ?? json['reviewed_at'] as String)
          : null,
      reviewedBy:
          json['reviewedBy'] as String? ?? json['reviewed_by'] as String?,
      status: ShopStatus.fromString(json['status'] as String),
      rejectionReason: json['rejectionReason'] as String? ??
          json['rejection_reason'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) =>
                  ShopDocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ??
          json['total_reviews'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shopName': shopName,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerEmail': ownerEmail,
        'category': category,
        'address': address,
        'city': city,
        'state': state,
        'gstNumber': gstNumber,
        'licenseNumber': licenseNumber,
        'submittedAt': submittedAt.toIso8601String(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'reviewedBy': reviewedBy,
        'status': status.name,
        'rejectionReason': rejectionReason,
        'documents': documents.map((d) => d.toJson()).toList(),
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'totalReviews': totalReviews,
      };

  ShopApprovalEntity toEntity() => ShopApprovalEntity(
        id: id,
        shopName: shopName,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerEmail: ownerEmail,
        category: category,
        address: address,
        city: city,
        state: state,
        gstNumber: gstNumber,
        licenseNumber: licenseNumber,
        submittedAt: submittedAt,
        reviewedAt: reviewedAt,
        reviewedBy: reviewedBy,
        status: status,
        rejectionReason: rejectionReason,
        documents: documents.map((d) => d.toEntity()).toList(),
        latitude: latitude,
        longitude: longitude,
        rating: rating,
        totalReviews: totalReviews,
      );
}
