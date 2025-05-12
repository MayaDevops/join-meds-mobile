import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personal_data_model.dart';

class PersonalDataService {
  static const String _baseUrl = 'http://joinmeds.in:8082/api/user-details/update/{id}';

  static Future<bool> savePersonalData(PersonalDataModel data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '/',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to save data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error saving personal data: $e');
      return false;
    }
  }
}