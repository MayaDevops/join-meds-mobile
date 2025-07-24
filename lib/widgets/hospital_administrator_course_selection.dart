import 'package:flutter/material.dart';
import '../constants/constant.dart';

class HospitalAdministratorCourseTypeSelection extends StatefulWidget {
  const HospitalAdministratorCourseTypeSelection({super.key});

  @override
  State<HospitalAdministratorCourseTypeSelection> createState() =>
      _HospitalAdministratorCourseTypeSelectionState();
}

class _HospitalAdministratorCourseTypeSelectionState
    extends State<HospitalAdministratorCourseTypeSelection> {
  String? courseType;

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
    switch (courseType) {
      case 'BHA':
        Navigator.pushNamed(context, '/bha_academic_status');
        break;
      case 'DHA':
        Navigator.pushNamed(
            context, '/diploma_hospital_administrator_academic_status');
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
        title: const Text("Hospital Administrator", style: appBarText),
        backgroundColor: mainBlue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
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
              ...['BHA', 'DHA'].map(
                    (course) => RadioListTile<String>(
                  value: course,
                  groupValue: courseType,
                  title: Text(course, style: radioTextStyle),
                  activeColor: mainBlue,
                  onChanged: (value) =>
                      setState(() => courseType = value),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _navigateBasedOnCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: mainBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
