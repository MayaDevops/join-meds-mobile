import 'package:equatable/equatable.dart';
import 'enums/navigation_type.dart';
import 'enums/action_type.dart';
import 'enums/operator_type.dart';

class NavigationCondition extends Equatable {
  final String field;
  final OperatorType operator;
  final dynamic value;

  const NavigationCondition({
    required this.field,
    required this.operator,
    this.value,
  });

  factory NavigationCondition.fromJson(Map<String, dynamic> json) {
    return NavigationCondition(
      field: json['field'] as String,
      operator: (json['operator'] as String).toOperatorType(),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'operator': operator.toShortString(),
      if (value != null) 'value': value,
    };
  }

  @override
  List<Object?> get props => [field, operator, value];
}

class NavigationAction extends Equatable {
  final ActionType type;
  final String? nextStep;
  final NavigationCondition? condition;
  final Map<String, dynamic>? modalConfig;

  const NavigationAction({
    required this.type,
    this.nextStep,
    this.condition,
    this.modalConfig,
  });

  factory NavigationAction.fromJson(Map<String, dynamic> json) {
    return NavigationAction(
      type: (json['type'] as String).toActionType(),
      nextStep: json['nextStep'] as String?,
      condition: json['condition'] != null
          ? NavigationCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      modalConfig: json['modalConfig'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toShortString(),
      if (nextStep != null) 'nextStep': nextStep,
      if (condition != null) 'condition': condition!.toJson(),
      if (modalConfig != null) 'modalConfig': modalConfig,
    };
  }

  @override
  List<Object?> get props => [type, nextStep, condition, modalConfig];
}

class NavigationRule extends Equatable {
  final NavigationCondition condition;
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

class NavigationConfig extends Equatable {
  final NavigationType type;
  final String? nextStep;
  final List<NavigationRule>? rules;
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

  @override
  List<Object?> get props => [type, nextStep, rules, defaultNextStep];
}
