import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  void clearToken() {
    _authToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_authToken != null && _authToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      // You can emit an event here to trigger logout
      debugPrint('AuthInterceptor: Unauthorized - Token may be expired');
    }
    handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ REQUEST');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ ${options.method} ${options.uri}');
      debugPrint('║ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('║ Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('║ Query: ${options.queryParameters}');
      }
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ RESPONSE');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Status: ${response.statusCode}');
      debugPrint('║ ${response.requestOptions.method} ${response.requestOptions.uri}');
      debugPrint('║ Data: ${response.data}');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════');
      debugPrint('║ ERROR');
      debugPrint('╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Status: ${err.response?.statusCode}');
      debugPrint('║ ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('║ Message: ${err.message}');
      debugPrint('║ Response: ${err.response?.data}');
      debugPrint('╚══════════════════════════════════════════════════════════════');
      debugPrint('');
    }
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Only retry on network errors or 5xx server errors
    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      await Future.delayed(retryDelay * (retryCount + 1));

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      if (kDebugMode) {
        debugPrint('RetryInterceptor: Retrying request (${retryCount + 1}/$maxRetries)');
      }

      try {
        final dio = Dio();
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with error handling
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
