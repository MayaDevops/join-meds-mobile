import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/v2/common/api_response.dart';

class ApiClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  ApiClient() {
    _authInterceptor = AuthInterceptor();

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      if (kDebugMode) LoggingInterceptor(),
      RetryInterceptor(maxRetries: 2),
    ]);
  }

  // Set auth token
  void setAuthToken(String token) {
    _authInterceptor.setToken(token);
  }

  // Clear auth token
  void clearAuthToken() {
    _authInterceptor.clearToken();
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart form data (for file uploads)
  Future<Response<T>> postFormData<T>(
    String path, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out. Please try again.');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return ApiException('Security certificate error');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ApiException('Request was cancelled');

      case DioExceptionType.unknown:
      default:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return NetworkException('No internet connection. Please check your network.');
        }
        return ApiException('Something went wrong. Please try again.');
    }
  }

  ApiException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    // Try to extract error message from response
    String message = 'Unknown error';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      errors = data['errors'] as Map<String, dynamic>?;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 422:
        return ValidationException(message, errors);
      case 500:
        return ServerException(message);
      case 503:
        return ServiceUnavailableException(message);
      default:
        return ApiException(message, statusCode, data);
    }
  }

  // V2 Typed Methods - Return ApiResponse<T> wrapper

  /// GET request with typed response wrapped in ApiResponse
  Future<ApiResponse<T>> getTyped<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    final response = await get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }

  /// POST request with typed response wrapped in ApiResponse
  Future<ApiResponse<T>> postTyped<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    final response = await post(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }

  /// PUT request with typed response wrapped in ApiResponse
  Future<ApiResponse<T>> putTyped<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    final response = await put(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }

  /// DELETE request with typed response wrapped in ApiResponse
  Future<ApiResponse<T>> deleteTyped<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
    CancelToken? cancelToken,
  }) async {
    final response = await delete(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }

  /// POST request without response data (for operations that return void)
  Future<ApiResponse<void>> postVoid(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await post(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse<void>(
      success: response.data['success'] ?? true,
      message: response.data['message'] ?? '',
      error: response.data['error'],
    );
  }

  /// PUT request without response data
  Future<ApiResponse<void>> putVoid(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await put(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse<void>(
      success: response.data['success'] ?? true,
      message: response.data['message'] ?? '',
      error: response.data['error'],
    );
  }

  /// DELETE request without response data
  Future<ApiResponse<void>> deleteVoid(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await delete(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
    return ApiResponse<void>(
      success: response.data['success'] ?? true,
      message: response.data['message'] ?? '',
      error: response.data['error'],
    );
  }

  /// GET request with list response wrapped in ApiResponse
  Future<ApiResponse<List<T>>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
    String dataKey = 'data',
    CancelToken? cancelToken,
  }) async {
    final response = await get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    return ApiResponse<List<T>>.fromJson(
      response.data,
      (data) {
        if (data is List) {
          return data
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data[dataKey] is List) {
          return (data[dataKey] as List)
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <T>[];
      },
    );
  }

  /// Upload file using multipart form data wrapped in ApiResponse
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required FormData data,
    required T Function(dynamic) fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final response = await postFormData(
      path,
      data: data,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }
}
