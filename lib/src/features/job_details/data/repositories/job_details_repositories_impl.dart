import 'package:dio/dio.dart';
import '../../../../shared/models/v2/common/api_response.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../shared/services/api/api_client.dart';
import '../../../../core/constants/v2_api_constants.dart';
import '../../domain/repository/jon_details_repository.dart';

/// Implementation of IJobDetailsRepository
class JobDetailsRepositoryImpl implements IJobDetailsRepository {
  final ApiClient _apiClient;

  JobDetailsRepositoryImpl(this._apiClient);

  @override
  Future<ApiResponse<JobDetailsDTO>> fetchJobDetails(
      String jobId, {
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _apiClient.get(
        V2ApiConstants.fetchJobDetails(jobId),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {

        /// ✅ CASE 1: API returns LIST with single item (YOUR ACTUAL API)
        if (response.data is List) {
          final list = response.data as List<dynamic>;

          if (list.isEmpty) {
            return ApiResponse<JobDetailsDTO>(
              success: false,
              message: 'Job not found',
              data: null,
            );
          }

          final job = JobDetailsDTO.fromJson(
            list.first as Map<String, dynamic>,
          );

          return ApiResponse<JobDetailsDTO>(
            success: true,
            message: 'Job details fetched successfully',
            data: job,
          );
        }

        /// ✅ CASE 2: API returns direct object
        if (response.data is Map<String, dynamic>) {
          final job = JobDetailsDTO.fromJson(
            response.data as Map<String, dynamic>,
          );

          return ApiResponse<JobDetailsDTO>(
            success: true,
            message: 'Job details fetched successfully',
            data: job,
          );
        }

        /// ✅ CASE 3: API returns wrapped ApiResponse
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data as Map<String, dynamic>,
              (data) => data as List<dynamic>,
        );

        if (apiResponse.success &&
            apiResponse.data != null &&
            apiResponse.data!.isNotEmpty) {
          final job = JobDetailsDTO.fromJson(
            apiResponse.data!.first as Map<String, dynamic>,
          );

          return ApiResponse<JobDetailsDTO>(
            success: true,
            message: apiResponse.message,
            data: job,
          );
        }

        return ApiResponse<JobDetailsDTO>(
          success: false,
          message: apiResponse.message,
          data: null,
        );
      }

      return ApiResponse<JobDetailsDTO>(
        success: false,
        message: 'Failed to fetch job details',
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse<JobDetailsDTO>(
        success: false,
        message: e.message ?? 'Network error occurred',
        data: null,
        error: {
          'dio_error': e.type.toString(),
          'status_code': e.response?.statusCode,
        },
      );
    } catch (e) {
      return ApiResponse<JobDetailsDTO>(
        success: false,
        message: 'An unexpected error occurred',
        data: null,
        error: {'error': e.toString()},
      );
    }
  }


  @override
  Future<ApiResponse<void>> applyForJob(
      String jobId, {
        required String userId,
        required String orgId,
        required String applicantName,
        required String resumeId,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _apiClient.post(
        V2ApiConstants.applyToJob,
        data: {
          'userId': userId,
          'orgId': orgId,
          'jobId': jobId,
          'applicantName': applicantName,
          'resumeId': resumeId,
          'status': 'active',
        },
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<void>(
          success: true,
          message: 'Job applied successfully',
          data: null,
        );
      }

      return ApiResponse<void>(
        success: false,
        message: 'Failed to apply for the job',
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.response?.data?['message'] ??
            e.message ??
            'Network error occurred',
        data: null,
        error: {
          'dio_error': e.type.toString(),
          'status_code': e.response?.statusCode,
        },
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

}
