import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/job/job_applied_dto.dart';
import '../../../../models/v2/job/job_details_dto.dart';
import '../../../../models/v2/job/job_search_params.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_job_repo.dart';

/// Job repository implementation
class JobRepo implements IJobRepo {
  final ApiClient _apiClient;

  JobRepo(this._apiClient);

  @override
  Future<ApiResponse<JobDetailsDTO>> createJob(
    int userId,
    JobDetailsDTO job, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<JobDetailsDTO>(
      V2ApiConstants.saveJob(userId),
      data: job.toJson(),
      fromJson: (json) => JobDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<JobDetailsDTO>> updateJob(
    String jobId,
    JobDetailsDTO job, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.putTyped<JobDetailsDTO>(
      V2ApiConstants.updateJob(jobId),
      data: job.toJson(),
      fromJson: (json) => JobDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<List<JobDetailsDTO>>> fetchAllJobs({
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getList<JobDetailsDTO>(
      V2ApiConstants.fetchAllJobs,
      fromJson: (json) => JobDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<void>> deleteJob(
    String jobId, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.deleteVoid(
      V2ApiConstants.deleteJob(jobId),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<JobAppliedDTO>> applyToJob(
    JobAppliedDTO application, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<JobAppliedDTO>(
      V2ApiConstants.applyToJob,
      data: application.toJson(),
      fromJson: (json) => JobAppliedDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<List<JobAppliedDTO>>> fetchUserApplications(
    String userId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.get(
        V2ApiConstants.fetchUserApplications(userId),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Handle direct array response (not wrapped in ApiResponse)
        if (response.data is List) {
          final applications = (response.data as List<dynamic>)
              .map((json) => JobAppliedDTO.fromJson(json as Map<String, dynamic>))
              .toList();

          return ApiResponse<List<JobAppliedDTO>>(
            success: true,
            message: 'Applications fetched successfully',
            data: applications,
          );
        }

        // Handle wrapped response
        return await _apiClient.getList<JobAppliedDTO>(
          V2ApiConstants.fetchUserApplications(userId),
          fromJson: (json) => JobAppliedDTO.fromJson(json),
          cancelToken: cancelToken,
        );
      } else {
        return ApiResponse<List<JobAppliedDTO>>(
          success: false,
          message: 'Failed to fetch applications',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<List<JobAppliedDTO>>(
        success: false,
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  @override
  Future<ApiResponse<List<JobAppliedDTO>>> searchApplications(
    JobSearchParams params, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getList<JobAppliedDTO>(
      V2ApiConstants.searchApplications,
      queryParameters: params.toQueryParameters(),
      fromJson: (json) => JobAppliedDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
