/// Centralised, localisable validation error messages.
library;

/// All validation error messages in one place so they can be updated or
/// localised without touching each validator individually.
///
/// Pass a custom [ValidatorMessages] instance to validator factories that
/// support it, or override individual properties via `copyWith`.
class ValidatorMessages {
  const ValidatorMessages({
    this.required = 'This field is required.',
    this.invalidEmail = 'Enter a valid email address.',
    this.invalidPhone = 'Enter a valid 10-digit mobile number.',
    this.invalidUrl = 'Enter a valid URL (http:// or https://).',
    this.invalidDate = 'Enter a valid date.',
    this.invalidNumber = 'Enter a valid number.',
    this.onlyDigits = 'Only numbers are allowed.',
    this.onlyAlpha = 'Only letters are allowed.',
    this.weakPassword =
        'Password must be at least 8 characters with uppercase, lowercase, '
            'a digit, and a special character.',
    this.passwordMismatch = 'Passwords do not match.',
    this.tooShort = 'Too short.',
    this.tooLong = 'Too long.',
    this.belowMinValue = 'Value is too small.',
    this.aboveMaxValue = 'Value is too large.',
    this.invalidFormat = 'Invalid format.',
    this.alreadyExists = 'Already exists.',
    this.notFound = 'Not found.',
  });

  /// Field must not be empty.
  final String required;

  /// Email address format is invalid.
  final String invalidEmail;

  /// Phone number format is invalid.
  final String invalidPhone;

  /// URL format is invalid.
  final String invalidUrl;

  /// Date format is invalid.
  final String invalidDate;

  /// Numeric format is invalid.
  final String invalidNumber;

  /// Field accepts only digit characters.
  final String onlyDigits;

  /// Field accepts only alphabetic characters.
  final String onlyAlpha;

  /// Password does not meet strength requirements.
  final String weakPassword;

  /// Confirm-password field does not match the password field.
  final String passwordMismatch;

  /// Input is shorter than the minimum allowed length.
  final String tooShort;

  /// Input is longer than the maximum allowed length.
  final String tooLong;

  /// Numeric value is less than the allowed minimum.
  final String belowMinValue;

  /// Numeric value is greater than the allowed maximum.
  final String aboveMaxValue;

  /// General invalid format message.
  final String invalidFormat;

  /// The provided value already exists (e.g. duplicate username).
  final String alreadyExists;

  /// The provided value was not found (e.g. coupon code).
  final String notFound;

  // ---------------------------------------------------------------------------
  // Factory helpers
  // ---------------------------------------------------------------------------

  /// Returns a localised set of messages for Hindi (`hi`).
  factory ValidatorMessages.hindi() => const ValidatorMessages(
        required: 'यह फ़ील्ड आवश्यक है।',
        invalidEmail: 'एक वैध ईमेल पता दर्ज करें।',
        invalidPhone: 'वैध 10-अंकीय मोबाइल नंबर दर्ज करें।',
        invalidUrl: 'एक वैध URL दर्ज करें।',
        invalidDate: 'एक वैध दिनांक दर्ज करें।',
        invalidNumber: 'एक वैध संख्या दर्ज करें।',
        onlyDigits: 'केवल अंक अनुमत हैं।',
        onlyAlpha: 'केवल अक्षर अनुमत हैं।',
        weakPassword: 'पासवर्ड कमज़ोर है।',
        passwordMismatch: 'पासवर्ड मेल नहीं खाते।',
        tooShort: 'बहुत छोटा।',
        tooLong: 'बहुत लंबा।',
        belowMinValue: 'मान बहुत कम है।',
        aboveMaxValue: 'मान बहुत अधिक है।',
        invalidFormat: 'अमान्य प्रारूप।',
        alreadyExists: 'पहले से मौजूद है।',
        notFound: 'नहीं मिला।',
      );

  /// Creates a copy with the specified fields replaced.
  ValidatorMessages copyWith({
    String? required,
    String? invalidEmail,
    String? invalidPhone,
    String? invalidUrl,
    String? invalidDate,
    String? invalidNumber,
    String? onlyDigits,
    String? onlyAlpha,
    String? weakPassword,
    String? passwordMismatch,
    String? tooShort,
    String? tooLong,
    String? belowMinValue,
    String? aboveMaxValue,
    String? invalidFormat,
    String? alreadyExists,
    String? notFound,
  }) =>
      ValidatorMessages(
        required: required ?? this.required,
        invalidEmail: invalidEmail ?? this.invalidEmail,
        invalidPhone: invalidPhone ?? this.invalidPhone,
        invalidUrl: invalidUrl ?? this.invalidUrl,
        invalidDate: invalidDate ?? this.invalidDate,
        invalidNumber: invalidNumber ?? this.invalidNumber,
        onlyDigits: onlyDigits ?? this.onlyDigits,
        onlyAlpha: onlyAlpha ?? this.onlyAlpha,
        weakPassword: weakPassword ?? this.weakPassword,
        passwordMismatch: passwordMismatch ?? this.passwordMismatch,
        tooShort: tooShort ?? this.tooShort,
        tooLong: tooLong ?? this.tooLong,
        belowMinValue: belowMinValue ?? this.belowMinValue,
        aboveMaxValue: aboveMaxValue ?? this.aboveMaxValue,
        invalidFormat: invalidFormat ?? this.invalidFormat,
        alreadyExists: alreadyExists ?? this.alreadyExists,
        notFound: notFound ?? this.notFound,
      );
}
