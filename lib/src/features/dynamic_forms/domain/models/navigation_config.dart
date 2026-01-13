import 'package:equatable/equatable.dart';
import '../enums/action_type.dart';
import '../enums/navigation_type.dart';
import '../enums/operator_type.dart';

/// Represents a condition for navigation rules
class NavigationCondition extends Equatable {
  /// Field ID to check
  final String field;

  /// Operator for comparison
  final OperatorType operator;

  /// Value to compare against
  final dynamic value;

  /// List of values (for inList/notInList operators)
  final List<dynamic>? valueList;

  const NavigationCondition({
    required this.field,
    required this.operator,
    this.value,
    this.valueList,
  });

  factory NavigationCondition.fromJson(Map<String, dynamic> json) {
    return NavigationCondition(
      field: json['field'] as String,
      operator: (json['operator'] as String).toOperatorType(),
      value: json['value'],
      valueList: json['valueList'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'operator': operator.toShortString(),
      if (value != null) 'value': value,
      if (valueList != null) 'valueList': valueList,
    };
  }

  /// Evaluate the condition against form data
  bool evaluate(Map<String, dynamic> formData) {
    final fieldValue = formData[field];

    switch (operator) {
      case OperatorType.equals:
        return fieldValue == value;
      case OperatorType.notEquals:
        return fieldValue != value;
      case OperatorType.contains:
        return fieldValue?.toString().contains(value.toString()) ?? false;
      case OperatorType.notContains:
        return !(fieldValue?.toString().contains(value.toString()) ?? false);
      case OperatorType.isEmpty:
        return fieldValue == null || fieldValue.toString().isEmpty;
      case OperatorType.isNotEmpty:
        return fieldValue != null && fieldValue.toString().isNotEmpty;
      case OperatorType.greaterThan:
        final numValue = fieldValue as num?;
        return numValue != null && numValue > (value as num);
      case OperatorType.lessThan:
        final numValue = fieldValue as num?;
        return numValue != null && numValue < (value as num);
      case OperatorType.greaterThanOrEqual:
        final numValue = fieldValue as num?;
        return numValue != null && numValue >= (value as num);
      case OperatorType.lessThanOrEqual:
        final numValue = fieldValue as num?;
        return numValue != null && numValue <= (value as num);
      case OperatorType.inList:
        return valueList?.contains(fieldValue) ?? false;
      case OperatorType.notInList:
        return !(valueList?.contains(fieldValue) ?? false);
    }
  }

  @override
  List<Object?> get props => [field, operator, value, valueList];
}

/// Configuration for modal dialogs
class ModalConfig extends Equatable {
  /// Title of the modal
  final String title;

  /// Field ID to store the modal result
  final String fieldId;

  /// Options to display in the modal
  final List<Map<String, String>> options;

  /// Subtitle or description
  final String? subtitle;

  /// Whether to allow dismissing the modal
  final bool dismissible;

  const ModalConfig({
    required this.title,
    required this.fieldId,
    required this.options,
    this.subtitle,
    this.dismissible = true,
  });

  factory ModalConfig.fromJson(Map<String, dynamic> json) {
    return ModalConfig(
      title: json['title'] as String,
      fieldId: json['fieldId'] as String,
      options: (json['options'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      subtitle: json['subtitle'] as String?,
      dismissible: json['dismissible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'fieldId': fieldId,
      'options': options,
      if (subtitle != null) 'subtitle': subtitle,
      'dismissible': dismissible,
    };
  }

  @override
  List<Object?> get props => [title, fieldId, options, subtitle, dismissible];
}

/// Represents a navigation action to execute
class NavigationAction extends Equatable {
  /// Type of action
  final ActionType type;

  /// Next step ID (for navigate actions)
  final String? nextStep;

  /// Modal configuration (for showModal actions)
  final ModalConfig? modalConfig;

  /// Condition for conditional actions
  final NavigationCondition? condition;

  /// Message to display (for showMessage actions)
  final String? message;

  /// Field ID and value (for setField actions)
  final String? fieldId;
  final dynamic fieldValue;

  /// API endpoint (for apiCall actions)
  final String? apiEndpoint;

  const NavigationAction({
    required this.type,
    this.nextStep,
    this.modalConfig,
    this.condition,
    this.message,
    this.fieldId,
    this.fieldValue,
    this.apiEndpoint,
  });

  factory NavigationAction.fromJson(Map<String, dynamic> json) {
    return NavigationAction(
      type: (json['type'] as String).toActionType(),
      nextStep: json['nextStep'] as String?,
      modalConfig: json['modalConfig'] != null
          ? ModalConfig.fromJson(json['modalConfig'] as Map<String, dynamic>)
          : null,
      condition: json['condition'] != null
          ? NavigationCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      fieldId: json['fieldId'] as String?,
      fieldValue: json['fieldValue'],
      apiEndpoint: json['apiEndpoint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toShortString(),
      if (nextStep != null) 'nextStep': nextStep,
      if (modalConfig != null) 'modalConfig': modalConfig!.toJson(),
      if (condition != null) 'condition': condition!.toJson(),
      if (message != null) 'message': message,
      if (fieldId != null) 'fieldId': fieldId,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (apiEndpoint != null) 'apiEndpoint': apiEndpoint,
    };
  }

  @override
  List<Object?> get props => [
        type,
        nextStep,
        modalConfig,
        condition,
        message,
        fieldId,
        fieldValue,
        apiEndpoint,
      ];
}

/// Represents a navigation rule with condition and actions
class NavigationRule extends Equatable {
  /// Condition to evaluate
  final NavigationCondition condition;

  /// Actions to execute if condition is true
  final List<NavigationAction> actions;

  const NavigationRule({
    required this.condition,
    required this.actions,
  });

  factory NavigationRule.fromJson(Map<String, dynamic> json) {
    return NavigationRule(
      condition: NavigationCondition.fromJson(json['condition'] as Map<String, dynamic>),
      actions: (json['actions'] as List)
          .map((e) => NavigationAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition.toJson(),
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [condition, actions];
}

/// Configuration for navigation behavior
class NavigationConfig extends Equatable {
  /// Type of navigation
  final NavigationType type;

  /// Direct next step (for NavigationType.direct)
  final String? nextStep;

  /// Conditional navigation rules (for NavigationType.conditional)
  final List<NavigationRule>? rules;

  /// Default next step if no rules match
  final String? defaultNextStep;

  const NavigationConfig({
    required this.type,
    this.nextStep,
    this.rules,
    this.defaultNextStep,
  });

  factory NavigationConfig.fromJson(Map<String, dynamic> json) {
    return NavigationConfig(
      type: (json['type'] as String).toNavigationType(),
      nextStep: json['nextStep'] as String?,
      rules: json['rules'] != null
          ? (json['rules'] as List)
              .map((e) => NavigationRule.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      defaultNextStep: json['defaultNextStep'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toShortString(),
      if (nextStep != null) 'nextStep': nextStep,
      if (rules != null) 'rules': rules!.map((e) => e.toJson()).toList(),
      if (defaultNextStep != null) 'defaultNextStep': defaultNextStep,
    };
  }

  NavigationConfig copyWith({
    NavigationType? type,
    String? nextStep,
    List<NavigationRule>? rules,
    String? defaultNextStep,
  }) {
    return NavigationConfig(
      type: type ?? this.type,
      nextStep: nextStep ?? this.nextStep,
      rules: rules ?? this.rules,
      defaultNextStep: defaultNextStep ?? this.defaultNextStep,
    );
  }

  @override
  List<Object?> get props => [type, nextStep, rules, defaultNextStep];
}
