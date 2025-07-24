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
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse", style: appBarText),
        backgroundColor: mainBlue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            padding: EdgeInsets.only(bottom: bottomInset + bottomPadding + 20),
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: inputBorderClr, width: 1.5),
                  ),
                ),
                child: const Text(
                  'Select Your Academic Qualification',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              ...courseOptions.map(
                    (course) => RadioListTile<String>(
                  value: course,
                  groupValue: nurseCourseType,
                  title: Text(course, style: radioTextStyle),
                  activeColor: mainBlue,
                  onChanged: (value) => setState(() => nurseCourseType = value),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveAcademicQualification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: mainBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
