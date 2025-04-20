import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';

class OrganisationLanding extends StatefulWidget {
  const OrganisationLanding({super.key});

  @override
  State<OrganisationLanding> createState() => _OrganisationLandingState();
}

class _OrganisationLandingState extends State<OrganisationLanding> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _orgLLPNumController = TextEditingController();

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgEmailController.dispose();
    _orgLLPNumController.dispose();
    super.dispose();
  }

  /// **Reusable Validation Method**
  String? _validateField(String? value, String fieldName,
      {int minLength = 1, String? pattern, String? errorMessage}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.length < minLength) return '$fieldName must be at least $minLength characters long';
    if (pattern != null && !RegExp(pattern).hasMatch(value)) return errorMessage ?? 'Invalid $fieldName format';
    return null;
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/org_phone_number');
    }
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
                    Image.asset(orgBanner1, fit: BoxFit.cover, width: double.infinity),
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
        padding: const EdgeInsets.all(20.0),
        child: MainButton(text: 'Continue', onPressed: _validateAndProceed),
      ),
    );
  }

  /// **Extracted Form Fields for Better Readability**
  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Name of Business/Organisation'),
        _buildTextField(_orgNameController, 'Name', minLength: 3, hintText: 'Enter Business/Organisation Name'),
        const SizedBox(height: 15),
        _buildLabel('Official Email Id'),
        _buildTextField(_orgEmailController, 'Email',
            pattern: r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
            errorMessage: 'Enter a valid email address',
            keyboardType: TextInputType.emailAddress,
            hintText: 'Enter Official Email Id'),
        const SizedBox(height: 15),
        _buildLabel('Company / LLP Incorporation No.'),
        _buildTextField(_orgLLPNumController, 'Incorporation No.', minLength: 5, hintText: 'Enter Incorporation No.'),
      ],
    );
  }

  /// **Reusable Label Widget**
  Widget _buildLabel(String text) => LabelText(labelText: text);

  /// **Reusable TextField Widget**
  Widget _buildTextField(TextEditingController controller, String fieldName,
      {int minLength = 1, String? pattern, String? errorMessage, TextInputType? keyboardType, String? hintText}) {
    return TextFormWidget(
      controller: controller,
      validator: (value) => _validateField(value, fieldName, minLength: minLength, pattern: pattern, errorMessage: errorMessage),
      keyboardType: keyboardType ?? TextInputType.text,
      hintText: hintText ?? '',
      obscureText: false,
    );
  }
}
