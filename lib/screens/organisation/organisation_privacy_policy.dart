import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class OrganisationPrivacyPolicy extends StatefulWidget {
  const OrganisationPrivacyPolicy({super.key});

  @override
  State<OrganisationPrivacyPolicy> createState() => _OrganisationPrivacyPolicyState();
}

class _OrganisationPrivacyPolicyState extends State<OrganisationPrivacyPolicy> {
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
