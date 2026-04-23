import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/auth/auth_response.dart';
import '../../../../models/v2/auth/login_request.dart';
import '../../../../models/v2/auth/reset_password_request.dart';
import '../../../../models/v2/auth/signup_request.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_auth_repo.dart';

/// Authentication repository implementation
class AuthRepo implements IAuthRepo {
  final ApiClient _apiClient;

  AuthRepo(this._apiClient);

  @override
  Future<ApiResponse<AuthResponse>> signup(
    SignupRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<AuthResponse>(
      V2ApiConstants.signup,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<AuthResponse>> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<AuthResponse>(
      V2ApiConstants.login,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<void>> resetPassword(
    ResetPasswordRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postVoid(
      V2ApiConstants.resetPassword,
      data: request.toJson(),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<AuthResponse>> updateUser(
    int id,
    SignupRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.putTyped<AuthResponse>(
      V2ApiConstants.signupUpdate(id),
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<AuthResponse>> fetchUser(
    int id, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.getTyped<AuthResponse>(
      V2ApiConstants.userFetch(id),
      fromJson: (json) => AuthResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
