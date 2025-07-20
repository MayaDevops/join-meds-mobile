import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constant.dart';
import '../../../widgets/repeated_headings.dart';
import '../../../widgets/text_form_fields.dart';

class NurseWorkExperience extends StatefulWidget {
  const NurseWorkExperience({super.key});

  @override
  State<NurseWorkExperience> createState() => _NurseWorkExperienceState();
}

class _NurseWorkExperienceState extends State<NurseWorkExperience> {
  final _workExpKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> workExperienceList = [];
  String? userId;

  final List<String> specialisationOptions = [
    'Casualty / Emergency Medicine',
    'OT',
    'ICU',
    'WARD',
    'Industrial Nurse',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      await _fetchExistingWorkExperiences(userId!);
    }
  }

  Future<void> _fetchExistingWorkExperiences(String userId) async {
    final response = await http.get(
      Uri.parse("https://api.joinmeds.in/api/work-experience/fetch/$userId"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      for (var item in data) {
        workExperienceList.add({
          'clinicalStatus': item['clinicalNonclinical'],
          'organisationController': TextEditingController(text: item['workedHospName']),
          'specialisation': specialisationOptions.contains(item['workSpecialisation'])
              ? item['workSpecialisation']
              : 'Others',
          'customSpecialisationController': TextEditingController(
              text: specialisationOptions.contains(item['workSpecialisation'])
                  ? ''
                  : item['workSpecialisation']),
          'fromDateController': TextEditingController(text: item['fromDate']),
          'toDateController': TextEditingController(text: item['toDate']),
        });
      }
    }

    if (workExperienceList.isEmpty) {
      _addWorkExperience();
    }

    setState(() {});
  }

  void _addWorkExperience() {
    setState(() {
      workExperienceList.add({
        'clinicalStatus': null,
        'organisationController': TextEditingController(),
        'specialisation': null,
        'customSpecialisationController': TextEditingController(),
        'fromDateController': TextEditingController(),
        'toDateController': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    for (var exp in workExperienceList) {
      exp['organisationController'].dispose();
      exp['customSpecialisationController'].dispose();
      exp['fromDateController'].dispose();
      exp['toDateController'].dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1965),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _saveExperienceData() async {
    for (var exp in workExperienceList) {
      final Map<String, dynamic> payload = {
        "userId": userId,
        "clinicalNonclinical": exp['clinicalStatus'],
        "workedHospName": exp['organisationController'].text.trim(),
        "workSpecialisation": exp['specialisation'] == 'Others'
            ? exp['customSpecialisationController'].text.trim()
            : exp['specialisation'],
        "fromDate": exp['fromDateController'].text.trim(),
        "toDate": exp['toDateController'].text.trim()
      };

      final response = await http.post(
        Uri.parse("https://api.joinmeds.in/api/work-experience/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("Failed to save: ${response.body}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Work Experience", style: TextStyle(color: Colors.white, fontSize: 25)),
        backgroundColor: mainBlue,
      ),
      body: Form(
        key: _workExpKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workExperienceList.length,
                itemBuilder: (context, index) {
                  final exp = workExperienceList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LabelText(labelText: 'Type of Experience'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('Clinical', style: TextStyle(fontSize: 18, color: inputBorderClr)),
                              Radio(
                                value: 'Clinical',
                                groupValue: exp['clinicalStatus'],
                                onChanged: (value) => setState(() => exp['clinicalStatus'] = value),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Non Clinical', style: TextStyle(fontSize: 18, color: inputBorderClr)),
                              Radio(
                                value: 'Non Clinical',
                                groupValue: exp['clinicalStatus'],
                                onChanged: (value) => setState(() => exp['clinicalStatus'] = value),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const LabelText(labelText: 'Organisation / Hospital'),
                      TextFormWidget(
                        controller: exp['organisationController'],
                        validator: (value) {
                          if (value!.isEmpty) return 'Required';
                          return null;
                        },
                        hintText: 'Enter name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: exp['specialisation'],
                        decoration: InputDecoration(
                          hintText: 'Select Specialisation',
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                        ),
                        items: specialisationOptions.map((item) {
                          return DropdownMenuItem(value: item, child: Text(item));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            exp['specialisation'] = value;
                            if (value != 'Others') exp['customSpecialisationController'].clear();
                          });
                        },
                      ),
                      if (exp['specialisation'] == 'Others')
                        TextFormWidget(
                          controller: exp['customSpecialisationController'],
                          hintText: 'Specify',
                          obscureText: false,
                        ),
                      const SizedBox(height: 10),
                      const LabelText(labelText: 'From'),
                      TextFormField(
                        controller: exp['fromDateController'],
                        readOnly: true,
                        onTap: () => _pickDate(context, exp['fromDateController']),
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.calendar_month, color: mainBlue),
                          hintText: 'Pick Date',
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const LabelText(labelText: 'To'),
                      TextFormField(
                        controller: exp['toDateController'],
                        readOnly: true,
                        onTap: () => _pickDate(context, exp['toDateController']),
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.calendar_month, color: mainBlue),
                          hintText: 'Pick Date',
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
              InkWell(
                onTap: _addWorkExperience,
                child: Row(
                  children: const [
                    LabelText(labelText: 'Add'),
                    Icon(Icons.add),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () async {
          if (_workExpKey.currentState!.validate()) {
            await _saveExperienceData();
            Navigator.pushNamed(context, '/County_that_you_preferred_page');
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: mainBlue,
        ),
        child: const Text('Continue', style: TextStyle(fontSize: 20.0, color: Colors.white)),
      ),
    );
  }
}
