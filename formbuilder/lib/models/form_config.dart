import 'package:equatable/equatable.dart';
import 'step_config.dart';

class ProfessionMetadata extends Equatable {
  final String id;
  final String displayName;
  final List<String> courseTypes;
  final String? icon;
  final String? description;

  const ProfessionMetadata({
    required this.id,
    required this.displayName,
    required this.courseTypes,
    this.icon,
    this.description,
  });

  factory ProfessionMetadata.fromJson(Map<String, dynamic> json) {
    return ProfessionMetadata(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      courseTypes: List<String>.from(json['courseTypes'] as List),
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'courseTypes': courseTypes,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [id, displayName, courseTypes, icon, description];
}

class FlowConfig extends Equatable {
  final String flowId;
  final String displayName;
  final List<StepConfig> steps;
  final String? initialStepId;

  const FlowConfig({
    required this.flowId,
    required this.displayName,
    required this.steps,
    this.initialStepId,
  });

  factory FlowConfig.fromJson(Map<String, dynamic> json) {
    return FlowConfig(
      flowId: json['flowId'] as String,
      displayName: json['displayName'] as String,
      steps: (json['steps'] as List)
          .map((e) => StepConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      initialStepId: json['initialStepId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flowId': flowId,
      'displayName': displayName,
      'steps': steps.map((e) => e.toJson()).toList(),
      if (initialStepId != null) 'initialStepId': initialStepId,
    };
  }

  StepConfig? getStepById(String stepId) {
    try {
      return steps.firstWhere((step) => step.stepId == stepId);
    } catch (e) {
      return null;
    }
  }

  int getStepIndex(String stepId) {
    return steps.indexWhere((step) => step.stepId == stepId);
  }

  @override
  List<Object?> get props => [flowId, displayName, steps, initialStepId];
}

class FormConfig extends Equatable {
  final String version;
  final ProfessionMetadata profession;
  final Map<String, FlowConfig> flows;
  final Map<String, String>? sharedDataPaths;
  final String? lastUpdated;

  const FormConfig({
    required this.version,
    required this.profession,
    required this.flows,
    this.sharedDataPaths,
    this.lastUpdated,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) {
    final flowsMap = <String, FlowConfig>{};
    if (json['flows'] != null) {
      (json['flows'] as Map<String, dynamic>).forEach((key, value) {
        flowsMap[key] = FlowConfig.fromJson(value as Map<String, dynamic>);
      });
    }

    return FormConfig(
      version: json['version'] as String,
      profession: ProfessionMetadata.fromJson(json['profession'] as Map<String, dynamic>),
      flows: flowsMap,
      sharedDataPaths: json['sharedDataPaths'] != null
          ? Map<String, String>.from(json['sharedDataPaths'] as Map)
          : null,
      lastUpdated: json['lastUpdated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'profession': profession.toJson(),
      'flows': flows.map((key, value) => MapEntry(key, value.toJson())),
      if (sharedDataPaths != null) 'sharedDataPaths': sharedDataPaths,
      if (lastUpdated != null) 'lastUpdated': lastUpdated,
    };
  }

  FlowConfig? getFlowById(String flowId) {
    return flows[flowId];
  }

  FlowConfig? getDefaultFlow() {
    if (profession.courseTypes.isEmpty) return null;
    return flows[profession.courseTypes.first];
  }

  FormConfig copyWith({
    String? version,
    ProfessionMetadata? profession,
    Map<String, FlowConfig>? flows,
    Map<String, String>? sharedDataPaths,
    String? lastUpdated,
  }) {
    return FormConfig(
      version: version ?? this.version,
      profession: profession ?? this.profession,
      flows: flows ?? this.flows,
      sharedDataPaths: sharedDataPaths ?? this.sharedDataPaths,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        version,
        profession,
        flows,
        sharedDataPaths,
        lastUpdated,
      ];
}
