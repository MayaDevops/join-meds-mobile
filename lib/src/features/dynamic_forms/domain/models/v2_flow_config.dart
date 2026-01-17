import 'v2_step_config.dart';

/// V2 Flow configuration - a graph of steps
class V2FlowConfig {
  /// Unique flow identifier (e.g., "b_pharm", "mbbs")
  final String id;

  /// Display name
  final String displayName;

  /// Starting step ID
  final String startStep;

  /// Map of step ID to step config
  final Map<String, V2StepConfig> steps;

  const V2FlowConfig({
    required this.id,
    required this.displayName,
    required this.startStep,
    required this.steps,
  });

  factory V2FlowConfig.fromJson(String id, Map<String, dynamic> json) {
    final stepsMap = <String, V2StepConfig>{};

    if (json['steps'] != null) {
      final stepsJson = json['steps'] as Map<String, dynamic>;
      stepsJson.forEach((stepId, stepData) {
        stepsMap[stepId] = V2StepConfig.fromJson(
          stepId,
          stepData as Map<String, dynamic>,
        );
      });
    }

    return V2FlowConfig(
      id: id,
      displayName: json['displayName'] as String,
      startStep: json['startStep'] as String,
      steps: stepsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'startStep': startStep,
      'steps': steps.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Get step by ID
  V2StepConfig? getStep(String stepId) => steps[stepId];

  /// Get the starting step
  V2StepConfig? get firstStep => steps[startStep];

  /// Get total number of steps
  int get totalSteps => steps.length;
}

/// V2 Profession metadata
class V2ProfessionMetadata {
  final String id;
  final String displayName;
  final String? icon;
  final String? description;

  const V2ProfessionMetadata({
    required this.id,
    required this.displayName,
    this.icon,
    this.description,
  });

  factory V2ProfessionMetadata.fromJson(Map<String, dynamic> json) {
    return V2ProfessionMetadata(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
    };
  }
}

/// V2 Form configuration - top level config for a profession
class V2FormConfig {
  /// Config version
  final String version;

  /// Profession metadata
  final V2ProfessionMetadata profession;

  /// Map of flow ID to flow config
  final Map<String, V2FlowConfig> flows;

  const V2FormConfig({
    required this.version,
    required this.profession,
    required this.flows,
  });

  factory V2FormConfig.fromJson(Map<String, dynamic> json) {
    final flowsMap = <String, V2FlowConfig>{};

    if (json['flows'] != null) {
      final flowsJson = json['flows'] as Map<String, dynamic>;
      flowsJson.forEach((flowId, flowData) {
        flowsMap[flowId] = V2FlowConfig.fromJson(
          flowId,
          flowData as Map<String, dynamic>,
        );
      });
    }

    return V2FormConfig(
      version: json['version'] as String? ?? '2.0.0',
      profession: V2ProfessionMetadata.fromJson(
        json['profession'] as Map<String, dynamic>,
      ),
      flows: flowsMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'profession': profession.toJson(),
      'flows': flows.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Get flow by ID
  V2FlowConfig? getFlow(String flowId) => flows[flowId];

  /// Get list of course types (flow IDs)
  List<String> get courseTypes => flows.keys.toList();

  /// Get the first/default flow
  V2FlowConfig? get defaultFlow => flows.isNotEmpty ? flows.values.first : null;
}
