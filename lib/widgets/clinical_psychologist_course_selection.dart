import 'package:flutter/material.dart';
import '../constants/constant.dart';

class ClinicalPsychologyCourseTypeSelection extends StatefulWidget {
  const ClinicalPsychologyCourseTypeSelection({super.key});

  @override
  State<ClinicalPsychologyCourseTypeSelection> createState() =>
      _ClinicalPsychologyCourseTypeSelectionState();
}

class _ClinicalPsychologyCourseTypeSelectionState
    extends State<ClinicalPsychologyCourseTypeSelection> {
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
      case 'BSc Psychology':
        Navigator.pushNamed(context, '/bsc_psychology_academic_status');
        break;
      case 'Diploma in Psychology':
        Navigator.pushNamed(context, '/diploma_psychology_academic_status');
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
        title: const Text("Clinical Psychologist", style: appBarText),
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
              ...['BSc Psychology', 'Diploma in Psychology'].map(
                    (course) => RadioListTile<String>(
                  value: course,
                  groupValue: courseType,
                  onChanged: (value) => setState(() => courseType = value),
                  title: Text(course, style: radioTextStyle),
                  activeColor: mainBlue,
                ),
              ),
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
