import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup_request.dart';

class UserApiService {
  // final String _baseUrl = 'https://api.joinmeds.in/api';

  Future<http.Response> signup(SignupRequest request) async {
    //   final response = await http.post(
    //     Uri.parse('$_baseUrl/user/signup'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       'Accept': '*/*',
    //     },
    //     body: jsonEncode(request.toJson()),
    //   );
    //   return response;
    // }

    final response = await http.post(
      Uri.parse('https://api.joinmeds.in/api/user/signup'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode(request.toJson()),
    );
    return response;
  }
  Future<http.Response> sendOtp({
    required String mobile,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.joinmeds.in/api/sms/send'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode({
        "mobile": mobile,
      }),
    );

    return response;
  }

  Future<http.Response> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.joinmeds.in/api/sms/verify'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode({
        "mobile": mobile,
        "otp": otp,
      }),
    );

    return response;
  }
}
