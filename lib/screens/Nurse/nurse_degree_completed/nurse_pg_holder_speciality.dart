import 'package:flutter/material.dart';
import '../../../../constants/constant.dart';
import '../../../../widgets/repeated_headings.dart';
import '../../../../widgets/text_form_fields.dart';

class SelectingNurseSpeciality extends StatefulWidget {
  const SelectingNurseSpeciality({super.key});

  @override
  State<SelectingNurseSpeciality> createState() => _SelectingNurseSpecialityState();
}

class _SelectingNurseSpecialityState extends State<SelectingNurseSpeciality> {
  final TextEditingController _othersController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedSpeciality;

  final List<String> _nurseSpecialities = [
    'Medical Surgical',
    'Psychiatry',
    'Community Nursing',
    'Child Health / Pediatrics',
    'Obstetric and Gynaecological Nursing',
    'Others',
  ];

  @override
  void dispose() {
    _othersController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (_selectedSpeciality == null) {
      _showSnackBar('Please select a speciality');
      return;
    }

    if (_selectedSpeciality == 'Others') {
      final customSpeciality = await _openOthersBottomSheet();
      if (customSpeciality == null) return;
      _selectedSpeciality = customSpeciality;
      _showSnackBar('Speciality saved: $_selectedSpeciality', color: Colors.green);
    }

    await _handleNextSteps();
  }

  Future<String?> _openOthersBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => OthersTextField(formKey: _formKey, controller: _othersController),
    );
  }

  Future<void> _handleNextSteps() async {
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

    Navigator.pushNamed(
      context,
      workExpStatus == 'Work Experience-No'
          ?  '/County_that_you_preferred_page' //navigate to country preferred page
          : '/nurse_work_experience',
    );
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
      builder: (_) => OptionBottomSheet(title: title, options: options),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your Speciality', style: appBarText),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _nurseSpecialities.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) {
          final speciality = _nurseSpecialities[index];
          return ListTile(
            leading: Radio<String>(
              activeColor: mainBlue,
              value: speciality,
              groupValue: _selectedSpeciality,
              onChanged: (value) => setState(() => _selectedSpeciality = value),
            ),
            title: Text(speciality, style: radioTextStyle),
            onTap: () => setState(() => _selectedSpeciality = speciality),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: _onSavePressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            backgroundColor: mainBlue,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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

  const OthersTextField({super.key, required this.formKey, required this.controller});

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
                if (value == null || value.trim().isEmpty) {
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

class OptionBottomSheet extends StatefulWidget {
  final String title;
  final Map<String, String> options;

  const OptionBottomSheet({super.key, required this.title, required this.options});

  @override
  State<OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<OptionBottomSheet> {
  String? _selectedOption;

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
                    groupValue: _selectedOption,
                    onChanged: (value) => setState(() => _selectedOption = value),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedOption != null) {
              Navigator.pop(context, _selectedOption);
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ],
    );
  }
}
