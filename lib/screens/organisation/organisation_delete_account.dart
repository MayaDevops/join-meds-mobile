import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';

class OrganisationDeleteAccount extends StatefulWidget {
  const OrganisationDeleteAccount({super.key});

  @override
  State<OrganisationDeleteAccount> createState() => _OrganisationDeleteAccountState();
}

class _OrganisationDeleteAccountState extends State<OrganisationDeleteAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String? _fullPhoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _confirmDeletion() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please enter a valid mobile number');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _validateAndProceed();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _validateAndProceed() {
    if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
      _showSnackBar('Please enter a valid mobile number');
      return;
    }
    _formKey.currentState!.save();
    Navigator.pushNamed(
      context,
      '/organisation_delete_otp',
      arguments: {'phone_number': _fullPhoneNumber},
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _phoneController,
      initialCountryCode: 'IN',
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: 'Enter Mobile Number',
        hintStyle: hintStyle,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorStyle: errorStyle,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
      ),
      validator: (phone) {
        if (phone == null || phone.number.isEmpty) {
          return 'Please enter your mobile number';
        }
        if (!phone.isValidNumber()) {
          return 'Enter a valid phone number';
        }
        return null;
      },
      onChanged: (phone) => _fullPhoneNumber = phone.completeNumber,
      onSaved: (phone) => _fullPhoneNumber = phone?.completeNumber ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: const Text.rich(
          TextSpan(
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
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _confirmDeletion,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
            backgroundColor: const WidgetStatePropertyAll(Colors.red),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          child: const Text(
            'Verify',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.red,
                    semanticLabel: 'Warning Icon',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "We're sad to see you go.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Deleting your account will permanently erase all your data. Are you sure you want to continue?",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "To delete your account, please enter your mobile number:",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
