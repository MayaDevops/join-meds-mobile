import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organisation_signup_model.dart';

class OrganisationApi {
  static const String baseUrl = 'https://api.joinmeds.in/api';

  static Future<http.Response> signupOrganisation(OrganisationSignup data) async {
    final url = Uri.parse('$baseUrl/user/signup');

    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data.toJson()),
    );

    return response;
  }
}
