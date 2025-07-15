import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String _loginUrl = 'https://api.joinmeds.in/api/user/login';

  // Function to log in user and get userId
  static Future<String?> loginAndGetId({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle cases where userId is nested or at root level
        if (data['id'] != null) return data['id'].toString();
        if (data['data'] != null && data['data']['id'] != null) {
          return data['data']['id'].toString();
        }
        print('UserId not found in response');
        return null;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
