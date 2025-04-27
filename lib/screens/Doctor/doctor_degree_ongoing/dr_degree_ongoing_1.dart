import 'package:flutter/material.dart';

import '../../../constants/constant.dart';


class DrDegreeOngoing1 extends StatefulWidget {
  const DrDegreeOngoing1({super.key});

  @override
  State<DrDegreeOngoing1> createState() => _DrDegreeOngoing1State();
}

class _DrDegreeOngoing1State extends State<DrDegreeOngoing1> {
  String? academicYear;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profession - Doctor", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(

          children: [
            SizedBox(
              height: 50.0,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Text('Choose Your Current Year',style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),),
            ),
            SizedBox(
              height: 15,
            ),

            Row(
              children: [

               Row(
                 children: [
                   Radio(
                       activeColor: mainBlue,
                       value: '1st Year',
                       groupValue: academicYear,
                       onChanged: (value){
                         setState(() {
                           academicYear = value;
                         });
                       }),
                   Text('1st Year',style: radioTextStyle,),
                 ],
               ),
                SizedBox(
                  width: 50,
                ),
                Row(
                  children: [
                    Radio(
                        activeColor: mainBlue,
                        value: '2nd Year',
                        groupValue: academicYear,
                        onChanged: (value){
                          setState(() {
                            academicYear = value;
                          });
                        }),
                    Text('2nd Year',style: radioTextStyle,),
                  ],
                ),


              ],
            ),

            Row(

              children: [

                Row(
                  children: [
                    Radio(
                        activeColor: mainBlue,
                        value: '3rd Year',
                        groupValue: academicYear,
                        onChanged: (value){
                          setState(() {
                            academicYear = value;
                          });
                        }),
                    Text('3rd Year',style: radioTextStyle,),
                  ],
                ),
                SizedBox(
                  width: 50,
                ),
                Row(
                  children: [
                    Radio(
                        activeColor: mainBlue,
                        value: '4th Year',
                        groupValue: academicYear,
                        onChanged: (value){
                          setState(() {
                            academicYear = value;
                          });
                        }),
                    Text('4th Year',style: radioTextStyle,),
                  ],
                ),


              ],
            ),

            Row(

              children: [

                Row(
                  children: [
                    Radio(
                        activeColor: mainBlue,
                        value: '5th Year',
                        groupValue: academicYear,
                        onChanged: (value){
                          setState(() {
                            academicYear = value;
                          });
                        }),
                    Text('5th Year',style: radioTextStyle,),
                  ],
                ),
                SizedBox(
                  width: 50,
                ),
                Row(
                  children: [
                    Radio(
                        activeColor: mainBlue,
                        value: 'House Surgency',
                        groupValue: academicYear,
                        onChanged: (value){
                          setState(() {
                            academicYear = value;
                          });

                        }),
                    Text('House Surgency',style: radioTextStyle,),
                  ],
                ),

              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: Text('University of Education',style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),),
            ),

          ],
        ),
      ),
    );
  }
}
