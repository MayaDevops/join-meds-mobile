import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constant.dart';
import '../../../widgets/repeated_headings.dart';


class GeneralNurseInternshipCompleted extends StatefulWidget {
  const GeneralNurseInternshipCompleted({super.key});

  @override
  State<GeneralNurseInternshipCompleted> createState() => _GeneralNurseInternshipCompletedState();
}

class _GeneralNurseInternshipCompletedState extends State<GeneralNurseInternshipCompleted> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();


  final _personalDataKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Internship",
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [

          RawScrollbar(
            thumbColor: Colors.black38,
            thumbVisibility: true,
            thickness: 8,
            radius: Radius.circular(10),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _personalDataKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Container(

                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Years of Internship',
                          style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600,color: inputBorderClr),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      LabelText(labelText: 'From'),
                      TextFormField(
                        validator: (value) {
                          if(value!.isEmpty){
                            return "Date of birth is required";
                          }
                          return null;


                        },
                        controller: _fromDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async{
                              final DateTime ?date =  await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1965), // Fixed: First date must be older
                                lastDate: DateTime.now(),
                              );
                              final formatedDate = DateFormat("dd-MM-yyy").format(date!);

                              setState(() {
                                _fromDateController.text = formatedDate.toString();
                              });
                            },
                            icon: Icon(
                              Icons.calendar_month,
                              color: mainBlue,
                              size: 35,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Select Date',
                          hintStyle: hintStyle,
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                          errorStyle: errorStyle,
                          errorBorder: errorBorder,
                          focusedErrorBorder: focusedErrorBorder,
                        ),
                      ),

                      SizedBox(height: 15,),

                      LabelText(labelText: 'To'),
                      TextFormField(
                        validator: (value) {
                          if(value!.isEmpty){
                            return "Date is required";
                          }
                          return null;


                        },
                        controller: _toDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async{
                              final DateTime ?date =  await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1965), // Fixed: First date must be older
                                lastDate: DateTime.now(),
                              );
                              final formatedDate = DateFormat("dd-MM-yyy").format(date!);

                              setState(() {
                                _toDateController.text = formatedDate.toString();
                              });
                            },
                            icon: Icon(
                              Icons.calendar_month,
                              color: mainBlue,
                              size: 35,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Select Date',
                          hintStyle: hintStyle,
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                          errorStyle: errorStyle,
                          errorBorder: errorBorder,
                          focusedErrorBorder: focusedErrorBorder,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    bottomNavigationBar:   ElevatedButton(
        onPressed: () {
          if (_personalDataKey.currentState!.validate()) {
            showModalBottomSheet(context: context, builder: (context) => WorkExpSheet(),);
          }
        },
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.all(15),),
        backgroundColor: WidgetStatePropertyAll(mainBlue),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),),
      ),

      child: Text('Continue',style: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),),
    )
    );
  }
}


class WorkExpSheet extends StatefulWidget {
  const WorkExpSheet({super.key});

  @override
  State<WorkExpSheet> createState() => _WorkExpSheetState();
}

class _WorkExpSheetState extends State<WorkExpSheet> {
  String? workExpStatus;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: inputBorderClr, width: 1.5),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Text('Do you have any Work Experience',style: TextStyle(fontSize: 20),),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Row(
              children: [
                Text('Yes',style: radioTextStyle,),
                Radio(value: 'Work-Experience-Yes', groupValue: workExpStatus, onChanged: (value){
                  setState(() {
                    workExpStatus = value;
                  });
                })
              ],
            ),

            Row(
              children: [
                Text('No',style: radioTextStyle,),
                Radio(value: 'Work-Experience-No', groupValue: workExpStatus, onChanged: (value){
                  setState(() {
                    workExpStatus = value;
                  });
                }),
              ],
            ),

          ],
        ),
        const SizedBox(height: 30),
    ElevatedButton(
    onPressed: (){
      if(workExpStatus == 'Work-Experience-Yes'){
        Navigator.pushNamed(context, '/nurse_work_experience');
      }else{
        Navigator.pushNamed(context,  '/County_that_you_preferred_page');
      }
    },
    style: ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.all(15),),
    backgroundColor: WidgetStatePropertyAll(mainBlue),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),),
    ),

    child: Text('continue',style: TextStyle(
    fontSize: 20.0,
    color: Colors.white,
    ),),
    ),
      ],
    );
  }
}



