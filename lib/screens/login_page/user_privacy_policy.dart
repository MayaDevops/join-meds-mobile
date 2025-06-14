import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class UserPrivacyPolicy extends StatefulWidget {
  const UserPrivacyPolicy({super.key});

  @override
  State<UserPrivacyPolicy> createState() => _UserPrivacyPolicyState();
}

class _UserPrivacyPolicyState extends State<UserPrivacyPolicy> {
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
      body: Center(
        child: Text('Privacy Policy',style: TextStyle(fontSize: 18),),
      ),
    );
  }
}
