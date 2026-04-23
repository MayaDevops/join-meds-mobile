import 'package:equatable/equatable.dart';

/// Configuration for API calls when submitting form data
class ApiConfig extends Equatable {
  /// API endpoint path
  /// Supports placeholders like {userId}
  /// Example: "/api/user-details/update/{userId}"
  final String endpoint;

  /// HTTP method (GET, POST, PUT, DELETE, PATCH)
  final String method;

  /// Mapping of field IDs to API parameter names
  /// Example: {"academicStatus": "academic_status", "university": "university"}
  final Map<String, String>? fieldMapping;

  /// Additional static parameters to include in API call
  /// Example: {"source": "mobile_app", "version": "2.0"}
  final Map<String, dynamic>? staticParams;

  /// Headers to include in the API request
  /// Example: {"Content-Type": "application/json"}
  final Map<String, String>? headers;

  /// Whether to send data as multipart/form-data
  /// Used for file uploads
  final bool isMultipart;

  /// Success message to show after API call
  final String? successMessage;

  /// Error message to show if API call fails
  final String? errorMessage;

  /// Whether to show loading indicator during API call
  final bool showLoading;

  /// Timeout in milliseconds
  final int? timeout;

  const ApiConfig({
    required this.endpoint,
    this.method = 'POST',
    this.fieldMapping,
    this.staticParams,
    this.headers,
    this.isMultipart = false,
    this.successMessage,
    this.errorMessage,
    this.showLoading = true,
    this.timeout,
  });

  /// Create ApiConfig from JSON
  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      endpoint: json['endpoint'] as String,
      method: (json['method'] as String?)?.toUpperCase() ?? 'POST',
      fieldMapping: json['fieldMapping'] != null
          ? Map<String, String>.from(json['fieldMapping'] as Map)
          : null,
      staticParams: json['staticParams'] as Map<String, dynamic>?,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      isMultipart: json['isMultipart'] as bool? ?? false,
      successMessage: json['successMessage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      showLoading: json['showLoading'] as bool? ?? true,
      timeout: json['timeout'] as int?,
    );
  }

  /// Convert ApiConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      if (fieldMapping != null) 'fieldMapping': fieldMapping,
      if (staticParams != null) 'staticParams': staticParams,
      if (headers != null) 'headers': headers,
      'isMultipart': isMultipart,
      if (successMessage != null) 'successMessage': successMessage,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'showLoading': showLoading,
      if (timeout != null) 'timeout': timeout,
    };
  }

  /// Create a copy with updated fields
  ApiConfig copyWith({
    String? endpoint,
    String? method,
    Map<String, String>? fieldMapping,
    Map<String, dynamic>? staticParams,
    Map<String, String>? headers,
    bool? isMultipart,
    String? successMessage,
    String? errorMessage,
    bool? showLoading,
    int? timeout,
  }) {
    return ApiConfig(
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      fieldMapping: fieldMapping ?? this.fieldMapping,
      staticParams: staticParams ?? this.staticParams,
      headers: headers ?? this.headers,
      isMultipart: isMultipart ?? this.isMultipart,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      showLoading: showLoading ?? this.showLoading,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  List<Object?> get props => [
        endpoint,
        method,
        fieldMapping,
        staticParams,
        headers,
        isMultipart,
        successMessage,
        errorMessage,
        showLoading,
        timeout,
      ];
}
