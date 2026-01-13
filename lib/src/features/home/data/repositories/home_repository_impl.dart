import 'package:dio/dio.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../shared/models/v2/common/api_response.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../shared/services/api/api_client.dart';
import '../../../../core/constants/v2_api_constants.dart';

/// Implementation of IHomeRepository
class HomeRepositoryImpl implements IHomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl(this._apiClient);

  @override
  Future<ApiResponse<List<JobDetailsDTO>>> fetchRecommendedJobs({
    int? limit,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.get(
        V2ApiConstants.fetchAllJobs,  // Using fetchAllJobs endpoint
        queryParameters: limit != null ? {'limit': limit.toString()} : null,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Handle direct array response (not wrapped in ApiResponse)
        if (response.data is List) {
          final jobs = (response.data as List<dynamic>)
              .map((json) => JobDetailsDTO.fromJson(json as Map<String, dynamic>))
              .toList();

          // Apply limit if specified
          final limitedJobs = limit != null && jobs.length > limit
              ? jobs.sublist(0, limit)
              : jobs;

          return ApiResponse<List<JobDetailsDTO>>(
            success: true,
            message: 'Jobs fetched successfully',
            data: limitedJobs,
          );
        }

        // Handle wrapped response
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final jobs = (apiResponse.data as List<dynamic>)
              .map((json) => JobDetailsDTO.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<JobDetailsDTO>>(
            success: true,
            message: apiResponse.message,
            data: jobs,
          );
        } else {
          return ApiResponse<List<JobDetailsDTO>>(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        return ApiResponse<List<JobDetailsDTO>>(
          success: false,
          message: 'Failed to fetch jobs',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<JobDetailsDTO>>(
        success: false,
        message: e.message ?? 'Network error occurred',
        data: null,
        error: {'dio_error': e.type.toString()},
      );
    } catch (e) {
      return ApiResponse<List<JobDetailsDTO>>(
        success: false,
        message: 'An unexpected error occurred',
        data: null,
        error: {'error': e.toString()},
      );
    }
  }

  @override
  Future<ApiResponse<void>> bookmarkJob(
    String jobId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.post(
        V2ApiConstants.bookmarkJob(jobId),
        data: {},
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: 'Job bookmarked successfully',
          data: null,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'Failed to bookmark job',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.message ?? 'Network error occurred',
        data: null,
        error: {'dio_error': e.type.toString()},
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred',
        data: null,
        error: {'error': e.toString()},
      );
    }
  }

  @override
  Future<ApiResponse<void>> removeBookmark(
    String jobId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.delete(
        V2ApiConstants.removeBookmark(jobId),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: 'Bookmark removed successfully',
          data: null,
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'Failed to remove bookmark',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.message ?? 'Network error occurred',
        data: null,
        error: {'dio_error': e.type.toString()},
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred',
        data: null,
        error: {'error': e.toString()},
      );
    }
  }

  @override
  Future<ApiResponse<List<JobDetailsDTO>>> fetchBookmarkedJobs({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.get(
        V2ApiConstants.fetchBookmarkedJobs,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data as List<dynamic>,
        );

        if (apiResponse.success && apiResponse.data != null) {
          final jobs = (apiResponse.data as List<dynamic>)
              .map((json) => JobDetailsDTO.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<JobDetailsDTO>>(
            success: true,
            message: apiResponse.message,
            data: jobs,
          );
        } else {
          return ApiResponse<List<JobDetailsDTO>>(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        return ApiResponse<List<JobDetailsDTO>>(
          success: false,
          message: 'Failed to fetch bookmarked jobs',
          data: null,
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<JobDetailsDTO>>(
        success: false,
        message: e.message ?? 'Network error occurred',
        data: null,
        error: {'dio_error': e.type.toString()},
      );
    } catch (e) {
      return ApiResponse<List<JobDetailsDTO>>(
        success: false,
        message: 'An unexpected error occurred',
        data: null,
        error: {'error': e.toString()},
      );
    }
  }
}
