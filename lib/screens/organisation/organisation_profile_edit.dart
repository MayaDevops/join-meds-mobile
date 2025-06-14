import 'package:flutter/material.dart';
import 'package:untitled/constants/organisation_datas.dart';
import '../../constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';

class OrganisationProfileEdit extends StatefulWidget {
  const OrganisationProfileEdit({super.key});

  @override
  State<OrganisationProfileEdit> createState() =>
      _OrganisationProfileEditState();
}

class _OrganisationProfileEditState extends State<OrganisationProfileEdit> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _incorporationNoController;

  // Singleton data instances
  late final OrganisationNameData _orgNameData;
  late final OrganisationOfficialEmail _orgEmailData;
  late final OrganisationRegisteredLocation _orgLocationData;
  late final OrganisationIncorporationNumber _orgIncorporationData;

  @override
  void initState() {
    super.initState();

    _orgNameData = OrganisationNameData();
    _orgEmailData = OrganisationOfficialEmail();
    _orgLocationData = OrganisationRegisteredLocation();
    _orgIncorporationData = OrganisationIncorporationNumber();

    _nameController =
        TextEditingController(text: _orgNameData.organisationName);
    _emailController =
        TextEditingController(text: _orgEmailData.organisationEmail);
    _locationController =
        TextEditingController(text: _orgLocationData.organisationLocation);
    _incorporationNoController = TextEditingController(
        text: _orgIncorporationData.organisationIncorporationNo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _incorporationNoController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _orgNameData.organisationName = _nameController.text;
      _orgEmailData.organisationEmail = _emailController.text;
      _orgLocationData.organisationLocation = _locationController.text;
      _orgIncorporationData.organisationIncorporationNo =
          _incorporationNoController.text;

      Navigator.pushNamed(context, '/profile_picture');
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(labelText: label),
        const SizedBox(height: 5),
        TextFormWidget(
          controller: controller,
          hintText: hint,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: false,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        titleSpacing: 16,
        automaticallyImplyLeading: true,
        title: RichText(
          text: TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thickness: 8,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                const FormsMainHead(text: 'Edit your Profile'),
                const SizedBox(height: 15),

                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Enter name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                      return 'Enter a valid name';
                    } else if (value.length < 3) {
                      return 'Name too short';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$")
                        .hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  label: "Company's Registered Location",
                  controller: _locationController,
                  hint: 'Enter company address',
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Location required' : null,
                ),

                _buildTextField(
                  label: 'Company / LLP Incorporation No.',
                  controller: _incorporationNoController,
                  hint: 'Enter incorporation number',
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Incorporation No. required' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: mainBlue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
