import 'v2_api_config.dart';
import 'v2_edge_config.dart';
import 'v2_field_config.dart';

/// V2 Step configuration - a node in the flow graph
class V2StepConfig {
  /// Unique step identifier
  final String id;

  /// Step type: cardSelection, form, modal, grid, list
  final String type;

  /// Display title
  final String title;

  /// Subtitle or description
  final String? subtitle;

  /// Single field for selection steps (cardSelection, modal)
  final V2FieldConfig? field;

  /// Multiple fields for form steps
  final List<V2FieldConfig>? fields;

  /// Template fields for list steps
  final List<V2FieldConfig>? template;

  /// Whether step can be skipped
  final bool skippable;

  /// Skip button text
  final String? skipText;

  /// API configuration for this step
  final V2ApiConfig? api;

  /// Navigation edges to other steps
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
    this.skipText,
    this.api,
    required this.edges,
  });

  factory V2StepConfig.fromJson(String id, Map<String, dynamic> json) {
    // Parse field (single)
    V2FieldConfig? field;
    if (json['field'] != null) {
      field = V2FieldConfig.fromJson(json['field'] as Map<String, dynamic>);
    }

    // Parse fields (multiple)
    List<V2FieldConfig>? fields;
    if (json['fields'] != null) {
      fields = (json['fields'] as List)
          .map((f) => V2FieldConfig.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    // Parse template
    List<V2FieldConfig>? template;
    if (json['template'] != null) {
      template = (json['template'] as List)
          .map((t) => V2FieldConfig.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    // Parse API config
    V2ApiConfig? api;
    if (json['api'] != null) {
      api = V2ApiConfig.fromJson(json['api'] as Map<String, dynamic>);
    }

    // Parse edges
    final edgesList = (json['edges'] as List?) ?? [];
    final edges = edgesList
        .map((e) => V2EdgeConfig.fromJson(e as Map<String, dynamic>))
        .toList();

    return V2StepConfig(
      id: id,
      type: json['type'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      field: field,
      fields: fields,
      template: template,
      skippable: json['skippable'] as bool? ?? false,
      skipText: json['skipText'] as String?,
      api: api,
      edges: edges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (field != null) 'field': field!.toJson(),
      if (fields != null) 'fields': fields!.map((f) => f.toJson()).toList(),
      if (template != null)
        'template': template!.map((t) => t.toJson()).toList(),
      if (skippable) 'skippable': skippable,
      if (skipText != null) 'skipText': skipText,
      if (api != null) 'api': api!.toJson(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }

  /// Get all fields from this step (combines field, fields, and template)
  List<V2FieldConfig> getAllFields() {
    final allFields = <V2FieldConfig>[];

    if (field != null) {
      allFields.add(field!);
    }

    if (fields != null) {
      allFields.addAll(fields!);
    }

    if (template != null) {
      allFields.addAll(template!);
    }

    return allFields;
  }

  /// Find the next step based on current form data
  String? getNextStepId(Map<String, dynamic> formData) {
    for (final edge in edges) {
      if (edge.matches(formData)) {
        return edge.isComplete ? null : edge.goto;
      }
    }
    return null;
  }

  /// Check if this step leads to flow completion
  bool isLastStep(Map<String, dynamic> formData) {
    for (final edge in edges) {
      if (edge.matches(formData) && edge.isComplete) {
        return true;
      }
    }
    return false;
  }
}
