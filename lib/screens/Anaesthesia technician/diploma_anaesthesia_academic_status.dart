import 'package:flutter/material.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class DiplomaAnaesthesiaTechAcademicStatus extends StatefulWidget {
  const DiplomaAnaesthesiaTechAcademicStatus({super.key});

  @override
  State<DiplomaAnaesthesiaTechAcademicStatus> createState() =>
      _DiplomaAnaesthesiaTechAcademicStatusState();
}

class _DiplomaAnaesthesiaTechAcademicStatusState
    extends State<DiplomaAnaesthesiaTechAcademicStatus> {
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
          FormsMainHead(text: 'DAT'),
          const Text(
            'Please select your academic status 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: inputBorderClr),
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AcademicOption(
                icon: Icons.menu_book,
                label: 'Diploma Ongoing',
                onTap: () =>
                    Navigator.pushNamed(context, '/dat_diploma_ongoing'),
              ),
              AcademicOption(
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: inputBorderClr, width: 1.5)),
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
                        onChanged: (value) =>
                            setState(() => selectedValue = value),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewPadding.bottom + 20,
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedValue != null) {
                    widget.onSave(selectedValue!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an option',
                            textAlign: TextAlign.center),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  padding: const EdgeInsets.all(15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
