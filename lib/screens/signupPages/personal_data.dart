import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';
import '../../models/personal_data_model.dart';
import '../../api/personal_data_service.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarNumController = TextEditingController();
  final _personalDataKey = GlobalKey<FormState>();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdFromPrefs();
  }

  Future<void> _loadUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchAndFillPersonalData(id);
    }
  }

  Future<void> _fetchAndFillPersonalData(String userId) async {
    try {
      final response = await PersonalDataService.getPersonalData(userId);
      if (response != null) {
        setState(() {
          _nameController.text = response.fullname ?? '';
          _dobController.text = response.dob ?? '';
          _emailController.text = response.email ?? '';
          _addressController.text = response.address ?? '';
          _aadhaarNumController.text = response.aadhaarNo ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching personal data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _aadhaarNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Personal data",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              bodyBg,
              fit: BoxFit.cover,
            ),
          ),
          RawScrollbar(
            thumbColor: Colors.black38,
            thumbVisibility: true,
            thickness: 8,
            radius: Radius.circular(10),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _personalDataKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30),
                      FormsMainHead(text: 'Set up your personal account'),
                      SizedBox(height: 30),
                      LabelText(labelText: 'Name'),
                      SizedBox(height: 5),
                      TextFormWidget(
                        controller: _nameController,
                        validator: (value) {
                          if (value!.isEmpty) return 'Name is required';
                          if (value.length < 3) return 'Name too short';
                          return null;
                        },
                        hintText: 'Enter name',
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Date Of Birth'),
                      TextFormField(
                        controller: _dobController,
                        validator: (value) =>
                        value!.isEmpty ? 'DOB is required' : null,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1965),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                final formattedDate =
                                DateFormat("dd-mm-yyyy").format(date);
                                setState(() {
                                  _dobController.text = formattedDate;
                                });
                              }
                            },
                            icon: Icon(Icons.calendar_month,
                                color: mainBlue, size: 35),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Select DOB',
                          hintStyle: hintStyle,
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                          errorStyle: errorStyle,
                          errorBorder: errorBorder,
                          focusedErrorBorder: focusedErrorBorder,
                        ),
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Email'),
                      TextFormWidget(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email required';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                            return 'Enter valid email';
                          return null;
                        },
                        hintText: 'Enter Email',
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Address'),
                      TextFormWidget(
                        controller: _addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Address required';
                          if (value.length < 5) return 'Address too short';
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        hintText: 'Enter Address',
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Aadhaar Number (Optional)'),
                      TextFormWidget(
                        controller: _aadhaarNumController,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter Aadhaar Number',
                        obscureText: false,
                      ),
                      SizedBox(height: 50),
                      MainButton(
                        text: 'Continue',
                        onPressed: () async {
                          if (_personalDataKey.currentState!.validate() &&
                              userId != null) {
                            final data = PersonalDataModel(
                              fullname: _nameController.text.trim(),
                              dob: _dobController.text.trim(),
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                              aadhaarNo: _aadhaarNumController.text.trim(),
                              userId: userId!
                            );
                            debugPrint("Submitting JSON: ${jsonEncode(data.toJson())}");
                            bool success = await PersonalDataService.updatePersonalData(userId!, data);
                            if (success) {
                              Navigator.pushNamed(context, '/profile_picture');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to submit data')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
