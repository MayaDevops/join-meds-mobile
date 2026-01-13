import 'package:equatable/equatable.dart';

class ApiConfig extends Equatable {
  final String endpoint;
  final String method;
  final Map<String, String>? fieldMapping;
  final Map<String, dynamic>? staticParams;
  final Map<String, String>? headers;
  final bool? isMultipart;
  final String? successMessage;
  final String? errorMessage;
  final bool? showLoading;
  final int? timeout;

  const ApiConfig({
    required this.endpoint,
    required this.method,
    this.fieldMapping,
    this.staticParams,
    this.headers,
    this.isMultipart,
    this.successMessage,
    this.errorMessage,
    this.showLoading,
    this.timeout,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      fieldMapping: json['fieldMapping'] != null
          ? Map<String, String>.from(json['fieldMapping'] as Map)
          : null,
      staticParams: json['staticParams'] as Map<String, dynamic>?,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      isMultipart: json['isMultipart'] as bool?,
      successMessage: json['successMessage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      showLoading: json['showLoading'] as bool?,
      timeout: json['timeout'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      if (fieldMapping != null) 'fieldMapping': fieldMapping,
      if (staticParams != null) 'staticParams': staticParams,
      if (headers != null) 'headers': headers,
      if (isMultipart != null) 'isMultipart': isMultipart,
      if (successMessage != null) 'successMessage': successMessage,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (showLoading != null) 'showLoading': showLoading,
      if (timeout != null) 'timeout': timeout,
    };
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
