import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/constants/constant.dart';

import '../../widgets/main_button.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';


class CountryThatYouPreferred extends StatefulWidget {
  const CountryThatYouPreferred({super.key});

  @override
  State<CountryThatYouPreferred> createState() => _CountryThatYouPreferredState();
}

class _CountryThatYouPreferredState extends State<CountryThatYouPreferred> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarNumController = TextEditingController();

  final _personalDataKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _aadhaarNumController.dispose();
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
          "Personal data",
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
                      FormsMainHead(
                        text: 'Set up your personal account',
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      LabelText(
                        labelText: 'Name',
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormWidget(
                          controller: _nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name is required';
                            } else if (!RegExp(r"^[a-zA-Z\s]+$")
                                .hasMatch(value)) {
                              return 'Enter a valid name use letters and spaces only';
                            } else if (value.length < 3) {
                              return 'Name must be at least 3 characters long';
                            }
                            return null;
                          },
                          hintText: 'Enter name', obscureText: false
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      LabelText(labelText: 'Date Of Birth'),
                      TextFormField(
                        validator: (value) {
                          if(value!.isEmpty){
                            return "Date of birth is required";
                          }
                          return null;


                        },
                        controller: _dobController,
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
                                _dobController.text = formatedDate.toString();
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
                          hintText: 'Select DOB',
                          hintStyle: hintStyle,
                          enabledBorder: enabledBorder,
                          focusedBorder: focusedBorder,
                          errorStyle: errorStyle,
                          errorBorder: errorBorder,
                          focusedErrorBorder: focusedErrorBorder,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      LabelText(labelText: 'Email'),
                      TextFormWidget(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }

                          else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;


                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hintText: 'Enter Email',
                        obscureText: false,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      LabelText(labelText: 'Address'),
                      TextFormWidget(
                        controller: _addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          } else if (value.length < 5) {
                            return 'Address must be at least 5 characters long';
                          } else if (!RegExp(r"^[a-zA-Z0-9\s,.-]+$").hasMatch(value)) {
                            return 'Enter a valid address (letters, numbers, spaces, , . - only)';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter Address',
                        obscureText: false,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      LabelText(labelText: 'Aadhaar Number (Optional)'),
                      TextFormWidget(

                        keyboardType: TextInputType.emailAddress,
                        controller: _aadhaarNumController,
                        hintText: 'Enter Aadhaar Number',
                        obscureText: false,
                      ),
                      SizedBox(height: 50,),
                      MainButton(
                          text: 'Continue',
                          onPressed: () {
                            if (_personalDataKey.currentState!.validate()) {
                              Navigator.pushNamed(context, '/profile_picture');
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
