import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personal_data_model.dart';

class PersonalDataService {
  static const String _baseUrl = 'https://api.joinmeds.in/api/user-details';

  /// Save new personal data (POST)
  static Future<bool> savePersonalData(PersonalDataModel data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/save'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
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

  /// Update existing personal data (PUT)
  static Future<bool> updatePersonalData(String userId, PersonalDataModel data) async {
    try {
      final uri = Uri.parse('$_baseUrl/update/$userId?userId=$userId');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        print('Data updated successfully');
        return true;
      } else {
        print('Failed to update data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating personal data: $e');
      return false;
    }
  }
}
