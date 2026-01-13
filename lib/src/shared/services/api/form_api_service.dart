import 'package:dio/dio.dart';

/// Reusable API service for form data submissions
/// Handles all API calls for dynamic forms
class FormApiService {
  final Dio _dio;
  final String _baseUrl;

  FormApiService({
    Dio? dio,
    String baseUrl = 'https://api.joinmeds.in',
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add common headers
          options.headers['Content-Type'] = 'application/json';
          print('API Request: ${options.method} ${options.uri}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Submit form data to a dynamic endpoint
  /// Replaces placeholders like {userId} with actual values
  Future<Map<String, dynamic>> submitFormData({
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
    Map<String, String>? pathParams,
    Map<String, String>? headers,
  }) async {
    try {
      // Replace path parameters
      String finalEndpoint = endpoint;
      if (pathParams != null) {
        pathParams.forEach((key, value) {
          finalEndpoint = finalEndpoint.replaceAll('{$key}', value);
        });
      }

      final url = '$_baseUrl$finalEndpoint';

      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(url, queryParameters: data);
          break;
        case 'POST':
          response = await _dio.post(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'PUT':
          response = await _dio.put(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'PATCH':
          response = await _dio.patch(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            url,
            data: data,
            options: Options(headers: headers),
          );
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': response.data,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      return {
        'success': false,
        'error': e.response?.data ?? e.message,
        'statusCode': e.response?.statusCode ?? 0,
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'statusCode': 0,
      };
    }
  }

  /// Update user details
  /// POST/PUT to /api/user-details/update/{userId}
  Future<Map<String, dynamic>> updateUserDetails({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    return await submitFormData(
      endpoint: '/api/user-details/update/$userId?userId=$userId',
      method: 'PUT',
      data: data,
      // pathParams: {'userId': userId},
    );
  }

  /// Save work experience
  /// POST to /api/work-experience/save
  Future<Map<String, dynamic>> saveWorkExperience({
    required String userId,
    required List<Map<String, dynamic>> experiences,
  }) async {
    return await submitFormData(
      endpoint: '/api/work-experience/save',
      method: 'POST',
      data: {
        'userId': userId,
        'experiences': experiences,
      },
    );
  }

  /// Fetch work experience
  /// GET /api/work-experience/fetch/{userId}
  Future<Map<String, dynamic>> fetchWorkExperience(String userId) async {
    try {
      final url = '$_baseUrl/api/work-experience/fetch/$userId';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Upload file (resume, certificate, etc.)
  /// POST to /api/resume/upload/{userId} or /api/images/upload/{userId}
  Future<Map<String, dynamic>> uploadFile({
    required String userId,
    required String filePath,
    required String fieldName,
    String endpoint = '/api/resume/upload',
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        'userId': userId,
      });

      final url = '$_baseUrl$endpoint/$userId';
      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generic method to map form fields to API fields
  /// Uses fieldMapping from ApiConfig
  Map<String, dynamic> mapFormDataToApi({
    required Map<String, dynamic> formData,
    required Map<String, String> fieldMapping,
  }) {
    final mappedData = <String, dynamic>{};

    formData.forEach((key, value) {
      // Use mapped name if exists, otherwise convert snake_case to camelCase
      final apiKey = fieldMapping[key] ?? _snakeToCamel(key);
      mappedData[apiKey] = value;
    });

    return mappedData;
  }

  /// Convert snake_case to camelCase
  /// Example: academic_status -> academicStatus
  String _snakeToCamel(String snakeCase) {
    if (!snakeCase.contains('_')) return snakeCase;

    final parts = snakeCase.split('_');
    if (parts.isEmpty) return snakeCase;

    // First part stays lowercase, rest are capitalized
    return parts.first +
        parts
            .skip(1)
            .map((part) => part.isEmpty
                ? ''
                : part[0].toUpperCase() + part.substring(1).toLowerCase())
            .join('');
  }

  /// Batch submit multiple form steps
  Future<List<Map<String, dynamic>>> batchSubmit({
    required List<Map<String, dynamic>> submissions,
  }) async {
    final results = <Map<String, dynamic>>[];

    for (final submission in submissions) {
      final result = await submitFormData(
        endpoint: submission['endpoint'] as String,
        method: submission['method'] as String,
        data: submission['data'] as Map<String, dynamic>,
        pathParams: submission['pathParams'] as Map<String, String>?,
      );
      results.add(result);

      // Stop on first error if needed
      if (!result['success']) {
        print('Batch submission failed at: ${submission['endpoint']}');
        // Could add option to continue or stop on error
      }
    }

    return results;
  }

  /// Retry failed submission
  Future<Map<String, dynamic>> retrySubmission({
    required String endpoint,
    required String method,
    required Map<String, dynamic> data,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    Map<String, dynamic> result = {};

    while (attempts < maxRetries) {
      result = await submitFormData(
        endpoint: endpoint,
        method: method,
        data: data,
      );

      if (result['success']) {
        return result;
      }

      attempts++;
      if (attempts < maxRetries) {
        print('Retry attempt $attempts/$maxRetries after ${retryDelay.inSeconds}s');
        await Future.delayed(retryDelay);
      }
    }

    return result;
  }
}
