import 'package:dio/dio.dart';
import '../../../../models/v2/job/job_applied_dto.dart';
import '../../../../models/v2/job/job_details_dto.dart';
import '../../../../models/v2/job/job_search_params.dart';
import '../../../../models/v2/common/api_response.dart';

/// Job repository interface
abstract class IJobRepo {
  /// Create a new job posting
  Future<ApiResponse<JobDetailsDTO>> createJob(
    int userId,
    JobDetailsDTO job, {
    CancelToken? cancelToken,
  });

  /// Update job posting
  Future<ApiResponse<JobDetailsDTO>> updateJob(
    String jobId,
    JobDetailsDTO job, {
    CancelToken? cancelToken,
  });

  /// Fetch all jobs
  Future<ApiResponse<List<JobDetailsDTO>>> fetchAllJobs({
    CancelToken? cancelToken,
  });

  /// Delete job posting
  Future<ApiResponse<void>> deleteJob(
    String jobId, {
    CancelToken? cancelToken,
  });

  // Job Applications

  /// Apply to a job
  Future<ApiResponse<JobAppliedDTO>> applyToJob(
    JobAppliedDTO application, {
    CancelToken? cancelToken,
  });

  /// Fetch user's job applications
  Future<ApiResponse<List<JobAppliedDTO>>> fetchUserApplications(
    String userId, {
    CancelToken? cancelToken,
  });

  /// Search job applications with filters
  Future<ApiResponse<List<JobAppliedDTO>>> searchApplications(
    JobSearchParams params, {
    CancelToken? cancelToken,
  });
}
