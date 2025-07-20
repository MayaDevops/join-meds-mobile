import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constant.dart';

class NurseCourseTypeSelection extends StatefulWidget {
  const NurseCourseTypeSelection({super.key});

  @override
  State<NurseCourseTypeSelection> createState() => _NurseCourseTypeSelectionState();
}

class _NurseCourseTypeSelectionState extends State<NurseCourseTypeSelection> {
  String? nurseCourseType;
  String? userId;
  bool isLoading = true;

  final List<String> courseOptions = [
    'BSc Nursing',
    'General Nursing',
    'Auxiliary Nursing and Midwifery (ANM)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchQualification();
  }

  Future<void> _loadUserDataAndFetchQualification() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse("https://api.joinmeds.in/api/user-details/fetch/$userId");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            nurseCourseType = data['academicQualification'];
            isLoading = false;
          });
        } else {
          _showSnackBar("Failed to fetch data", Colors.red);
          setState(() => isLoading = false);
        }
      } catch (e) {
        _showSnackBar("Error: $e", Colors.red);
        setState(() => isLoading = false);
      }
    } else {
      _showSnackBar("User ID not found", Colors.red);
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _saveAcademicQualification() async {
    if (nurseCourseType == null) {
      _showSnackBar("Please select a course", Colors.red);
      return;
    }

    final url = Uri.parse("https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId");

    final body = jsonEncode({
      "academicQualification": nurseCourseType,
      "userId": userId,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _navigateBasedOnCourse();
      } else {
        _showSnackBar("Error: ${response.body}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Exception: $e", Colors.red);
    }
  }

  void _navigateBasedOnCourse() {
    switch (nurseCourseType) {
      case 'BSc Nursing':
        Navigator.pushNamed(context, '/nurse_academic_status');
        break;
      case 'General Nursing':
        Navigator.pushNamed(context, '/gn_nurse_academic_status');
        break;
      case 'Auxiliary Nursing and Midwifery (ANM)':
        Navigator.pushNamed(context, '/anm_nurse_diploma_status');
        break;
      default:
        _showSnackBar("Please select a course", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: inputBorderClr, width: 1.5),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          child: const Text(
            'Select Your Academic Qualification',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        ...courseOptions.map(
              (course) => RadioListTile<String>(
            value: course,
            groupValue: nurseCourseType,
            onChanged: (value) => setState(() => nurseCourseType = value),
            title: Text(course, style: radioTextStyle),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _saveAcademicQualification,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: mainBlue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: const Text('Save',
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ],
    );
  }
}
