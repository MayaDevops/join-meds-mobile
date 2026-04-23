/// V2 Field configuration
class V2FieldConfig {
  /// Unique field identifier
  final String id;

  /// Field type: text, radio, dropdown, date, grid, list
  final String type;

  /// Display label
  final String? label;

  /// Hint text for input fields
  final String? hint;

  /// Whether field is required
  final bool required;

  /// Options for selection fields (radio, dropdown, grid)
  final List<V2FieldOption>? options;

  /// Data source path for dynamic options (e.g., "shared/universities")
  final String? source;

  /// Allow custom input (for grid type)
  final bool allowCustom;

  /// Custom input hint text
  final String? customHint;

  /// Template fields for list type
  final List<V2FieldConfig>? template;

  /// Min/max entries for list type
  final int? minEntries;
  final int? maxEntries;

  /// 🔥 NEW: Conditional visibility rule
  /// Example: { "hasForeignExam": "yes" }
  final Map<String, dynamic>? visibleWhen;

  const V2FieldConfig({
    required this.id,
    required this.type,
    this.label,
    this.hint,
    this.required = false,
    this.options,
    this.source,
    this.allowCustom = false,
    this.customHint,
    this.template,
    this.minEntries,
    this.maxEntries,
    this.visibleWhen, // 🔥 NEW
  }) : assert(
  options == null || source == null,
  'V2FieldConfig "$id" cannot have both "options" and "source". '
      'Use one or the other.',
  );

  factory V2FieldConfig.fromJson(Map<String, dynamic> json) {
    // Handle simple string options (e.g., ["1st Year", "2nd Year"])
    List<V2FieldOption>? options;
    if (json['options'] != null) {
      final optionsList = json['options'] as List;
      options = optionsList.map((opt) {
        if (opt is String) {
          return V2FieldOption(value: opt.toLowerCase(), label: opt);
        } else if (opt is Map<String, dynamic>) {
          return V2FieldOption.fromJson(opt);
        }
        return V2FieldOption(value: opt.toString(), label: opt.toString());
      }).toList();
    }

    // Handle template for list fields
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
      customHint: json['customHint'] as String?,
      template: template,
      minEntries: json['minEntries'] as int?,
      maxEntries: json['maxEntries'] as int?,

      // 🔥 NEW
      visibleWhen: json['visibleWhen'] != null
          ? Map<String, dynamic>.from(json['visibleWhen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (label != null) 'label': label,
      if (hint != null) 'hint': hint,
      if (required) 'required': required,
      if (options != null) 'options': options!.map((o) => o.toJson()).toList(),
      if (source != null) 'source': source,
      if (allowCustom) 'allowCustom': allowCustom,
      if (customHint != null) 'customHint': customHint,
      if (template != null)
        'template': template!.map((t) => t.toJson()).toList(),
      if (minEntries != null) 'minEntries': minEntries,
      if (maxEntries != null) 'maxEntries': maxEntries,

      // 🔥 NEW
      if (visibleWhen != null) 'visibleWhen': visibleWhen,
    };
  }
}


/// Option for selection fields
class V2FieldOption {
  final String value;
  final String label;
  final String? icon;
  final String? description;

  const V2FieldOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
  });

  factory V2FieldOption.fromJson(Map<String, dynamic> json) {
    return V2FieldOption(
      value: json['value'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
    };
  }
}
