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
}
