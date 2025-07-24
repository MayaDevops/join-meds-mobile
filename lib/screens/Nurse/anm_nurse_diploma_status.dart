import 'package:flutter/material.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class AnmNurseDiplomaAcademicStatus extends StatefulWidget {
  const AnmNurseDiplomaAcademicStatus({super.key});

  @override
  State<AnmNurseDiplomaAcademicStatus> createState() => _AnmNurseDiplomaAcademicStatusState();
}

class _AnmNurseDiplomaAcademicStatusState extends State<AnmNurseDiplomaAcademicStatus> {
  String? internshipStatus;

  void _handleSubmit() async {
    if (internshipStatus == null) {
      _showSnackBar('Please select your internship status', Colors.red);
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

      if (workExperience == null) return;

      if (workExperience == 'Work Experience-No') {
        Navigator.pushNamed(context, '/County_that_you_preferred_page');
      } else if(workExperience == 'Work Experience-Yes'){
        Navigator.pushNamed(context, '/nurse_work_experience');
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPostGraduationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _RadioSelectionSheet(
        title: 'Do you have Internship?',
        options: {
          'Internship-Yes': 'Yes',
          'Internship-No': 'No',
        },
        onSave: (value) {
          setState(() => internshipStatus = value);
          _handleSubmit();
        },
      ),
    );
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
          FormsMainHead(text: 'Auxiliary Nursing Midwifery'),
          const Text(
            'Please select your academic status 🎓',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: inputBorderClr,
            ),
          ),
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AcademicOption(
                icon: Icons.menu_book,
                label: 'Diploma Ongoing',
                onTap: () => Navigator.pushNamed(context, '/anm_nurse_diploma_ongoing'),
              ),
              AcademicOption(
                icon: Icons.school,
                label: 'Diploma Completed',
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Text(widget.title, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
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
