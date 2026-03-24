/// Custom [TextInputFormatter] implementations for common input patterns.
library;

import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Phone Number Formatter
// ---------------------------------------------------------------------------

/// Formats a phone number as the user types.
///
/// Example: `9876543210` → `98765 43210`
class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10) {
      return oldValue; // prevent more than 10 digits
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Currency Formatter
// ---------------------------------------------------------------------------

/// Formats numeric input as a currency string with thousands separators.
///
/// Example: `1234567` → `12,34,567` (Indian numbering system).
class CurrencyFormatter extends TextInputFormatter {
  const CurrencyFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Allow only digits and a single decimal point.
    final raw = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = raw.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Indian comma formatting: last group 3 digits, rest groups of 2.
    final formatted = _formatIndian(intPart);
    final result = '$formatted$decPart';

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _formatIndian(String digits) {
    if (digits.length <= 3) return digits;
    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final buffer = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i != 0 && (rest.length - i) % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
    }
    return '${buffer.toString()},$lastThree';
  }
}

// ---------------------------------------------------------------------------
// Credit Card Formatter
// ---------------------------------------------------------------------------

/// Formats a 16-digit credit / debit card number with spaces every 4 digits.
///
/// Example: `4111111111111111` → `4111 1111 1111 1111`
class CreditCardFormatter extends TextInputFormatter {
  const CreditCardFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Expiry Formatter
// ---------------------------------------------------------------------------

/// Formats card expiry date as `MM/YY`.
///
/// Example: `1225` → `12/25`
class CardExpiryFormatter extends TextInputFormatter {
  const CardExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 4) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Date Formatter (DD/MM/YYYY)
// ---------------------------------------------------------------------------

/// Formats date input as `DD/MM/YYYY`.
///
/// Example: `01012025` → `01/01/2025`
class DateInputFormatter extends TextInputFormatter {
  const DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 8) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Digits Only Formatter
// ---------------------------------------------------------------------------

/// Strips all non-digit characters, allowing only numeric input.
class DigitsOnlyFormatter extends TextInputFormatter {
  const DigitsOnlyFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
