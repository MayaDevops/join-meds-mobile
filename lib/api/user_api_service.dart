import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/signup_request.dart';

class UserApiService {
  final String _baseUrl = 'http://joinmeds.in:8082/api';

  Future<http.Response> signup(SignupRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/user/signup'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
      body: jsonEncode(request.toJson()),
    );
    return response;
  }
}
