import '../../domain/models/field_config.dart';
import '../../domain/models/validation_config.dart';
import 'package:intl/intl.dart';

/// Centralized validation engine for form fields
class ValidationEngine {
  /// Validate a field value against its configuration
  static String? validateField(FieldConfig config, dynamic value) {
    if (config.validation == null) return null;

    final validation = config.validation!;

    // Required validation
    if (validation.required) {
      if (value == null) {
        return validation.requiredMessage ??
            validation.errorMessage ??
            'This field is required';
      }

      // Check for empty values based on type
      if (value is String && value.trim().isEmpty) {
        return validation.requiredMessage ??
            validation.errorMessage ??
            'This field is required';
      }

      if (value is List && value.isEmpty) {
        return validation.requiredMessage ??
            validation.errorMessage ??
            'At least one entry is required';
      }
    }

    // If value is null and not required, skip other validations
    if (value == null) return null;

    // String-specific validations
    if (value is String) {
      return _validateString(value, validation);
    }

    // Date-specific validations
    if (value is DateTime) {
      return _validateDate(value, validation);
    }

    // Number-specific validations
    if (value is num) {
      return _validateNumber(value, validation);
    }

    return null;
  }

  /// Validate string values
  static String? _validateString(String value, ValidationConfig validation) {
    if (value.isEmpty) return null;

    // Min length validation
    if (validation.minLength != null && value.length < validation.minLength!) {
      return validation.minLengthMessage ??
          validation.errorMessage ??
          'Minimum ${validation.minLength} characters required';
    }

    // Max length validation
    if (validation.maxLength != null && value.length > validation.maxLength!) {
      return validation.maxLengthMessage ??
          validation.errorMessage ??
          'Maximum ${validation.maxLength} characters allowed';
    }

    // Pattern validation
    if (validation.pattern != null) {
      final isValid = validatePattern(validation.pattern!, value);
      if (!isValid) {
        return validation.patternMessage ??
            validation.errorMessage ??
            'Invalid format';
      }
    }

    return null;
  }

  /// Validate date values
  static String? _validateDate(DateTime value, ValidationConfig validation) {
    final now = DateTime.now();

    // Min date validation
    if (validation.minDate != null) {
      final minDate = _parseDate(validation.minDate!);
      if (minDate != null && value.isBefore(minDate)) {
        return validation.errorMessage ??
            'Date must be after ${DateFormat('dd-MM-yyyy').format(minDate)}';
      }
    }

    // Max date validation
    if (validation.maxDate != null) {
      final maxDate = _parseDate(validation.maxDate!);
      if (maxDate != null && value.isAfter(maxDate)) {
        return validation.errorMessage ??
            'Date must be before ${DateFormat('dd-MM-yyyy').format(maxDate)}';
      }
    }

    return null;
  }

  /// Validate numeric values
  static String? _validateNumber(num value, ValidationConfig validation) {
    // Min value validation
    if (validation.minValue != null && value < validation.minValue!) {
      return validation.errorMessage ??
          'Value must be at least ${validation.minValue}';
    }

    // Max value validation
    if (validation.maxValue != null && value > validation.maxValue!) {
      return validation.errorMessage ??
          'Value must be at most ${validation.maxValue}';
    }

    return null;
  }

  /// Validate a string against a regex pattern
  static bool validatePattern(String pattern, String value) {
    try {
      final regex = RegExp(pattern);
      return regex.hasMatch(value);
    } catch (e) {
      print('Invalid regex pattern: $pattern - $e');
      return true; // Don't fail validation on invalid regex
    }
  }

  /// Parse date string to DateTime
  static DateTime? _parseDate(String dateStr) {
    if (dateStr.toLowerCase() == 'today') {
      return DateTime.now();
    }

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Invalid date string: $dateStr');
      return null;
    }
  }

  /// Validate date range (e.g., toDate must be after fromDate)
  static String? validateDateRange({
    required DateTime? fromDate,
    required DateTime? toDate,
    String? errorMessage,
  }) {
    if (fromDate == null || toDate == null) return null;

    if (toDate.isBefore(fromDate)) {
      return errorMessage ?? 'End date must be after start date';
    }

    return null;
  }

  /// Validate all fields in a step
  static Map<String, String?> validateStep(
    List<FieldConfig> fields,
    Map<String, dynamic> formData,
  ) {
    final errors = <String, String?>{};

    for (final field in fields) {
      final value = formData[field.fieldId];
      final error = validateField(field, value);
      if (error != null) {
        errors[field.fieldId] = error;
      }
    }

    return errors;
  }

  /// Check if all validations pass
  static bool isStepValid(
    List<FieldConfig> fields,
    Map<String, dynamic> formData,
  ) {
    final errors = validateStep(fields, formData);
    return errors.values.every((error) => error == null);
  }
}
