import 'package:flutter/material.dart';
import '../../../constants/constant.dart';

class JobSearchInput extends StatelessWidget {
  const JobSearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Eg: Doctor, Nurse...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
          onPressed: (){},
          style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.all(15),),
          backgroundColor: WidgetStatePropertyAll(mainBlue),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
          ),

          child: Text('Search jobs',style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
          ),),
    ),
        ],
      ),
    );
  }
}


