import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/constants/organisation_datas.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';

class OrganisationDeleteOtpPage extends StatefulWidget {
  const OrganisationDeleteOtpPage({super.key});

  @override
  State<OrganisationDeleteOtpPage> createState() => _OrganisationDeleteOtpPageState();
}

class _OrganisationDeleteOtpPageState extends State<OrganisationDeleteOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _phoneNumber = args?['phone_number'] ?? 'N/A';
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
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
    Navigator.pushNamed(context, '/landing_page');
  }

  Widget _buildOtpInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            },
          ),
        );
      }),
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
          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
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
              Text(
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
                    icon: const Icon(Icons.edit, color: mainBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOtpInputFields(),
              const SizedBox(height: 40),
              const Text(
                'Didn’t get OTP?',
                textAlign: TextAlign.center,
                style: subHeadForms,
              ),
              InkWell(
                onTap: () {
                  // TODO: Add resend OTP logic
                },
                child: Center(
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: mainBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              MainButton(
                text: 'Verify',
                onPressed: _onVerifyPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
