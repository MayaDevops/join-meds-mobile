import 'package:flutter/material.dart';
import '../constants/constant.dart';

class AnaesthesiaTechnicianCourseTypeSelection extends StatefulWidget {
  const AnaesthesiaTechnicianCourseTypeSelection({super.key});

  @override
  State<AnaesthesiaTechnicianCourseTypeSelection> createState() =>
      _AnaesthesiaTechnicianCourseTypeSelectionState();
}

class _AnaesthesiaTechnicianCourseTypeSelectionState
    extends State<AnaesthesiaTechnicianCourseTypeSelection> {
  String? selectedCourse;

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
    switch (selectedCourse) {
      case 'BSc AT':
        Navigator.pushNamed(context, '/bsc_at_academic_status');
        break;
      case 'DAT':
        Navigator.pushNamed(context, '/dat_academic_status');
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
        title: const Text("Anaesthesia Technician", style: appBarText),
        centerTitle: true,
        backgroundColor: mainBlue,
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
              ...['BSc AT', 'DAT'].map(
                    (course) => RadioListTile<String>(
                  value: course,
                  groupValue: selectedCourse,
                  onChanged: (value) => setState(() => selectedCourse = value),
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
