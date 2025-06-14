import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class UserTermsAndCondition extends StatefulWidget {
  const UserTermsAndCondition({super.key});

  @override
  State<UserTermsAndCondition> createState() => _UserTermsAndConditionState();
}

class _UserTermsAndConditionState extends State<UserTermsAndCondition> {
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
        child: Text('Terms and Conditions',style: TextStyle(fontSize: 18),),
      ),
    );
  }
}
