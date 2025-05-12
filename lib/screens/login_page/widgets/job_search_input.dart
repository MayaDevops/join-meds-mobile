import 'package:flutter/material.dart';

class JobSearchInput extends StatelessWidget {
  const JobSearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Eg: Doctor, Nurse...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: const Text('Search jobs'),
            ),
          )
        ],
      ),
    );
  }
}