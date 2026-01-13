import 'package:equatable/equatable.dart';

class ValidationConfig extends Equatable {
  final bool? required;
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final num? minValue;
  final num? maxValue;
  final String? minDate;
  final String? maxDate;
  final String? compareToField;
  final String? requiredMessage;
  final String? patternMessage;
  final String? minLengthMessage;
  final String? maxLengthMessage;

  const ValidationConfig({
    this.required,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.minValue,
    this.maxValue,
    this.minDate,
    this.maxDate,
    this.compareToField,
    this.requiredMessage,
    this.patternMessage,
    this.minLengthMessage,
    this.maxLengthMessage,
  });

  factory ValidationConfig.fromJson(Map<String, dynamic> json) {
    return ValidationConfig(
      required: json['required'] as bool?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      pattern: json['pattern'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
      minDate: json['minDate'] as String?,
      maxDate: json['maxDate'] as String?,
      compareToField: json['compareToField'] as String?,
      requiredMessage: json['requiredMessage'] as String?,
      patternMessage: json['patternMessage'] as String?,
      minLengthMessage: json['minLengthMessage'] as String?,
      maxLengthMessage: json['maxLengthMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (required != null) 'required': required,
      if (minLength != null) 'minLength': minLength,
      if (maxLength != null) 'maxLength': maxLength,
      if (pattern != null) 'pattern': pattern,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (minDate != null) 'minDate': minDate,
      if (maxDate != null) 'maxDate': maxDate,
      if (compareToField != null) 'compareToField': compareToField,
      if (requiredMessage != null) 'requiredMessage': requiredMessage,
      if (patternMessage != null) 'patternMessage': patternMessage,
      if (minLengthMessage != null) 'minLengthMessage': minLengthMessage,
      if (maxLengthMessage != null) 'maxLengthMessage': maxLengthMessage,
    };
  }

  @override
  List<Object?> get props => [
        required,
        minLength,
        maxLength,
        pattern,
        minValue,
        maxValue,
        minDate,
        maxDate,
        compareToField,
        requiredMessage,
        patternMessage,
        minLengthMessage,
        maxLengthMessage,
      ];
}
