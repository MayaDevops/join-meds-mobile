import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/user/citizen_profile_dto.dart';
import '../../../../models/v2/user/user_details_dto.dart';
import '../../../../models/v2/user/work_experience_dto.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_user_repo.dart';

/// User repository implementation
class UserRepo implements IUserRepo {
  final ApiClient _apiClient;

  UserRepo(this._apiClient);

  @override
  Future<ApiResponse<UserDetailsDTO>> saveUserDetails(
    UserDetailsDTO details, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<UserDetailsDTO>(
      V2ApiConstants.saveUserDetails,
      data: details.toJson(),
      fromJson: (json) => UserDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<UserDetailsDTO>> updateUserDetails(
    int userId,
    UserDetailsDTO details, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.putTyped<UserDetailsDTO>(
      V2ApiConstants.updateUserDetails(userId),
      data: details.toJson(),
      fromJson: (json) => UserDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<UserDetailsDTO>> fetchUserDetails(
    int userId, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getTyped<UserDetailsDTO>(
      V2ApiConstants.fetchUserDetails(userId),
      fromJson: (json) => UserDetailsDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<CitizenProfileDTO>> fetchCitizenProfile(
    int userId, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getTyped<CitizenProfileDTO>(
      V2ApiConstants.fetchCitizenProfile(userId),
      fromJson: (json) => CitizenProfileDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<WorkExperienceDTO>> saveWorkExperience(
    WorkExperienceDTO experience, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<WorkExperienceDTO>(
      V2ApiConstants.saveWorkExperience,
      data: experience.toJson(),
      fromJson: (json) => WorkExperienceDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<WorkExperienceDTO>> updateWorkExperience(
    int id,
    WorkExperienceDTO experience, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.putTyped<WorkExperienceDTO>(
      V2ApiConstants.updateWorkExperience(id),
      data: experience.toJson(),
      fromJson: (json) => WorkExperienceDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<List<WorkExperienceDTO>>> fetchWorkExperience(
    int userId, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getList<WorkExperienceDTO>(
      V2ApiConstants.fetchWorkExperience(userId),
      fromJson: (json) => WorkExperienceDTO.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
