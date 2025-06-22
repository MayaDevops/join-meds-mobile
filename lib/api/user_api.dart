import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserApi {
  static const String _baseUrl = 'http://joinmeds.in:8082/api/user/user-fetch';

  static Future<UserModel?> fetchUser(String userId) async {
    final url = Uri.parse('$_baseUrl/$userId');

    try {
      final response = await http.get(url, headers: {
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }
}
