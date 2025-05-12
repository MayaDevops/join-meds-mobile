import 'package:flutter/material.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'widgets/job_search_input.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                  text: 'Join',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              TextSpan(
                  text: 'Meds',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('images/banner-home.png'),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Enter job title", style: TextStyle(fontSize: 18)),
          ),
          const JobSearchInput(),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}