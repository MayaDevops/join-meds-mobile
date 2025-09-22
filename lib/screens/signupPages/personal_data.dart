import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';
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
  final _personalDataKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarNumController = TextEditingController();

  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id != null && mounted) {
      setState(() => userId = id);
      _fetchAndFillPersonalData(id);
    }
  }

  Future<void> _fetchAndFillPersonalData(String userId) async {
    try {
      final data = await PersonalDataService.getPersonalData(userId);
      if (data != null && mounted) {
        setState(() {
          _nameController.text = data.fullname ?? '';
          _dobController.text = data.dob ?? '';
          _emailController.text = data.email ?? '';
          _addressController.text = data.address ?? '';
          _aadhaarNumController.text = data.aadhaarNo ?? '';
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

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1965),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final formattedDate = DateFormat("dd-MM-yyyy").format(date);
      setState(() => _dobController.text = formattedDate);
    }
  }

  Future<void> _submitData() async {
    if (!_personalDataKey.currentState!.validate() || userId == null) return;

    final data = PersonalDataModel(
      fullname: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      aadhaarNo: _aadhaarNumController.text.trim(),
      userId: userId!,
    );

    debugPrint("Submitting JSON: ${jsonEncode(data.toJson())}");

    final success = await PersonalDataService.updatePersonalData(userId!, data);
    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(context, '/resume_upload');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Personal Data",
          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Image.asset(bodyBg, fit: BoxFit.cover)),
          RawScrollbar(
            thumbColor: Colors.black38,
            thumbVisibility: true,
            thickness: 8,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _personalDataKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    const FormsMainHead(text: 'Set up your personal account'),
                    const SizedBox(height: 30),
                    LabelText(labelText: 'Name'),
                    const SizedBox(height: 5),
                    TextFormWidget(
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name is required';
                        if (value.length < 3) return 'Name too short';
                        return null;
                      },
                      hintText: 'Enter name',
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    LabelText(labelText: 'Date Of Birth'),
                    TextFormField(
                      controller: _dobController,
                      validator: (value) => (value == null || value.isEmpty) ? 'DOB is required' : null,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month, color: mainBlue, size: 35),
                          onPressed: _selectDate,
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
                    const SizedBox(height: 15),
                    LabelText(labelText: 'Email'),
                    TextFormWidget(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email required';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter valid email';
                        return null;
                      },
                      hintText: 'Enter Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    LabelText(labelText: 'Address'),
                    TextFormWidget(
                      controller: _addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Address required';
                        if (value.length < 5) return 'Address too short';
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      hintText: 'Enter Address',
                      obscureText: false,
                    ),
                    const SizedBox(height: 15),
                    LabelText(labelText: 'Aadhaar Number (Optional)'),
                    TextFormWidget(
                      controller: _aadhaarNumController,
                      keyboardType: TextInputType.number,
                      hintText: 'Enter Aadhaar Number',
                      obscureText: false,
                    ),
                    const SizedBox(height: 50),
                    MainButton(
                      text: 'Continue',
                      onPressed: _submitData,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
