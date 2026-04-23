import 'package:dio/dio.dart';
import '../../../../shared/models/v2/common/api_response.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';

/// Repository interface for home screen data operations
abstract class IHomeRepository {
  /// Fetch recommended jobs for the user
  ///
  /// [limit] - Maximum number of jobs to fetch (optional)
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] containing list of [JobDetailsDTO]
  Future<ApiResponse<List<JobDetailsDTO>>> fetchRecommendedJobs({
    int? limit,
    CancelToken? cancelToken,
  });

  /// Bookmark a job for later viewing
  ///
  /// [jobId] - ID of the job to bookmark (UUID format)
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] with success status
  Future<ApiResponse<void>> bookmarkJob(
    String jobId, {
    CancelToken? cancelToken,
  });

  /// Remove a job from bookmarks
  ///
  /// [jobId] - ID of the job to remove from bookmarks (UUID format)
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] with success status
  Future<ApiResponse<void>> removeBookmark(
    String jobId, {
    CancelToken? cancelToken,
  });

  /// Fetch all bookmarked jobs for the user
  ///
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] containing list of [JobDetailsDTO]
  Future<ApiResponse<List<JobDetailsDTO>>> fetchBookmarkedJobs({
    CancelToken? cancelToken,
  });


  /// Fetch jobs based on search keyword
  ///
  /// [keyword] - Search keyword entered by the user
  /// [cancelToken] - Token to cancel the request (optional)
  ///
  /// Returns [ApiResponse] containing list of [JobDetailsDTO]
  Future<ApiResponse<List<JobDetailsDTO>>> fetchJobsByKeyword(
      String keyword, {
        CancelToken? cancelToken,
      });
}
