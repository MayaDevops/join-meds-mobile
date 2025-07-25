import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constant.dart';
import '../../../widgets/repeated_headings.dart';
import '../../../widgets/text_form_fields.dart';

class WorkExperience extends StatefulWidget {
  const WorkExperience({super.key});

  @override
  State<WorkExperience> createState() => _WorkExperienceState();
}

class _WorkExperienceState extends State<WorkExperience> {
  final _workExpKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> workExperienceList = [];

  final List<String> specialisationOptions = [
    'Obstetrics and Gyneacology',
    'Pediatrics',
    'Radiology',
    'Cardiology',
    'Neurology',
    'Oncology',
    'Psychiatry',
    'Emergency Medicine',
    'Cosmetology',
    'Ent',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _addWorkExperience(); // Start with one section
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Work Experience",
          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        backgroundColor: mainBlue,
      ),
      body: Form(
        key: _workExpKey,
        child: RawScrollbar(
          thumbColor: Colors.black38,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workExperienceList.length,
                  itemBuilder: (context, index) {
                    final exp = workExperienceList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelText(labelText: 'Type of Experience'),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                const Text('Clinical', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: inputBorderClr)),
                                Radio(
                                  value: 'Clinical',
                                  groupValue: exp['clinicalStatus'],
                                  onChanged: (value) {
                                    setState(() {
                                      exp['clinicalStatus'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Non Clinical', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: inputBorderClr)),
                                Radio(
                                  value: 'Non Clinical',
                                  groupValue: exp['clinicalStatus'],
                                  onChanged: (value) {
                                    setState(() {
                                      exp['clinicalStatus'] = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        LabelText(labelText: 'Organisation / Hospital'),
                        const SizedBox(height: 5),
                        TextFormWidget(
                          controller: exp['organisationController'],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name is required';
                            } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                              return 'Enter a valid name using letters and spaces only';
                            } else if (value.length < 3) {
                              return 'Name must be at least 3 characters long';
                            }
                            return null;
                          },
                          hintText: 'Specify organisation/hospital',
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: exp['specialisation'],
                          decoration: InputDecoration(
                            hintText: 'Select Work Specialisation',
                            hintStyle: hintStyle,
                            enabledBorder: enabledBorder,
                            focusedBorder: focusedBorder,
                            errorStyle: errorStyle,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
                          ),
                          items: specialisationOptions.map((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              exp['specialisation'] = value;
                              if (value != 'Others') {
                                exp['customSpecialisationController'].clear();
                              }
                            });
                          },
                        ),
                        if (exp['specialisation'] == 'Others') ...[
                          const SizedBox(height: 10),
                          TextFormWidget(
                            controller: exp['customSpecialisationController'],
                            validator: (value) {
                              if (exp['specialisation'] == 'Others' && (value == null || value.isEmpty)) {
                                return 'Please specify specialisation';
                              }
                              return null;
                            },
                            hintText: 'Enter your Specialisation',
                            obscureText: false,
                          ),
                        ],
                        const SizedBox(height: 15),
                        LabelText(labelText: 'From'),
                        TextFormField(
                          controller: exp['fromDateController'],
                          readOnly: true,
                          validator: (value) => value!.isEmpty ? 'Date is required' : null,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month, color: mainBlue, size: 30),
                              onPressed: () => _pickDate(context, exp['fromDateController']),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Select Date',
                            hintStyle: hintStyle,
                            enabledBorder: enabledBorder,
                            focusedBorder: focusedBorder,
                            errorStyle: errorStyle,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
                          ),
                        ),
                        const SizedBox(height: 15),
                        LabelText(labelText: 'To'),
                        TextFormField(
                          controller: exp['toDateController'],
                          readOnly: true,
                          validator: (value) => value!.isEmpty ? 'Date is required' : null,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month, color: mainBlue, size: 30),
                              onPressed: () => _pickDate(context, exp['toDateController']),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Select Date',
                            hintStyle: hintStyle,
                            enabledBorder: enabledBorder,
                            focusedBorder: focusedBorder,
                            errorStyle: errorStyle,
                            errorBorder: errorBorder,
                            focusedErrorBorder: focusedErrorBorder,
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
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(25),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: () {
            if (_workExpKey.currentState!.validate()) {
              List<Map<String, dynamic>> finalData = workExperienceList.map((exp) {
                return {
                  'typeOfExperience': exp['clinicalStatus'],
                  'organisation': exp['organisationController'].text,
                  'specialisation': exp['specialisation'] == 'Others'
                      ? exp['customSpecialisationController'].text
                      : exp['specialisation'],
                  'from': exp['fromDateController'].text,
                  'to': exp['toDateController'].text,
                };
              }).toList();

              print(finalData);

              Navigator.pushNamed(context, '/dr_certification_of_spl');
            }
          },
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
    );
  }
}
