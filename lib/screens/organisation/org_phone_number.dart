import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';


class OrgPhoneNumber extends StatefulWidget {
  const OrgPhoneNumber({super.key});

  @override
  State<OrgPhoneNumber> createState() => _OrgPhoneNumberState();
}

class _OrgPhoneNumberState extends State<OrgPhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  String? _fullPhoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// **Displays a SnackBar Message**
  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// **Validates and Navigates to OTP Screen**
  void _validateAndProceed() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please enter a valid mobile number');
      return;
    }

    if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
      _showSnackBar('Please enter a valid mobile number');
      return;
    }

    _formKey.currentState!.save();
    Navigator.pushNamed(
      context,
      '/organisation_otp',
      arguments: {'phone_number': _fullPhoneNumber},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MainButton(text: 'Verify', onPressed: _validateAndProceed),
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(orgBanner1, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        'We Will Send your One Time Password on this Mobile Number',
                        style: subHeadForms,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildPhoneField(),
                      const SizedBox(
                          height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Phone Input Field**
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
      validator: (p0) => (p0 != null && p0.isValidNumber())
          ? null
          : 'Enter a valid phone number',
      onChanged: (phone) => _fullPhoneNumber = phone.completeNumber,
      onSaved: (phone) => _fullPhoneNumber = phone?.completeNumber ?? '',
    );
  }
}
