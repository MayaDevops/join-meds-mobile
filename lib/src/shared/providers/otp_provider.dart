import 'package:flutter/foundation.dart';
import '../models/v2/otp/send_otp_request.dart';
import '../models/v2/otp/verify_otp_request.dart';
import '../models/v2/otp/otp_response.dart';
import '../models/v2/common/api_response.dart';
import '../services/v2/repository_provider.dart';
import '../services/v2/repositories/interfaces/i_otp_repo.dart';

enum OtpStatus {
  initial,
  sending,
  sent,
  verifying,
  verified,
  error,
}

class OtpProvider extends ChangeNotifier {
  final IOtpRepo _otpRepo;

  OtpStatus _status = OtpStatus.initial;
  String? _error;
  String? _phoneNumber;
  OtpResponse? _otpResponse;

  OtpProvider({IOtpRepo? otpRepo})
      : _otpRepo = otpRepo ?? RepositoryProvider.instance.otpRepo;

  // Getters
  OtpStatus get status => _status;
  String? get error => _error;
  String? get phoneNumber => _phoneNumber;
  OtpResponse? get otpResponse => _otpResponse;

  bool get isSending => _status == OtpStatus.sending;
  bool get isSent => _status == OtpStatus.sent;
  bool get isVerifying => _status == OtpStatus.verifying;
  bool get isVerified => _status == OtpStatus.verified;
  bool get hasError => _status == OtpStatus.error;

  /// Send OTP to phone number
  Future<ApiResponse<OtpResponse>> sendOtp(String phoneNumber) async {
    _status = OtpStatus.sending;
    _error = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      final response = await _otpRepo.sendOtp(
        SendOtpRequest(phone: phoneNumber),
      );

      if (response.success) {
        _status = OtpStatus.sent;
        _otpResponse = response.data;
      } else {
        _status = OtpStatus.error;
        _error = response.message;
      }

      notifyListeners();
      return response;
    } catch (e) {
      _status = OtpStatus.error;
      _error = e.toString();
      notifyListeners();

      return ApiResponse<OtpResponse>(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  /// Verify OTP code
  Future<ApiResponse<OtpResponse>> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      _status = OtpStatus.error;
      _error = 'Phone number not set. Please send OTP first.';
      notifyListeners();

      return ApiResponse<OtpResponse>(
        success: false,
        message: _error!,
        data: null,
      );
    }

    _status = OtpStatus.verifying;
    _error = null;
    notifyListeners();

    try {
      final response = await _otpRepo.verifyOtp(
        VerifyOtpRequest(
          phone: _phoneNumber!,
          otp: otp,
        ),
      );

      if (response.success) {
        _status = OtpStatus.verified;
        _otpResponse = response.data;
      } else {
        _status = OtpStatus.error;
        _error = response.message;
      }

      notifyListeners();
      return response;
    } catch (e) {
      _status = OtpStatus.error;
      _error = e.toString();
      notifyListeners();

      return ApiResponse<OtpResponse>(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  /// Resend OTP to the same phone number
  Future<ApiResponse<OtpResponse>> resendOtp() async {
    if (_phoneNumber == null) {
      _status = OtpStatus.error;
      _error = 'Phone number not set. Please send OTP first.';
      notifyListeners();

      return ApiResponse<OtpResponse>(
        success: false,
        message: _error!,
        data: null,
      );
    }

    return sendOtp(_phoneNumber!);
  }

  /// Reset provider state
  void reset() {
    _status = OtpStatus.initial;
    _error = null;
    _phoneNumber = null;
    _otpResponse = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    if (_status == OtpStatus.error) {
      _status = OtpStatus.initial;
    }
    notifyListeners();
  }
}
