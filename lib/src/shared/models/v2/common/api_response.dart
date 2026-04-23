/// Generic API response wrapper for V2 API
/// Provides consistent structure for all API responses
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  /// Creates ApiResponse from JSON with type-safe data parsing
  ///
  /// [json] - The JSON response from API
  /// [fromJsonT] - Optional function to parse the data field
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] as Map<String, dynamic>?,
    );
  }

  /// Converts ApiResponse to JSON
  Map<String, dynamic> toJson(Object? Function(T?)? toJsonT) {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data) : data,
      if (error != null) 'error': error,
    };
  }

  /// Returns true if the response is successful and has data
  bool get hasData => success && data != null;

  /// Returns error message if available
  String? get errorMessage => error?['message'] as String?;
}
