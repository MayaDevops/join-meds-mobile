import 'package:equatable/equatable.dart';
import '../enums/field_type.dart';
import 'validation_config.dart';

/// Represents a single option in a field (radio, dropdown, etc.)
class FieldOption extends Equatable {
  /// The value that will be stored
  final String value;

  /// The label to display to the user
  final String label;

  /// Optional icon name for card selection fields
  /// Example: "menu_book", "school", "work"
  final String? icon;

  /// Optional description for the option
  final String? description;

  const FieldOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
  });

  factory FieldOption.fromJson(Map<String, dynamic> json) {
    return FieldOption(
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

  @override
  List<Object?> get props => [value, label, icon, description];
}

/// Configuration for data source (Firebase, API, static)
class DataSourceConfig extends Equatable {
  /// Type of data source: "firebase", "api", "static"
  final String type;

  /// Path or endpoint for the data source
  /// Example: "shared_data/universities/india"
  final String? path;

  /// Static data if type is "static"
  final List<String>? staticData;

  /// Cache key for local storage
  final String? cacheKey;

  /// Cache duration in minutes
  final int? cacheDuration;

  const DataSourceConfig({
    required this.type,
    this.path,
    this.staticData,
    this.cacheKey,
    this.cacheDuration,
  });

  factory DataSourceConfig.fromJson(Map<String, dynamic> json) {
    return DataSourceConfig(
      type: json['type'] as String,
      path: json['path'] as String?,
      staticData: json['staticData'] != null
          ? List<String>.from(json['staticData'] as List)
          : null,
      cacheKey: json['cacheKey'] as String?,
      cacheDuration: json['cacheDuration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (path != null) 'path': path,
      if (staticData != null) 'staticData': staticData,
      if (cacheKey != null) 'cacheKey': cacheKey,
      if (cacheDuration != null) 'cacheDuration': cacheDuration,
    };
  }

  @override
  List<Object?> get props => [type, path, staticData, cacheKey, cacheDuration];
}

/// Configuration for a form field
class FieldConfig extends Equatable {
  /// Unique identifier for the field
  final String fieldId;

  /// Type of the field (radio, dropdown, text, etc.)
  final FieldType fieldType;

  /// Label to display above the field
  final String label;

  /// Hint text or placeholder
  final String? hint;

  /// Whether the field is required
  final bool required;

  /// List of options for selection fields (radio, dropdown, grid)
  final List<FieldOption>? options;

  /// Validation rules for the field
  final ValidationConfig? validation;

  /// Data source configuration for dynamic options
  final DataSourceConfig? dataSource;

  /// Mapping to API parameter name
  /// Example: "currentYear" maps to "current_year"
  final String? apiMapping;

  /// Default value for the field
  final dynamic defaultValue;

  /// Whether the field is searchable (for dropdown)
  final bool searchable;

  /// Layout for radio buttons: "row", "column", "wrap"
  final String? layout;

  /// For dynamicList fields: minimum number of entries
  final int? minEntries;

  /// For dynamicList fields: maximum number of entries
  final int? maxEntries;

  /// For dynamicList fields: template of fields for each entry
  final List<FieldConfig>? template;

  /// For dynamicList fields: text for "Add More" button
  final String? addButtonText;

  /// For grid fields: number of columns
  final int? gridColumnCount;

  /// Whether to show this field (can be conditional)
  final bool visible;

  /// Conditional visibility based on another field
  /// Example: {"field": "academicStatus", "equals": "completed"}
  final Map<String, dynamic>? visibilityCondition;

  /// Read-only field (cannot be edited)
  final bool readOnly;

  /// Keyboard type for text fields
  /// Options: "text", "number", "email", "phone", "url"
  final String? keyboardType;

  /// Maximum lines for text input
  final int? maxLines;

  /// Minimum lines for text input
  final int? minLines;

  const FieldConfig({
    required this.fieldId,
    required this.fieldType,
    required this.label,
    this.hint,
    this.required = false,
    this.options,
    this.validation,
    this.dataSource,
    this.apiMapping,
    this.defaultValue,
    this.searchable = false,
    this.layout,
    this.minEntries,
    this.maxEntries,
    this.template,
    this.addButtonText,
    this.gridColumnCount,
    this.visible = true,
    this.visibilityCondition,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines,
    this.minLines,
  });

  factory FieldConfig.fromJson(Map<String, dynamic> json) {
    return FieldConfig(
      fieldId: json['fieldId'] as String,
      fieldType: (json['fieldType'] as String).toFieldType(),
      label: json['label'] as String,
      hint: json['hint'] as String?,
      required: json['required'] as bool? ?? false,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((e) => FieldOption.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      validation: json['validation'] != null
          ? ValidationConfig.fromJson(json['validation'] as Map<String, dynamic>)
          : null,
      dataSource: json['dataSource'] != null
          ? DataSourceConfig.fromJson(json['dataSource'] as Map<String, dynamic>)
          : null,
      apiMapping: json['apiMapping'] as String?,
      defaultValue: json['defaultValue'],
      searchable: json['searchable'] as bool? ?? false,
      layout: json['layout'] as String?,
      minEntries: json['minEntries'] as int?,
      maxEntries: json['maxEntries'] as int?,
      template: json['template'] != null
          ? (json['template'] as List)
              .map((e) => FieldConfig.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      addButtonText: json['addButtonText'] as String?,
      gridColumnCount: json['gridColumnCount'] as int?,
      visible: json['visible'] as bool? ?? true,
      visibilityCondition: json['visibilityCondition'] as Map<String, dynamic>?,
      readOnly: json['readOnly'] as bool? ?? false,
      keyboardType: json['keyboardType'] as String?,
      maxLines: json['maxLines'] as int?,
      minLines: json['minLines'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldType': fieldType.toShortString(),
      'label': label,
      if (hint != null) 'hint': hint,
      'required': required,
      if (options != null) 'options': options!.map((e) => e.toJson()).toList(),
      if (validation != null) 'validation': validation!.toJson(),
      if (dataSource != null) 'dataSource': dataSource!.toJson(),
      if (apiMapping != null) 'apiMapping': apiMapping,
      if (defaultValue != null) 'defaultValue': defaultValue,
      'searchable': searchable,
      if (layout != null) 'layout': layout,
      if (minEntries != null) 'minEntries': minEntries,
      if (maxEntries != null) 'maxEntries': maxEntries,
      if (template != null) 'template': template!.map((e) => e.toJson()).toList(),
      if (addButtonText != null) 'addButtonText': addButtonText,
      if (gridColumnCount != null) 'gridColumnCount': gridColumnCount,
      'visible': visible,
      if (visibilityCondition != null) 'visibilityCondition': visibilityCondition,
      'readOnly': readOnly,
      if (keyboardType != null) 'keyboardType': keyboardType,
      if (maxLines != null) 'maxLines': maxLines,
      if (minLines != null) 'minLines': minLines,
    };
  }

  FieldConfig copyWith({
    String? fieldId,
    FieldType? fieldType,
    String? label,
    String? hint,
    bool? required,
    List<FieldOption>? options,
    ValidationConfig? validation,
    DataSourceConfig? dataSource,
    String? apiMapping,
    dynamic defaultValue,
    bool? searchable,
    String? layout,
    int? minEntries,
    int? maxEntries,
    List<FieldConfig>? template,
    String? addButtonText,
    int? gridColumnCount,
    bool? visible,
    Map<String, dynamic>? visibilityCondition,
    bool? readOnly,
    String? keyboardType,
    int? maxLines,
    int? minLines,
  }) {
    return FieldConfig(
      fieldId: fieldId ?? this.fieldId,
      fieldType: fieldType ?? this.fieldType,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      required: required ?? this.required,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      dataSource: dataSource ?? this.dataSource,
      apiMapping: apiMapping ?? this.apiMapping,
      defaultValue: defaultValue ?? this.defaultValue,
      searchable: searchable ?? this.searchable,
      layout: layout ?? this.layout,
      minEntries: minEntries ?? this.minEntries,
      maxEntries: maxEntries ?? this.maxEntries,
      template: template ?? this.template,
      addButtonText: addButtonText ?? this.addButtonText,
      gridColumnCount: gridColumnCount ?? this.gridColumnCount,
      visible: visible ?? this.visible,
      visibilityCondition: visibilityCondition ?? this.visibilityCondition,
      readOnly: readOnly ?? this.readOnly,
      keyboardType: keyboardType ?? this.keyboardType,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
    );
  }

  @override
  List<Object?> get props => [
        fieldId,
        fieldType,
        label,
        hint,
        required,
        options,
        validation,
        dataSource,
        apiMapping,
        defaultValue,
        searchable,
        layout,
        minEntries,
        maxEntries,
        template,
        addButtonText,
        gridColumnCount,
        visible,
        visibilityCondition,
        readOnly,
        keyboardType,
        maxLines,
        minLines,
      ];
}
