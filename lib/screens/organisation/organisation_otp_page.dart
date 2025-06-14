import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/constants/organisation_datas.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';
import '../../widgets/0tpInputField.dart';

class OrganisationOtpPage extends StatefulWidget {
  const OrganisationOtpPage({super.key});

  @override
  State<OrganisationOtpPage> createState() => _OrganisationOtpPageState();
}

class _OrganisationOtpPageState extends State<OrganisationOtpPage> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());

  late String _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phoneNumber = (ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>?)?['phone_number'] ??
        'N/A';
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _onVerifyPressed() {
    final otp = _otpControllers.map((c) => c.text.trim()).join();

    if (otp.length != 6 || otp.contains(RegExp(r'\D'))) {
      _showSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    OrganisationPhoneNumber().organisationPhoneNumber = _phoneNumber;
    Navigator.pushNamed(context, '/organisation_signUpLoading');
  }

  Widget _buildOtpInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
            (index) => OtpSizedBox(
          child: OtpField(controller: _otpControllers[index]),
        ),
      ),
    );
  }

  Widget _buildOtpInfoSection() {
    return Column(
      children: [
        const Text(
          'You’ll receive a 6-digit OTP on your \nmobile number',
          textAlign: TextAlign.center,
          style: subHeadForms,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_phoneNumber, style: subHeadForms),
            IconButton(
              icon: Icon(Icons.edit, color: mainBlue),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        const Text('Didn’t get OTP?', style: subHeadForms),
        InkWell(
          onTap: () {
            // TODO: Implement resend OTP functionality
          },
          child: Text(
            'Resend OTP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: mainBlue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "OTP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: mainBlue,
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(otpBanner, height: 280),
              const SizedBox(height: 16),
              _buildOtpInfoSection(),
              const SizedBox(height: 20),
              _buildOtpInputFields(),
              const SizedBox(height: 40),
              _buildResendSection(),
              const SizedBox(height: 50),
              MainButton(text: 'Verify', onPressed: _onVerifyPressed),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpField extends StatelessWidget {
  final TextEditingController controller;

  const OtpField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        counterText: '',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }
}

class OtpSizedBox extends StatelessWidget {
  final Widget child;
  const OtpSizedBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 60,
      child: child,
    );
  }
}
