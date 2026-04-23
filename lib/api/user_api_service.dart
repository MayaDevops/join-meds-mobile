import 'dart:convert';
import 'package:flutter/material.dart';
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
debugPrint(response.body.toString());
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


  Future<http.Response> resetPassword({
    required String mobile,
    required String confirmPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.joinmeds.in/api/user/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
      },
      body: jsonEncode({
        "mobileNumber": mobile,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      }),
    );

    return response;
  }

}
