import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class OrganisationProfileSettings extends StatefulWidget {
  const OrganisationProfileSettings({super.key});

  @override
  State<OrganisationProfileSettings> createState() => _OrganisationProfileSettingsState();
}

class _OrganisationProfileSettingsState extends State<OrganisationProfileSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: RichText(
          text: const TextSpan(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: (){
              Navigator.pushNamed(context, 'organisation_privacy_policy');
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.black26),
                ),
              ),
              padding: EdgeInsets.only(left: 16, top: 15, bottom: 15),
              child: Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.pushNamed(context, 'organisation_terms_and_conditions');
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.black26),
                ),
              ),
              padding: EdgeInsets.only(left: 16, top: 15, bottom: 15),
              child: Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/organisation_delete_account');
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.black26),
                ),
              ),
              padding: EdgeInsets.only(left: 16, top: 15, bottom: 15),
              child: Text(
                'Delete Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
