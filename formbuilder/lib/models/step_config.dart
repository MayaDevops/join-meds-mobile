import 'package:equatable/equatable.dart';
import 'field_config.dart';
import 'navigation_config.dart';
import 'api_config.dart';

class StepConfig extends Equatable {
  final String stepId;
  final String stepType;
  final String title;
  final String? subtitle;
  final List<FieldConfig> fields;
  final NavigationConfig? navigation;
  final ApiConfig? apiConfig;
  final bool? showProgress;
  final bool? skippable;
  final String? skipMessage;
  final bool? validateBeforeNavigate;
  final String? instructions;
  final String? icon;
  final String? backgroundColor;

  const StepConfig({
    required this.stepId,
    required this.stepType,
    required this.title,
    this.subtitle,
    this.fields = const [],
    this.navigation,
    this.apiConfig,
    this.showProgress,
    this.skippable,
    this.skipMessage,
    this.validateBeforeNavigate,
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
      fields: json['fields'] != null
          ? (json['fields'] as List)
              .map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      navigation: json['navigation'] != null
          ? NavigationConfig.fromJson(json['navigation'] as Map<String, dynamic>)
          : null,
      apiConfig: json['apiConfig'] != null
          ? ApiConfig.fromJson(json['apiConfig'] as Map<String, dynamic>)
          : null,
      showProgress: json['showProgress'] as bool?,
      skippable: json['skippable'] as bool?,
      skipMessage: json['skipMessage'] as String?,
      validateBeforeNavigate: json['validateBeforeNavigate'] as bool?,
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
      if (showProgress != null) 'showProgress': showProgress,
      if (skippable != null) 'skippable': skippable,
      if (skipMessage != null) 'skipMessage': skipMessage,
      if (validateBeforeNavigate != null)
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
