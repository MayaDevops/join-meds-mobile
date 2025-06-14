import 'package:flutter/material.dart';
import 'package:untitled/constants/organisation_datas.dart';
import 'package:untitled/widgets/repeated_headings.dart';

import '../../constants/constant.dart';

class OrganisationViewProfile extends StatefulWidget {
  const OrganisationViewProfile({super.key});

  @override
  State<OrganisationViewProfile> createState() =>
      _OrganisationViewProfileState();
}

class _OrganisationViewProfileState extends State<OrganisationViewProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
            ),
            CircleAvatar(
              radius: 60,
              backgroundColor: mainBlue,
              child: Text(
                OrganisationNameData().organisationName.isNotEmpty
                    ? OrganisationNameData().organisationName[0].toUpperCase()
                    : '',
                style: const TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Name of business/organisation',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              OrganisationNameData().organisationName,
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Company's Registered Location",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              OrganisationRegisteredLocation().organisationLocation,
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Official Email id" ,
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              OrganisationOfficialEmail().organisationEmail,
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Company / LLP incorporation no.',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              OrganisationIncorporationNumber().organisationIncorporationNo,
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Phone Number',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              OrganisationPhoneNumber().organisationPhoneNumber,
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
          ],
        ),
      ),
    );
  }
}
