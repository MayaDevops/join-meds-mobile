import 'package:dio/dio.dart';
import '../../../../../core/constants/v2_api_constants.dart';
import '../../../../models/v2/otp/otp_response.dart';
import '../../../../models/v2/otp/send_otp_request.dart';
import '../../../../models/v2/otp/verify_otp_request.dart';
import '../../../../models/v2/common/api_response.dart';
import '../../../api/api_client.dart';
import '../interfaces/i_otp_repo.dart';

/// OTP repository implementation
class OtpRepo implements IOtpRepo {
  final ApiClient _apiClient;

  OtpRepo(this._apiClient);

  @override
  Future<ApiResponse<OtpResponse>> sendOtp(
    SendOtpRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<OtpResponse>(
      V2ApiConstants.sendOtp,
      data: request.toJson(),
      fromJson: (json) => OtpResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<OtpResponse>> verifyOtp(
    VerifyOtpRequest request, {
    CancelToken? cancelToken,
  }) async {
    return await _apiClient.postTyped<OtpResponse>(
      V2ApiConstants.verifyOtp,
      data: request.toJson(),
      fromJson: (json) => OtpResponse.fromJson(json),
      cancelToken: cancelToken,
    );
  }
}
