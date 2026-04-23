import 'package:dio/dio.dart';
import '../../../../models/v2/otp/otp_response.dart';
import '../../../../models/v2/otp/send_otp_request.dart';
import '../../../../models/v2/otp/verify_otp_request.dart';
import '../../../../models/v2/common/api_response.dart';

/// OTP repository interface
abstract class IOtpRepo {
  /// Send OTP to phone number
  Future<ApiResponse<OtpResponse>> sendOtp(
    SendOtpRequest request, {
    CancelToken? cancelToken,
  });

  /// Verify OTP code
  Future<ApiResponse<OtpResponse>> verifyOtp(
    VerifyOtpRequest request, {
    CancelToken? cancelToken,
  });
}
