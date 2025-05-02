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
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _navigateBasedOnCourse() {
    switch (nurseCourseType) {
      case 'BPT':
        Navigator.pushNamed(context, '/bpt_academic_status');
        break;
      case 'DPT':
        Navigator.pushNamed(context, '/dpt_academic_status');
        break;
      default:
        _showSnackBar("Please select a course", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ...['BPT', 'DPT']
            .map((course) => RadioListTile<String>(
          value: course,
          groupValue: nurseCourseType,
          onChanged: (value) => setState(() => nurseCourseType = value),
          title: Text(course, style: radioTextStyle),
        ))
            .toList(),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _navigateBasedOnCourse,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: mainBlue,
            shape:
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: const Text('Save',
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ],
    );
  }
}
