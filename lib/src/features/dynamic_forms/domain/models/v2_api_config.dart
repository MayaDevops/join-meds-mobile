/// V2 API configuration for step submissions
class V2ApiConfig {
  /// API endpoint path
  final String endpoint;

  /// HTTP method (POST, PUT, etc.)
  final String method;

  /// Field mapping from form field ID to API field name
  /// Example: {"currentYear": "currentYear", "university": "university"}
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

  Map<String, dynamic> toJson() {
    return {'endpoint': endpoint, 'method': method, 'mapping': mapping};
  }

  /// Build request body from form data
  /// Only includes fields that are in the mapping
  Map<String, dynamic> buildRequestBody(
    Map<String, dynamic> formData,
    String userId,
  ) {
    final body = <String, dynamic>{'userId': userId};

    for (final entry in mapping.entries) {
      final formFieldId = entry.key;
      final apiFieldName = entry.value;

      if (formData.containsKey(formFieldId)) {
        body[apiFieldName] = formData[formFieldId];
      }
    }

    return body;
  }
}
