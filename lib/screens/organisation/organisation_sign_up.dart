import 'package:flutter/material.dart';
// import 'package:untitled/api/organisation_api.dart'; // API temporarily not in use
// import 'package:untitled/models/organisation_signup_model.dart'; // Model for API call

import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import 'package:untitled/widgets/text_form_fields.dart';

import '../../constants/constant.dart';
import '../../constants/organisation_datas.dart';
import 'organisation_home.dart';

class OrganisationSingUp extends StatefulWidget {
  const OrganisationSingUp({super.key});

  @override
  State<OrganisationSingUp> createState() => _OrganisationSingUpState();
}

class _OrganisationSingUpState extends State<OrganisationSingUp> {
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _registeredLocationController =
      TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _orgLLPNumController = TextEditingController();
  // final TextEditingController _orgPasswordController = TextEditingController();
  // final TextEditingController _orgConfpasswordController = TextEditingController();

  @override
  void dispose() {
    _orgNameController.dispose();
    _registeredLocationController.dispose();
    _orgEmailController.dispose();
    _orgLLPNumController.dispose();
    // _orgPasswordController.dispose();
    // _orgConfpasswordController.dispose();
    super.dispose();
  }

  String? _validateField(String? value, String fieldName,
      {int minLength = 1, String? pattern, String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    if (pattern != null && !RegExp(pattern).hasMatch(value)) {
      return errorMessage ?? 'Invalid $fieldName format';
    }
    return null;
  }

  void _validateAndProceed() async {
    if (_formKey.currentState!.validate()) {
      // Save organisation name globally
      OrganisationNameData().organisationName = _orgNameController.text.trim();
      OrganisationRegisteredLocation().organisationLocation =
          _registeredLocationController.text.trim();
      OrganisationOfficialEmail().organisationEmail =
          _orgEmailController.text.trim();
      OrganisationIncorporationNumber().organisationIncorporationNo =
          _orgLLPNumController.text.trim();
      // Prepare organisation data (for future API use)
      /*
      final data = OrganisationSignup(
        orgName: _orgNameController.text.trim(),
        officialEmail: _orgEmailController.text.trim(),
        officialPhone: "9999999999", // placeholder
        incorporationNo: _orgLLPNumController.text.trim(),
        emailMobile: _orgEmailController.text.trim(), // assume same
        // password: _orgPasswordController.trim(),
        // confPassword: _orgConfpasswordController.trim(),
        createdAt: DateTime.now().toIso8601String(),
        userType: "organisation",
      );
      */

      try {
        // Call signup API (currently disabled)
        /*
        final response = await OrganisationApi.signupOrganisation(data);
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pushNamed(context, '/org_phone_number');
        } else {
          _showErrorDialog(
              'Signup failed: ${response.statusCode}\n${response.body}');
        }
        */

        // Temporary navigation until API is implemented
        if (isChecked == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must accept the terms and conditions.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          // Proceed to the next step
          Navigator.pushNamed(context, '/org_phone_number');
        }
      } catch (e) {
        _showErrorDialog('An error occurred: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(orgBanner1,
                      fit: BoxFit.cover, width: double.infinity),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: _buildFormFields(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainButton(text: 'Continue', onPressed: _validateAndProceed),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('If you have an account ',
                    style: TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/organisation_login'),
                  child: Text(
                    ' Login',
                    style: TextStyle(
                        fontSize: 16,
                        color: mainBlue,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelText(labelText: 'Name of Business/Organisation'),
        _buildTextField(_orgNameController, 'Name',
            minLength: 3, hintText: 'Enter Business/Organisation Name'),
        const SizedBox(height: 15),
        LabelText(labelText: "Company's Registered Location"),
        _buildTextField(_registeredLocationController, 'Location',
            minLength: 3, hintText: 'Eg: Thiruvananthapuram,Kerala'),
        const SizedBox(height: 15),
        LabelText(labelText: 'Official Email Id'),
        _buildTextField(_orgEmailController, 'Email',
            pattern: r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            errorMessage: 'Enter a valid email address',
            keyboardType: TextInputType.emailAddress,
            hintText: 'Enter Official Email Id'),
        const SizedBox(height: 15),
        LabelText(labelText: 'Company / LLP Incorporation No.'),
        _buildTextField(_orgLLPNumController, 'Incorporation No.',
            minLength: 5, hintText: 'Enter Incorporation No.'),
        const SizedBox(height: 15),
        Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (bool? newValue) {
                setState(() {
                  isChecked = newValue ?? false;
                });
              },
            ),
            const Text(
              'I Agree ',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: inputBorderClr),
            ),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, 'organisation_terms_and_conditions');
              },
              child: Text(
                'Terms and Conditions',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent),
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String fieldName,
      {int minLength = 1,
      String? pattern,
      String? errorMessage,
      TextInputType? keyboardType,
      String? hintText}) {
    return TextFormWidget(
      controller: controller,
      validator: (value) => _validateField(value, fieldName,
          minLength: minLength, pattern: pattern, errorMessage: errorMessage),
      keyboardType: keyboardType ?? TextInputType.text,
      hintText: hintText ?? '',
      obscureText: false,
    );
  }
}
