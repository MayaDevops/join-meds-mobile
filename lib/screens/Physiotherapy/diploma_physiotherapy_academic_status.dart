import 'package:flutter/material.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class DiplomaPhysiotherapyAcademicStatus extends StatefulWidget {
  const DiplomaPhysiotherapyAcademicStatus({super.key});

  @override
  State<DiplomaPhysiotherapyAcademicStatus> createState() => _DiplomaPhysiotherapyAcademicStatusState();
}

class _DiplomaPhysiotherapyAcademicStatusState extends State<DiplomaPhysiotherapyAcademicStatus> {
  String? internshipStatus;

  void _handleSubmit() async {
    if (internshipStatus == null) {
      _showSnackBar('Please select your internship status');
      return;
    }

    if (internshipStatus == 'Internship-Yes') {
      Navigator.pushNamed(context, '/gn_nurse_internship_completed');
    } else {
      final workExperience = await _showOptionBottomSheet(
        title: 'Do you have any Work Experience?',
        options: {
          'Work Experience-Yes': 'Yes',
          'Work Experience-No': 'No',
        },
      );

      if (workExperience == 'Work Experience-Yes') {
        Navigator.pushNamed(context, '/nurse_work_experience');
      } else if (workExperience == 'Work Experience-No') {
        Navigator.pushNamed(context, '/County_that_you_preferred_page');
      }
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
      builder: (_) => _RadioSelectionSheet(
        title: title,
        options: options,
        onSave: (value) => Navigator.pop(context, value),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openInternshipSheet() {
    _showOptionBottomSheet(
      title: 'Do you have Internship?',
      options: {
        'Internship-Yes': 'Yes',
        'Internship-No': 'No',
      },
    ).then((value) {
      if (value != null) {
        setState(() => internshipStatus = value);
        _handleSubmit();
      }
    });
  }

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
          FormsMainHead(text: 'DPT'),
          const Text(
            'Please select your academic status 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: inputBorderClr),
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AcademicOption(
                icon: Icons.menu_book,
                label: 'Diploma Ongoing',
                onTap: () => Navigator.pushNamed(context, '/dpt_diploma_ongoing'),
              ),
              _AcademicOption(
                icon: Icons.school,
                label: 'Diploma Completed',
                onTap: _openInternshipSheet,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcademicOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AcademicOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xffD9D9D9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: mainBlue),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 18, color: mainBlue, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioSelectionSheet extends StatefulWidget {
  final String title;
  final Map<String, String> options;
  final ValueChanged<String> onSave;

  const _RadioSelectionSheet({
    required this.title,
    required this.options,
    required this.onSave,
  });

  @override
  State<_RadioSelectionSheet> createState() => _RadioSelectionSheetState();
}

class _RadioSelectionSheetState extends State<_RadioSelectionSheet> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 70,
                children: widget.options.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.value, style: radioTextStyle),
                      Radio<String>(
                        value: entry.key,
                        groupValue: selectedValue,
                        activeColor: mainBlue,
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
                  widget.onSave(selectedValue!);
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
        ),
      ),
    );
  }
}
