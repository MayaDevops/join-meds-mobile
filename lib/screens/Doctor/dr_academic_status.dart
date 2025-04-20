import 'package:flutter/material.dart';

import '../../constants/constant.dart';

class DrAcademicStatus extends StatefulWidget {
  const DrAcademicStatus({super.key});

  @override
  State<DrAcademicStatus> createState() => _DrAcademicStatusState();
}

class _DrAcademicStatusState extends State<DrAcademicStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile Picture", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 50,
          ),
          Text(
            'Please select your academic status 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: inputBorderClr,
            ),
          ),
          SizedBox(height: 100,),
          
          Row(

            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Color(0xffD9D9D9),),
                width: 180,

                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Icon(Icons.menu_book,size: 70,color: mainBlue,),
                    Text('Degree Ongoing',style: TextStyle(
                      fontSize: 18,
                      color: mainBlue,
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 30,),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Color(0xffD9D9D9),),
                width: 180,

                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Icon(Icons.school,size: 70,color: mainBlue,),
                    Text('Degree Completed',style: TextStyle(
                      fontSize: 18,
                      color: mainBlue,
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 30,),
                  ],
                ),
              ),
            ],
          )

        ],
      ),
    );
  }
}
