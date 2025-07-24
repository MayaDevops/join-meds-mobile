import 'package:flutter/material.dart';
import '../constants/constant.dart';

class PhysiotherapyCourseTypeSelection extends StatefulWidget {
  const PhysiotherapyCourseTypeSelection({super.key});

  @override
  State<PhysiotherapyCourseTypeSelection> createState() => _PhysiotherapyCourseTypeSelectionState();
}

class _PhysiotherapyCourseTypeSelectionState extends State<PhysiotherapyCourseTypeSelection> {
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
    if (nurseCourseType == 'BPT') {
      Navigator.pushNamed(context, '/bpt_academic_status');
    } else if (nurseCourseType == 'DPT') {
      Navigator.pushNamed(context, '/dpt_academic_status');
    } else {
      _showSnackBar("Please select a course", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Physiotherapy", style: appBarText),
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
              ...['BPT', 'DPT'].map((course) {
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
