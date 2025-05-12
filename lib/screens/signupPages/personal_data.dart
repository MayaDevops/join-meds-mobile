import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/constants/images.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';
import '../../models/personal_data_model.dart';
import '../../api/personal_data_service.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
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
          Positioned.fill(
            child: Image.asset(
              bodyBg,
              fit: BoxFit.cover,
            ),
          ),
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
                      SizedBox(height: 30),
                      FormsMainHead(text: 'Set up your personal account'),
                      SizedBox(height: 30),
                      LabelText(labelText: 'Name'),
                      SizedBox(height: 5),
                      TextFormWidget(
                        controller: _nameController,
                        validator: (value) {
                          if (value!.isEmpty) return 'Name is required';
                          if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                            return 'Enter a valid name';
                          }
                          if (value.length < 3) return 'Name too short';
                          return null;
                        },
                        hintText: 'Enter name',
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Date Of Birth'),
                      TextFormField(
                        controller: _dobController,
                        validator: (value) =>
                        value!.isEmpty ? 'DOB is required' : null,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1965),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                final formattedDate =
                                DateFormat("yyyy-MM-dd").format(date);
                                setState(() {
                                  _dobController.text = formattedDate;
                                });
                              }
                            },
                            icon: Icon(Icons.calendar_month,
                                color: mainBlue, size: 35),
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
                      SizedBox(height: 15),
                      LabelText(labelText: 'Email'),
                      TextFormWidget(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Email is required';
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}")
                              .hasMatch(value)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Enter Email',
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Address'),
                      TextFormWidget(
                        controller: _addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Address required';
                          if (value.length < 5)
                            return 'Address too short';
                          if (!RegExp(r"^[a-zA-Z0-9\s,.-]+$")
                              .hasMatch(value)) {
                            return 'Invalid characters in address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                        hintText: 'Enter Address',
                        obscureText: false,
                      ),
                      SizedBox(height: 15),
                      LabelText(labelText: 'Aadhaar Number (Optional)'),
                      TextFormWidget(
                        controller: _aadhaarNumController,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter Aadhaar Number',
                        obscureText: false,
                      ),
                      SizedBox(height: 50),
                      MainButton(
                        text: 'Continue',
                        onPressed: () async {
                          if (_personalDataKey.currentState!.validate()) {
                            final data = PersonalDataModel(
                              fullname: _nameController.text.trim(),
                              dob: _dobController.text.trim(),
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                              aadhaarNo: _aadhaarNumController.text.trim(),
                            );

                            bool success = await PersonalDataService.savePersonalData(data);

                            if (success) {
                              Navigator.pushNamed(context, '/profile_picture');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to submit data')),
                              );
                            }
                          }
                        },
                      ),
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