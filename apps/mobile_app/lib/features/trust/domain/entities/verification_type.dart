enum VerificationType {
  identity,
  phone,
  email,
  address,
  backgroundCheck,
  license,
  insurance,
}

extension VerificationTypeExtension on VerificationType {
  String get displayName {
    switch (this) {
      case VerificationType.identity: return 'Identity';
      case VerificationType.phone: return 'Phone';
      case VerificationType.email: return 'Email';
      case VerificationType.address: return 'Address';
      case VerificationType.backgroundCheck: return 'Background Check';
      case VerificationType.license: return 'License';
      case VerificationType.insurance: return 'Insurance';
    }
  }

  String get icon {
    switch (this) {
      case VerificationType.identity: return '🪪';
      case VerificationType.phone: return '📱';
      case VerificationType.email: return '📧';
      case VerificationType.address: return '🏠';
      case VerificationType.backgroundCheck: return '🔍';
      case VerificationType.license: return '📋';
      case VerificationType.insurance: return '🛡️';
    }
  }
}
