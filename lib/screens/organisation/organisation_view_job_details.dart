import 'package:flutter/material.dart';

import '../../constants/constant.dart';
import '../../constants/organisation_datas.dart';
import 'organisation_home.dart';

class OrganisationViewJobDetails extends StatefulWidget {
  const OrganisationViewJobDetails({super.key});

  @override
  State<OrganisationViewJobDetails> createState() =>
      _OrganisationViewJobDetailsState();
}

class _OrganisationViewJobDetailsState
    extends State<OrganisationViewJobDetails> {
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 2, color: inputBorderClr),
              ),
            ),
            padding: EdgeInsets.only(left: 16, top: 20, bottom: 20),
            child: Text(
              OrganisationNameData().organisationName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: inputBorderClr,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Job Title: Doctor MBBS & MD',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xffFF6F61),
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Total Applied',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        '10',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
