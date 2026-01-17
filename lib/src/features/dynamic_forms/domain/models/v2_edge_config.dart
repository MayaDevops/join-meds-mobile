/// V2 Edge configuration for graph-based navigation
class V2EdgeConfig {
  /// Condition for this edge (optional for default/unconditional edges)
  /// Example: {"academicStatus": "ongoing"}
  final Map<String, dynamic>? when;

  /// Target step ID to navigate to
  /// Use "_complete" for flow completion
  final String goto;

  const V2EdgeConfig({this.when, required this.goto});

  factory V2EdgeConfig.fromJson(Map<String, dynamic> json) {
    return V2EdgeConfig(
      when: json['when'] as Map<String, dynamic>?,
      goto: json['goto'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {if (when != null) 'when': when, 'goto': goto};
  }

  /// Check if this edge's condition matches the form data
  bool matches(Map<String, dynamic> formData) {
    // No condition = always matches (default edge)
    if (when == null || when!.isEmpty) {
      return true;
    }

    // All conditions must match
    for (final entry in when!.entries) {
      final fieldId = entry.key;
      final expectedValue = entry.value;
      final actualValue = formData[fieldId];

      if (actualValue != expectedValue) {
        return false;
      }
    }

    return true;
  }

  /// Check if this is the completion edge
  bool get isComplete => goto == '_complete';
}
