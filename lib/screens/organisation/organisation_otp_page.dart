import 'package:flutter/material.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';
import '../../widgets/0tpInputField.dart';

class OrganisationOtpPage extends StatefulWidget {
  const OrganisationOtpPage({super.key});

  @override
  State<OrganisationOtpPage> createState() => _OrganisationOtpPageState();
}

class _OrganisationOtpPageState extends State<OrganisationOtpPage> {
  late final TextEditingController _phoneController;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phoneNumber = (ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?)?['phone_number'] ??
        'N/A';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
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
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
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
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.edit, color: mainBlue),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                    OtpSizedBox(
                      child: OtpField(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text('Didn’t get OTP?', style: subHeadForms),
                ),
                Container(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {},
                    child: Text(
                      'Resent OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: mainBlue,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                MainButton(
                    text: 'Verify',
                    onPressed: (){
                      Navigator.pushNamed(context, '/about_organisation');
                    },),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
