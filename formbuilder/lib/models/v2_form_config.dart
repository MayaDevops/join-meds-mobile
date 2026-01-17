/// V2 API Configuration
class V2ApiConfig {
  final String endpoint;
  final String method;
  final Map<String, String> mapping;

  const V2ApiConfig({
    required this.endpoint,
    required this.method,
    required this.mapping,
  });

  factory V2ApiConfig.fromJson(Map<String, dynamic> json) {
    return V2ApiConfig(
      endpoint: json['endpoint'] as String,
      method: json['method'] as String? ?? 'POST',
      mapping: Map<String, String>.from(json['mapping'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'endpoint': endpoint,
    'method': method,
    'mapping': mapping,
  };

  V2ApiConfig copyWith({
    String? endpoint,
    String? method,
    Map<String, String>? mapping,
  }) {
    return V2ApiConfig(
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      mapping: mapping ?? this.mapping,
    );
  }
}

/// V2 Field Option
class V2FieldOption {
  final String value;
  final String label;
  final String? icon;

  const V2FieldOption({required this.value, required this.label, this.icon});

  factory V2FieldOption.fromJson(Map<String, dynamic> json) {
    return V2FieldOption(
      value: json['value'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'label': label,
    if (icon != null) 'icon': icon,
  };
}

/// V2 Field Configuration
class V2FieldConfig {
  final String id;
  final String type;
  final String? label;
  final String? hint;
  final bool required;
  final List<V2FieldOption>? options;
  final String? source;
  final bool allowCustom;
  final List<V2FieldConfig>? template;

  const V2FieldConfig({
    required this.id,
    required this.type,
    this.label,
    this.hint,
    this.required = false,
    this.options,
    this.source,
    this.allowCustom = false,
    this.template,
  });

  factory V2FieldConfig.fromJson(Map<String, dynamic> json) {
    List<V2FieldOption>? options;
    if (json['options'] != null) {
      final list = json['options'] as List;
      options = list.map((opt) {
        if (opt is String) {
          return V2FieldOption(value: opt, label: opt);
        }
        return V2FieldOption.fromJson(opt as Map<String, dynamic>);
      }).toList();
    }

    List<V2FieldConfig>? template;
    if (json['template'] != null) {
      template = (json['template'] as List)
          .map((t) => V2FieldConfig.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return V2FieldConfig(
      id: json['id'] as String,
      type: json['type'] as String,
      label: json['label'] as String?,
      hint: json['hint'] as String?,
      required: json['required'] as bool? ?? false,
      options: options,
      source: json['source'] as String?,
      allowCustom: json['allowCustom'] as bool? ?? false,
      template: template,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (label != null) 'label': label,
    if (hint != null) 'hint': hint,
    if (required) 'required': required,
    if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
    if (source != null) 'source': source,
    if (allowCustom) 'allowCustom': allowCustom,
    if (template != null) 'template': template!.map((t) => t.toJson()).toList(),
  };

  V2FieldConfig copyWith({
    String? id,
    String? type,
    String? label,
    String? hint,
    bool? required,
    List<V2FieldOption>? options,
    String? source,
    bool? allowCustom,
    List<V2FieldConfig>? template,
  }) {
    return V2FieldConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      required: required ?? this.required,
      options: options ?? this.options,
      source: source ?? this.source,
      allowCustom: allowCustom ?? this.allowCustom,
      template: template ?? this.template,
    );
  }
}

/// V2 Edge Configuration
class V2EdgeConfig {
  final Map<String, dynamic>? when;
  final String goto;

  const V2EdgeConfig({this.when, required this.goto});

  factory V2EdgeConfig.fromJson(Map<String, dynamic> json) {
    return V2EdgeConfig(
      when: json['when'] as Map<String, dynamic>?,
      goto: json['goto'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    if (when != null) 'when': when,
    'goto': goto,
  };

  V2EdgeConfig copyWith({Map<String, dynamic>? when, String? goto}) {
    return V2EdgeConfig(when: when ?? this.when, goto: goto ?? this.goto);
  }
}

/// V2 Step Configuration
class V2StepConfig {
  final String id;
  final String type;
  final String title;
  final String? subtitle;
  final V2FieldConfig? field;
  final List<V2FieldConfig>? fields;
  final List<V2FieldConfig>? template;
  final bool skippable;
  final V2ApiConfig? api;
  final List<V2EdgeConfig> edges;

  const V2StepConfig({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.field,
    this.fields,
    this.template,
    this.skippable = false,
    this.api,
    required this.edges,
  });

  factory V2StepConfig.fromJson(String id, Map<String, dynamic> json) {
    return V2StepConfig(
      id: id,
      type: json['type'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      field: json['field'] != null
          ? V2FieldConfig.fromJson(json['field'] as Map<String, dynamic>)
          : null,
      fields: json['fields'] != null
          ? (json['fields'] as List)
                .map((f) => V2FieldConfig.fromJson(f as Map<String, dynamic>))
                .toList()
          : null,
      template: json['template'] != null
          ? (json['template'] as List)
                .map((t) => V2FieldConfig.fromJson(t as Map<String, dynamic>))
                .toList()
          : null,
      skippable: json['skippable'] as bool? ?? false,
      api: json['api'] != null
          ? V2ApiConfig.fromJson(json['api'] as Map<String, dynamic>)
          : null,
      edges: ((json['edges'] as List?) ?? [])
          .map((e) => V2EdgeConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    if (subtitle != null) 'subtitle': subtitle,
    if (field != null) 'field': field!.toJson(),
    if (fields != null) 'fields': fields!.map((f) => f.toJson()).toList(),
    if (template != null) 'template': template!.map((t) => t.toJson()).toList(),
    if (skippable) 'skippable': skippable,
    if (api != null) 'api': api!.toJson(),
    'edges': edges.map((e) => e.toJson()).toList(),
  };

  V2StepConfig copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    V2FieldConfig? field,
    List<V2FieldConfig>? fields,
    List<V2FieldConfig>? template,
    bool? skippable,
    V2ApiConfig? api,
    List<V2EdgeConfig>? edges,
  }) {
    return V2StepConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      field: field ?? this.field,
      fields: fields ?? this.fields,
      template: template ?? this.template,
      skippable: skippable ?? this.skippable,
      api: api ?? this.api,
      edges: edges ?? this.edges,
    );
  }
}

/// V2 Flow Configuration
class V2FlowConfig {
  final String id;
  final String displayName;
  final String startStep;
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
      (json['steps'] as Map<String, dynamic>).forEach((stepId, stepData) {
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

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'startStep': startStep,
    'steps': steps.map((key, value) => MapEntry(key, value.toJson())),
  };

  V2FlowConfig copyWith({
    String? id,
    String? displayName,
    String? startStep,
    Map<String, V2StepConfig>? steps,
  }) {
    return V2FlowConfig(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      startStep: startStep ?? this.startStep,
      steps: steps ?? this.steps,
    );
  }
}

/// V2 Profession Metadata
class V2ProfessionMetadata {
  final String id;
  final String displayName;
  final String? icon;

  const V2ProfessionMetadata({
    required this.id,
    required this.displayName,
    this.icon,
  });

  factory V2ProfessionMetadata.fromJson(Map<String, dynamic> json) {
    return V2ProfessionMetadata(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    if (icon != null) 'icon': icon,
  };

  V2ProfessionMetadata copyWith({
    String? id,
    String? displayName,
    String? icon,
  }) {
    return V2ProfessionMetadata(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
    );
  }
}

/// V2 Form Configuration (top-level)
class V2FormConfig {
  final String version;
  final V2ProfessionMetadata profession;
  final Map<String, V2FlowConfig> flows;

  const V2FormConfig({
    required this.version,
    required this.profession,
    required this.flows,
  });

  factory V2FormConfig.fromJson(Map<String, dynamic> json) {
    final flowsMap = <String, V2FlowConfig>{};
    if (json['flows'] != null) {
      (json['flows'] as Map<String, dynamic>).forEach((flowId, flowData) {
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

  Map<String, dynamic> toJson() => {
    'version': version,
    'profession': profession.toJson(),
    'flows': flows.map((key, value) => MapEntry(key, value.toJson())),
  };

  V2FormConfig copyWith({
    String? version,
    V2ProfessionMetadata? profession,
    Map<String, V2FlowConfig>? flows,
  }) {
    return V2FormConfig(
      version: version ?? this.version,
      profession: profession ?? this.profession,
      flows: flows ?? this.flows,
    );
  }
}
