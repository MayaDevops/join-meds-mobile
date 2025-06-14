import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Doctor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Job Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: mainBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    decoration: const BoxDecoration(
                      color: mainBlue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Doctors MBBS & MD',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Hospital Info
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                        const Text(
                          'KIMSHEALTH Hospital Trivandrum',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildTag('From ₹800 an hour'),
                            const SizedBox(width: 8),
                            _buildTag('Full-time'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  // Apply Now Button
                  Container(
                    decoration: const BoxDecoration(
                      color: mainBlue,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'user_view_job_details');
                      },
                      child: const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white,fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),


    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}