import 'package:dio/dio.dart';
import '../../../../models/v2/user/citizen_profile_dto.dart';
import '../../../../models/v2/user/user_details_dto.dart';
import '../../../../models/v2/user/work_experience_dto.dart';
import '../../../../models/v2/common/api_response.dart';

/// User repository interface
abstract class IUserRepo {
  /// Save user details
  Future<ApiResponse<UserDetailsDTO>> saveUserDetails(
    UserDetailsDTO details, {
    CancelToken? cancelToken,
  });

  /// Update user details
  Future<ApiResponse<UserDetailsDTO>> updateUserDetails(
    int userId,
    UserDetailsDTO details, {
    CancelToken? cancelToken,
  });

  /// Fetch user details by user ID
  Future<ApiResponse<UserDetailsDTO>> fetchUserDetails(
    int userId, {
    CancelToken? cancelToken,
  });

  /// Fetch citizen profile
  Future<ApiResponse<CitizenProfileDTO>> fetchCitizenProfile(
    int userId, {
    CancelToken? cancelToken,
  });

  /// Save work experience
  Future<ApiResponse<WorkExperienceDTO>> saveWorkExperience(
    WorkExperienceDTO experience, {
    CancelToken? cancelToken,
  });

  /// Update work experience
  Future<ApiResponse<WorkExperienceDTO>> updateWorkExperience(
    int id,
    WorkExperienceDTO experience, {
    CancelToken? cancelToken,
  });

  /// Fetch work experience for a user
  Future<ApiResponse<List<WorkExperienceDTO>>> fetchWorkExperience(
    int userId, {
    CancelToken? cancelToken,
  });
}
