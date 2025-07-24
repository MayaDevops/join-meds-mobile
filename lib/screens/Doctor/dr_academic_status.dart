import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import './doctor_degree_completed/doctor_pg-holder/dr_pg_holder_speciality.dart';

class DrAcademicStatus extends StatefulWidget {
  const DrAcademicStatus({super.key});

  @override
  State<DrAcademicStatus> createState() => _DrAcademicStatusState();
}

class _DrAcademicStatusState extends State<DrAcademicStatus> {
  String? postGraduation;

  void _handleSubmit() async {
    if (postGraduation == null) {
      _showSnackBar('Please select a profession', Colors.red);
      return;
    }

    if (postGraduation == 'PG-Holder') {
      Navigator.pushNamed(context, '/dr_pg_holder_speciality');
    } else {
      final workExpStatus = await _showOptionBottomSheet(
        title: 'Do you have any Work Experience?',
        options: {'Work-Experience-Yes': 'Yes', 'Work-Experience-No': 'No'},
      );

      if (workExpStatus == null) return;
      Navigator.pushNamed(
        context,
        workExpStatus == 'No'
            ? '/County_that_you_preferred_page'
            : '/work_experience',
      );
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _OptionBottomSheet(title: title, options: options),
    );
  }

  void _showSnackBar(String message, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _openPostGraduationSheet() =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        builder: (_) => _PostGraduationSheet(
          initialValue: postGraduation,
          onChanged: (value) => setState(() => postGraduation = value),
          onSave: _handleSubmit,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Academic Status", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          const Text(
            'Please select your academic status 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: inputBorderClr),
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AcademicOption(
                icon: Icons.menu_book,
                label: 'Degree Ongoing',
                onTap: () => Navigator.pushNamed(context, '/dr_degree_ongoing_1'),
              ),
              AcademicOption(
                icon: Icons.school,
                label: 'Degree Completed',
                onTap: _openPostGraduationSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AcademicOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AcademicOption({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: screenWidth * 0.42, // ~42% of screen width
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xffD9D9D9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(2, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: screenWidth * 0.12, color: mainBlue),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04, // Responsive font size
                color: mainBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostGraduationSheet extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final VoidCallback onSave;
  final String? initialValue;

  const _PostGraduationSheet({required this.onChanged, required this.onSave, this.initialValue});

  @override
  State<_PostGraduationSheet> createState() => _PostGraduationSheetState();
}

class _PostGraduationSheetState extends State<_PostGraduationSheet> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  void _onRadioChanged(String? value) {
    setState(() => selectedValue = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: inputBorderClr, width: 1.5)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: const Text('Are you a Post Graduate?', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RadioOption(text: 'Yes', value: 'PG-Holder', groupValue: selectedValue, onChanged: _onRadioChanged),
              const SizedBox(width: 40),
              _RadioOption(text: 'No', value: 'Not-PG-Holder', groupValue: selectedValue, onChanged: _onRadioChanged),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: widget.onSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              backgroundColor: mainBlue,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String text;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({required this.text, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: radioTextStyle),
        Radio<String>(value: value, groupValue: groupValue, activeColor: mainBlue, onChanged: onChanged),
      ],
    );
  }
}

class _OptionBottomSheet extends StatefulWidget {
  final String title;
  final Map<String, String> options;

  const _OptionBottomSheet({required this.title, required this.options});

  @override
  State<_OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<_OptionBottomSheet> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inputBorderClr, width: 1.5)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Text(widget.title, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (selectedValue != null) {
              Navigator.pop(context, widget.options[selectedValue!]);
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