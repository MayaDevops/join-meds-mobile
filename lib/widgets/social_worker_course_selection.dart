import 'package:flutter/material.dart';
import '../constants/constant.dart';

class SocialWorkerCourseTypeSelection extends StatefulWidget {
  const SocialWorkerCourseTypeSelection({super.key});

  @override
  State<SocialWorkerCourseTypeSelection> createState() => _SocialWorkerCourseTypeSelectionState();
}

class _SocialWorkerCourseTypeSelectionState extends State<SocialWorkerCourseTypeSelection> {
  String? nurseCourseType;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateBasedOnCourse() {
    if (nurseCourseType == 'BSW') {
      Navigator.pushNamed(context, '/bsw_academic_status');
    } else if (nurseCourseType == 'Diploma in Social Work') {
      Navigator.pushNamed(context, '/diploma_social_worker_academic_status');
    } else {
      _showSnackBar("Please select a course", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Worker", style: appBarText),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            padding: EdgeInsets.only(bottom: bottomPadding + 20),
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.only(bottom: 15),
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

              ...['BSW', 'Diploma in Social Work'].map((course) {
                return RadioListTile<String>(
                  value: course,
                  groupValue: nurseCourseType,
                  title: Text(course, style: radioTextStyle),
                  activeColor: mainBlue,
                  onChanged: (value) => setState(() => nurseCourseType = value),
                );
              }).toList(),

              const SizedBox(height: 40),
              SafeArea(
                minimum: const EdgeInsets.only(left: 40,right: 40,bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateBasedOnCourse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
