import 'package:dio/dio.dart';
import '../../../../models/v2/auth/auth_response.dart';
import '../../../../models/v2/auth/login_request.dart';
import '../../../../models/v2/auth/reset_password_request.dart';
import '../../../../models/v2/auth/signup_request.dart';
import '../../../../models/v2/common/api_response.dart';

/// Authentication repository interface
abstract class IAuthRepo {
  /// Register new user
  Future<ApiResponse<AuthResponse>> signup(
    SignupRequest request, {
    CancelToken? cancelToken,
  });

  /// User login
  Future<ApiResponse<AuthResponse>> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  });

  /// Reset password
  Future<ApiResponse<void>> resetPassword(
    ResetPasswordRequest request, {
    CancelToken? cancelToken,
  });

  /// Update user details
  Future<ApiResponse<AuthResponse>> updateUser(
    int id,
    SignupRequest request, {
    CancelToken? cancelToken,
  });

  /// Fetch user details by ID
  Future<ApiResponse<AuthResponse>> fetchUser(
    int id, {
    CancelToken? cancelToken,
  });
}
