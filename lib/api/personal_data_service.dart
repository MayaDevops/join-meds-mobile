import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_data_model.dart';

class PersonalDataService {
  static Future<PersonalDataModel?> getPersonalData(String userId) async {
    debugPrint('PersonalDataService: Attempting to fetch personal data for userId: $userId');

    final url = Uri.parse(
        'https://api.joinmeds.in/api/user-details/$userId?userId=$userId');

    debugPrint('PersonalDataService: Request URL: $url');

    final response = await http.get(url, headers: {
      'accept': '*/*',
    });

    debugPrint('PersonalDataService: Response status: ${response.statusCode}');
    debugPrint('PersonalDataService: Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        debugPrint('PersonalDataService: Decoded JSON: $jsonData');

        // ✅ Parse the full object directly, not jsonData['data']
        final result = PersonalDataModel.fromJson(jsonData);
        debugPrint('PersonalDataService: Parsed result - fullname: ${result.fullname}');

        // ✅ Save user profile to storage in UserProvider format
        final prefs = await SharedPreferences.getInstance();
        final userProfile = {
          'fullName': result.fullname,
          'email': result.email,
          'phone': result.emailOrPhone,
          'profession': result.profession,
          'profileImageUrl': result.photoId,
          'resumeUrl': result.resumeId,
        };
        await prefs.setString('user_profile', jsonEncode(userProfile));
        debugPrint('PersonalDataService: Saved user profile from getPersonalData: $userProfile');

        return result;
      } catch (e) {
        debugPrint('PersonalDataService: Error parsing JSON response: $e');
        debugPrint('PersonalDataService: Raw response body: ${response.body}');
        return null;
      }
    } else {
      debugPrint('PersonalDataService: Failed to load user data: ${response.statusCode}');
      debugPrint('PersonalDataService: Error response body: ${response.body}');
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

      // ✅ Save full profile data in the format UserProvider expects
      final userProfile = {
        'fullName': data.fullname,
        'email': data.email,
        'phone': data.emailOrPhone,
        'profession': data.profession,
        'profileImageUrl': json['photoId'],
        'resumeUrl': json['resumeId'],
      };

      await prefs.setString('user_profile', jsonEncode(userProfile));
      debugPrint("Saved full user profile to storage: $userProfile");

      return true;
    }

    return false;
  }
}