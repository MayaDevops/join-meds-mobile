import 'package:dio/dio.dart';
import '../../../../shared/models/v2/common/api_response.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';

/// Repository interface for job details screen data operations
abstract class IJobDetailsRepository {
  /// Fetch full details of a specific job
  ///
  /// [jobId] - ID of the job to fetch details (UUID format)
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] containing [JobDetailsDTO]
  Future<ApiResponse<JobDetailsDTO>> fetchJobDetails(
      String jobId, {
        CancelToken? cancelToken,
      });
}
