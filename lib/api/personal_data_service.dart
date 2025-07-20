import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_data_model.dart';

class PersonalDataService {
  static Future<PersonalDataModel?> getPersonalData(String userId) async {
    final url = Uri.parse(
        'https://api.joinmeds.in/api/user-details/$userId?userId=$userId');

    final response = await http.get(url, headers: {
      'accept': '*/*',
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // ✅ Parse the full object directly, not jsonData['data']
      return PersonalDataModel.fromJson(jsonData);
    } else {
      debugPrint('Failed to load user data: ${response.statusCode}');
      return null;
    }
  }


  static Future<bool> updatePersonalData(String userId,
      PersonalDataModel data) async {
    final url = Uri.parse(
        'https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    debugPrint('PUT status: ${response.statusCode}');
    debugPrint('PUT response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);

      // ✅ Save photoId & resumeId to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (json['photoId'] != null) {
        prefs.setString('photoId', json['photoId']);
        debugPrint("Saved photoId: ${json['photoId']}");
      }
      if (json['resumeId'] != null) {
        prefs.setString('resumeId', json['resumeId']);
        debugPrint("Saved resumeId: ${json['resumeId']}");
      }

      return true;
    }

    return false;
  }
}