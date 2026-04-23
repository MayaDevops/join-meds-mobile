import 'package:equatable/equatable.dart';
import 'api_config.dart';
import 'field_config.dart';
import 'navigation_config.dart';

/// Configuration for a single step/screen in the form flow
class StepConfig extends Equatable {
  /// Unique identifier for this step
  final String stepId;

  /// Type of step: "form", "cardSelection", "modal"
  final String stepType;

  /// Title to display in the AppBar
  final String title;

  /// Subtitle or description
  final String? subtitle;

  /// List of fields to display in this step
  final List<FieldConfig> fields;

  /// Navigation configuration for this step
  /// If null, the form will auto-proceed to next step in sequence or complete
  final NavigationConfig? navigation;

  /// API configuration for submitting this step's data
  final ApiConfig? apiConfig;

  /// Whether to show a progress indicator
  /// Shows current step number / total steps
  final bool showProgress;

  /// Whether the step can be skipped
  final bool skippable;

  /// Message to show when skipping
  final String? skipMessage;

  /// Whether to validate fields before navigation
  final bool validateBeforeNavigate;

  /// Custom instructions or help text
  final String? instructions;

  /// Icon to show in the AppBar
  final String? icon;

  /// Background color for the step (hex string)
  final String? backgroundColor;

  const StepConfig({
    required this.stepId,
    required this.stepType,
    required this.title,
    this.subtitle,
    required this.fields,
    required this.navigation,
    this.apiConfig,
    this.showProgress = true,
    this.skippable = false,
    this.skipMessage,
    this.validateBeforeNavigate = true,
    this.instructions,
    this.icon,
    this.backgroundColor,
  });

  factory StepConfig.fromJson(Map<String, dynamic> json) {
    return StepConfig(
      stepId: json['stepId'] as String,
      stepType: json['stepType'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      fields: (json['fields'] as List)
          .map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      navigation: json['navigation'] != null
          ? NavigationConfig.fromJson(json['navigation'] as Map<String, dynamic>)
          : null,
      apiConfig: json['apiConfig'] != null
          ? ApiConfig.fromJson(json['apiConfig'] as Map<String, dynamic>)
          : null,
      showProgress: json['showProgress'] as bool? ?? true,
      skippable: json['skippable'] as bool? ?? false,
      skipMessage: json['skipMessage'] as String?,
      validateBeforeNavigate: json['validateBeforeNavigate'] as bool? ?? true,
      instructions: json['instructions'] as String?,
      icon: json['icon'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'stepType': stepType,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      'fields': fields.map((e) => e.toJson()).toList(),
      if (navigation != null) 'navigation': navigation!.toJson(),
      if (apiConfig != null) 'apiConfig': apiConfig!.toJson(),
      'showProgress': showProgress,
      'skippable': skippable,
      if (skipMessage != null) 'skipMessage': skipMessage,
      'validateBeforeNavigate': validateBeforeNavigate,
      if (instructions != null) 'instructions': instructions,
      if (icon != null) 'icon': icon,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
    };
  }

  StepConfig copyWith({
    String? stepId,
    String? stepType,
    String? title,
    String? subtitle,
    List<FieldConfig>? fields,
    NavigationConfig? navigation,
    ApiConfig? apiConfig,
    bool? showProgress,
    bool? skippable,
    String? skipMessage,
    bool? validateBeforeNavigate,
    String? instructions,
    String? icon,
    String? backgroundColor,
  }) {
    return StepConfig(
      stepId: stepId ?? this.stepId,
      stepType: stepType ?? this.stepType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fields: fields ?? this.fields,
      navigation: navigation ?? this.navigation,
      apiConfig: apiConfig ?? this.apiConfig,
      showProgress: showProgress ?? this.showProgress,
      skippable: skippable ?? this.skippable,
      skipMessage: skipMessage ?? this.skipMessage,
      validateBeforeNavigate: validateBeforeNavigate ?? this.validateBeforeNavigate,
      instructions: instructions ?? this.instructions,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [
        stepId,
        stepType,
        title,
        subtitle,
        fields,
        navigation,
        apiConfig,
        showProgress,
        skippable,
        skipMessage,
        validateBeforeNavigate,
        instructions,
        icon,
        backgroundColor,
      ];
}
