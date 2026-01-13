import 'package:equatable/equatable.dart';

/// Configuration for field validation rules
class ValidationConfig extends Equatable {
  /// Whether the field is required
  final bool required;

  /// Minimum length for text fields
  final int? minLength;

  /// Maximum length for text fields
  final int? maxLength;

  /// Regular expression pattern for validation
  /// Example: "^[a-zA-Z\\s]+$" for letters and spaces only
  final String? pattern;

  /// Custom error message to display when validation fails
  final String? errorMessage;

  /// Error message for required validation
  final String? requiredMessage;

  /// Error message for pattern validation
  final String? patternMessage;

  /// Error message for min length validation
  final String? minLengthMessage;

  /// Error message for max length validation
  final String? maxLengthMessage;

  /// Minimum date for date fields (ISO 8601 format or "today")
  final String? minDate;

  /// Maximum date for date fields (ISO 8601 format or "today")
  final String? maxDate;

  /// Reference to another field for date comparison
  /// Example: "fromDate" to ensure toDate is after fromDate
  final String? compareToField;

  /// Minimum numeric value
  final num? minValue;

  /// Maximum numeric value
  final num? maxValue;

  const ValidationConfig({
    this.required = false,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.errorMessage,
    this.requiredMessage,
    this.patternMessage,
    this.minLengthMessage,
    this.maxLengthMessage,
    this.minDate,
    this.maxDate,
    this.compareToField,
    this.minValue,
    this.maxValue,
  });

  /// Create ValidationConfig from JSON
  factory ValidationConfig.fromJson(Map<String, dynamic> json) {
    return ValidationConfig(
      required: json['required'] as bool? ?? false,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      pattern: json['pattern'] as String?,
      errorMessage: json['errorMessage'] as String?,
      requiredMessage: json['requiredMessage'] as String?,
      patternMessage: json['patternMessage'] as String?,
      minLengthMessage: json['minLengthMessage'] as String?,
      maxLengthMessage: json['maxLengthMessage'] as String?,
      minDate: json['minDate'] as String?,
      maxDate: json['maxDate'] as String?,
      compareToField: json['compareToField'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
    );
  }

  /// Convert ValidationConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'required': required,
      if (minLength != null) 'minLength': minLength,
      if (maxLength != null) 'maxLength': maxLength,
      if (pattern != null) 'pattern': pattern,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (requiredMessage != null) 'requiredMessage': requiredMessage,
      if (patternMessage != null) 'patternMessage': patternMessage,
      if (minLengthMessage != null) 'minLengthMessage': minLengthMessage,
      if (maxLengthMessage != null) 'maxLengthMessage': maxLengthMessage,
      if (minDate != null) 'minDate': minDate,
      if (maxDate != null) 'maxDate': maxDate,
      if (compareToField != null) 'compareToField': compareToField,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
    };
  }

  /// Create a copy with updated fields
  ValidationConfig copyWith({
    bool? required,
    int? minLength,
    int? maxLength,
    String? pattern,
    String? errorMessage,
    String? requiredMessage,
    String? patternMessage,
    String? minLengthMessage,
    String? maxLengthMessage,
    String? minDate,
    String? maxDate,
    String? compareToField,
    num? minValue,
    num? maxValue,
  }) {
    return ValidationConfig(
      required: required ?? this.required,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      pattern: pattern ?? this.pattern,
      errorMessage: errorMessage ?? this.errorMessage,
      requiredMessage: requiredMessage ?? this.requiredMessage,
      patternMessage: patternMessage ?? this.patternMessage,
      minLengthMessage: minLengthMessage ?? this.minLengthMessage,
      maxLengthMessage: maxLengthMessage ?? this.maxLengthMessage,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      compareToField: compareToField ?? this.compareToField,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  @override
  List<Object?> get props => [
        required,
        minLength,
        maxLength,
        pattern,
        errorMessage,
        requiredMessage,
        patternMessage,
        minLengthMessage,
        maxLengthMessage,
        minDate,
        maxDate,
        compareToField,
        minValue,
        maxValue,
      ];
}
