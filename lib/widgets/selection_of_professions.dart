import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/constant.dart';
import 'anaesthesia_techician_course_type.dart';
import 'package:untitled/widgets/audiology_course_selection.dart';
import 'package:untitled/widgets/clinical_psychologist_course_selection.dart';
import 'package:untitled/widgets/dietitian_course_selection.dart';
import 'package:untitled/widgets/hospital_administrator_course_selection.dart';
import 'package:untitled/widgets/lab_technician_type_selection.dart';
import 'package:untitled/widgets/nurse_course_type_selection.dart';
import 'package:untitled/widgets/pharmacist_course_type_selection.dart';
import 'package:untitled/widgets/physiotherapy_course_type_selection.dart';
import 'package:untitled/widgets/social_worker_course_selection.dart';

class SelectionProfession extends StatefulWidget {
  const SelectionProfession({super.key});

  @override
  State<SelectionProfession> createState() => _SelectionProfessionState();
}

class _SelectionProfessionState extends State<SelectionProfession> {
  String? profession;
  String? userId;

  final List<String> professions = [
    'Doctor',
    'Nurse',
    'Pharmacist',
    'Lab Technician',
    'Anesthesia Technician',
    'Dentist',
    'Physiotherapy',
    'Audiologist',
    'Dietitian',
    'Clinical Psychologist',
    'Social Worker',
    'Hospital Administrator',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    final savedProfession = prefs.getString('profession');

    if (mounted) {
      setState(() {
        userId = savedUserId;
        profession = savedProfession;
      });
    }

    print('Loaded userId: $savedUserId, profession: $savedProfession');
  }

  Future<void> _saveProfession() async {
    if (profession == null) {
      _showSnackBar("Please select a profession", Colors.red);
      return;
    }

    if (userId == null) {
      _showSnackBar("User ID not found. Please login again.", Colors.red);
      return;
    }

    final url = Uri.parse("https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId");

    final body = jsonEncode({
      "profession": profession,
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profession', profession!);
        _navigateToNextScreen();
      } else {
        _showSnackBar("Error: ${response.body}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Exception: $e", Colors.red);
    }
  }

  void _navigateToNextScreen() {
    switch (profession) {
      case 'Doctor':
        Navigator.pushNamed(context, '/dr_acd_status');
        break;
      case 'Nurse':
        showModalBottomSheet(
          context: context,
          builder: (_) => const NurseCourseTypeSelection(),
        );
        break;
      case 'Pharmacist':
        showModalBottomSheet(
          context: context,
          builder: (_) => const PharmacistCourseTypeSelection(),
        );
        break;
      case 'Lab Technician':
        showModalBottomSheet(
          context: context,
          builder: (_) => const LabTechnicianCourseTypeSelection(),
        );
        break;
      case 'Anesthesia Technician':
        showModalBottomSheet(
          context: context,
          builder: (_) => const AnaesthesiaTechnicianCourseTypeSelection(),
        );
        break;
      case 'Dentist':
        Navigator.pushNamed(context, '/dentist_academic_status');
        break;
      case 'Physiotherapy':
        showModalBottomSheet(
          context: context,
          builder: (_) => const PhysiotherapyCourseTypeSelection(),
        );
        break;
      case 'Audiologist':
        showModalBottomSheet(
          context: context,
          builder: (_) => const AudiologyCourseTypeSelection(),
        );
        break;
      case 'Dietitian':
        showModalBottomSheet(
          context: context,
          builder: (_) => const DietitianCourseTypeSelection(),
        );
        break;
      case 'Clinical Psychologist':
        showModalBottomSheet(
          context: context,
          builder: (_) => const ClinicalPsychologyCourseTypeSelection(),
        );
        break;
      case 'Social Worker':
        showModalBottomSheet(
          context: context,
          builder: (_) => const SocialWorkerCourseTypeSelection(),
        );
        break;
      case 'Hospital Administrator':
        showModalBottomSheet(
          context: context,
          builder: (_) => const HospitalAdministratorCourseTypeSelection(),
        );
        break;
      default:
        _showSnackBar("Invalid selection", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profession'),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => RadioListTile<String>(
          activeColor: mainBlue,
          value: professions[index],
          groupValue: profession,
          onChanged: (value) => setState(() => profession = value),
          title: Text(professions[index], style: radioTextStyle),
        ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: professions.length,
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _saveProfession,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: mainBlue,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}
