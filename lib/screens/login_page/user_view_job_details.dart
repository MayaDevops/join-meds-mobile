import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class UserViewJobDetails extends StatefulWidget {
  const UserViewJobDetails({super.key});

  @override
  State<UserViewJobDetails> createState() => _UserViewJobDetailsState();
}

class _UserViewJobDetailsState extends State<UserViewJobDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: false,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            color: mainBlue,
            child: Text(
              'Doctor MBBS & MD',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                
              ],
            ),
          )
        ],
      ),
    );
  }
}
