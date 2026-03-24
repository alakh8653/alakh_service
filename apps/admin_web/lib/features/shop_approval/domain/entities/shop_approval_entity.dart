import 'package:equatable/equatable.dart';

enum ShopStatus {
  pending,
  underReview,
  approved,
  rejected,
  suspended;

  static ShopStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'under_review':
      case 'underreview':
        return ShopStatus.underReview;
      case 'approved':
        return ShopStatus.approved;
      case 'rejected':
        return ShopStatus.rejected;
      case 'suspended':
        return ShopStatus.suspended;
      case 'pending':
      default:
        return ShopStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ShopStatus.pending:
        return 'Pending';
      case ShopStatus.underReview:
        return 'Under Review';
      case ShopStatus.approved:
        return 'Approved';
      case ShopStatus.rejected:
        return 'Rejected';
      case ShopStatus.suspended:
        return 'Suspended';
    }
  }
}

enum ShopDocumentType {
  gstCertificate,
  businessLicense,
  addressProof,
  ownerIdProof,
  shopPhoto;

  static ShopDocumentType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'gst_certificate':
      case 'gstcertificate':
        return ShopDocumentType.gstCertificate;
      case 'business_license':
      case 'businesslicense':
        return ShopDocumentType.businessLicense;
      case 'address_proof':
      case 'addressproof':
        return ShopDocumentType.addressProof;
      case 'owner_id_proof':
      case 'owneridproof':
        return ShopDocumentType.ownerIdProof;
      case 'shop_photo':
      case 'shopphoto':
        return ShopDocumentType.shopPhoto;
      default:
        return ShopDocumentType.shopPhoto;
    }
  }

  String get displayName {
    switch (this) {
      case ShopDocumentType.gstCertificate:
        return 'GST Certificate';
      case ShopDocumentType.businessLicense:
        return 'Business License';
      case ShopDocumentType.addressProof:
        return 'Address Proof';
      case ShopDocumentType.ownerIdProof:
        return 'Owner ID Proof';
      case ShopDocumentType.shopPhoto:
        return 'Shop Photo';
    }
  }
}

class ShopDocument extends Equatable {
  final String id;
  final ShopDocumentType type;
  final String url;
  final DateTime uploadedAt;
  final bool verified;

  const ShopDocument({
    required this.id,
    required this.type,
    required this.url,
    required this.uploadedAt,
    required this.verified,
  });

  @override
  List<Object?> get props => [id, type, url, uploadedAt, verified];
}

class ShopApprovalEntity extends Equatable {
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
  final List<ShopDocument> documents;
  final double? latitude;
  final double? longitude;
  final double rating;
  final int totalReviews;

  const ShopApprovalEntity({
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

  ShopApprovalEntity copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? category,
    String? address,
    String? city,
    String? state,
    String? gstNumber,
    String? licenseNumber,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    ShopStatus? status,
    String? rejectionReason,
    List<ShopDocument>? documents,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalReviews,
  }) {
    return ShopApprovalEntity(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      category: category ?? this.category,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      gstNumber: gstNumber ?? this.gstNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopName,
        ownerName,
        ownerPhone,
        ownerEmail,
        category,
        address,
        city,
        state,
        gstNumber,
        licenseNumber,
        submittedAt,
        reviewedAt,
        reviewedBy,
        status,
        rejectionReason,
        documents,
        latitude,
        longitude,
        rating,
        totalReviews,
      ];
}
