import 'package:flutter/material.dart';
import '../constants/constant.dart';

class PharmacistCourseTypeSelection extends StatefulWidget {
  const PharmacistCourseTypeSelection({super.key});

  @override
  State<PharmacistCourseTypeSelection> createState() => _PharmacistCourseTypeSelectionState();
}

class _PharmacistCourseTypeSelectionState extends State<PharmacistCourseTypeSelection> {
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
    switch (nurseCourseType) {
      case 'B-Pharm':
        Navigator.pushNamed(context, '/pharmacist_academic_status_page');
        break;
      case 'Pharm-D':
        Navigator.pushNamed(context, '/pharm_d_academic_status');
        break;
      case 'D-Pharm':
        Navigator.pushNamed(context, '/d_pharmd_diploma_academic_status');
        break;
      default:
        _showSnackBar("Please select a course", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacist", style: appBarText),
        backgroundColor: mainBlue,
        centerTitle: true,
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
              ...['B-Pharm', 'Pharm-D', 'D-Pharm'].map((course) {
                return RadioListTile<String>(
                  value: course,
                  groupValue: nurseCourseType,
                  title: Text(course, style: radioTextStyle),
                  activeColor: mainBlue,
                  onChanged: (value) => setState(() => nurseCourseType = value),
                );
              }).toList(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _navigateBasedOnCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
