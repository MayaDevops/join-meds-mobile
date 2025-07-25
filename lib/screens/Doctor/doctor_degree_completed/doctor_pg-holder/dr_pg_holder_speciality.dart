import 'package:flutter/material.dart';
import '../../../../constants/constant.dart';
import '../../../../widgets/repeated_headings.dart';
import '../../../../widgets/text_form_fields.dart';

class SelectingDrSpeciality extends StatefulWidget {
  const SelectingDrSpeciality({super.key});

  @override
  State<SelectingDrSpeciality> createState() => _SelectingDrSpecialityState();
}

class _SelectingDrSpecialityState extends State<SelectingDrSpeciality> {
  final TextEditingController _othersController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? speciality;

  final List<String> doctorSpeciality = [
    'Obstetrics And Gyneacology',
    'Pediatrics',
    'Radiology',
    'Cardiology',
    'Neurology',
    'Oncology',
    'Psychiatry',
    'Audiologist',
    'Emergency Medicine',
    'Others',
  ];

  @override
  void dispose() {
    _othersController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (speciality == null) {
      _showSnackBar('Please select a speciality', Colors.red);
      return;
    }

    if (speciality == 'Others') {
      final result = await _openOthersBottomSheet();
      if (result == null) return;
      speciality = result;
      _showSnackBar('Speciality saved: $speciality', Colors.green);
    }

    await _startNextSteps();
  }

  Future<String?> _openOthersBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OthersTextField(
        formKey: _formKey,
        controller: _othersController,
      ),
    );
  }

  Future<void> _startNextSteps() async {
    // Show PhD Status and Work Experience Status in sequence
    final phDStatus = await _showOptionBottomSheet(
      title: 'Are you a PhD holder?',
      options: {
        'PhD Holder': 'Yes',
        'Not-PhD Holder': 'No',
        'PhD Ongoing': 'Ongoing',
      },
    );

    if (phDStatus == null) return;

    final workExpStatus = await _showOptionBottomSheet(
      title: 'Do you have any Work Experience?',
      options: {
        'Work Experience-Yes': 'Yes',
        'Work Experience-No': 'No',
      },
    );

    if (workExpStatus == null) return;

    // Navigate based on work experience status
    if (workExpStatus == 'Work Experience-No') {
      Navigator.pushNamed(context, '/County_that_you_preferred_page');
    } else if (workExpStatus == 'Work Experience-Yes') {
      Navigator.pushNamed(context, '/work_experience');
    }

  }

  Future<String?> _showOptionBottomSheet({
    required String title,
    required Map<String, String> options,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OptionBottomSheet(title: title, options: options),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your Speciality', style: appBarText),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 3,
          children: doctorSpeciality.map((item) {
            final isSelected = item == speciality;
            return GestureDetector(
              onTap: () => setState(() => speciality = item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? mainBlue : Colors.white,
                  border: Border.all(
                    color: isSelected ? mainBlue : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, //
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: mainBlue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    );
  }

}

class OthersTextField extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  const OthersTextField({
    super.key,
    required this.formKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const FormsMainHead(text: 'Specify your Speciality Here'),
            const SizedBox(height: 30),
            const LabelText(labelText: 'Speciality Name'),
            const SizedBox(height: 5),
            TextFormWidget(
              controller: controller,
              hintText: 'Enter your speciality',
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Speciality is required';
                } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  return 'Use letters and spaces only';
                } else if (value.trim().length < 3) {
                  return 'At least 3 characters required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainBlue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionBottomSheet extends StatefulWidget {
  final String title;
  final Map<String, String> options;

  const _OptionBottomSheet({super.key, required this.title, required this.options});

  @override
  State<_OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<_OptionBottomSheet> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inputBorderClr, width: 1.5)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Text(widget.title, style: const TextStyle(fontSize: 20)),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            children: widget.options.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.value, style: radioTextStyle),
                  Radio<String>(
                    value: entry.key,
                    groupValue: selectedValue,
                    onChanged: (value) => setState(() => selectedValue = value),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
          ),
          child: ElevatedButton(
            onPressed: () {
              if (selectedValue != null) {
                Navigator.pop(context, selectedValue);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select an option', textAlign: TextAlign.center),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainBlue,
              padding: const EdgeInsets.all(15),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10),),),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

