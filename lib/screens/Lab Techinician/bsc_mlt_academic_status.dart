import 'package:flutter/material.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class BScMLTAcademicStatus extends StatefulWidget {
  const BScMLTAcademicStatus({super.key});

  @override
  State<BScMLTAcademicStatus> createState() => _BScMLTAcademicStatusState();
}

class _BScMLTAcademicStatusState extends State<BScMLTAcademicStatus> {
  String? postGraduation;

  void _handleSubmit() async {
    if (postGraduation == null) {
      _showSnackBar('Please select a profession', Colors.red);
      return;
    }

    if (postGraduation == 'PG-Holder') {
      final phdStatus = await _showOptionBottomSheet(
        title: 'Are you a PhD holder?',
        options: const {
          'PhD Holder': 'Yes',
          'Not-PhD Holder': 'No',
          'PhD Ongoing': 'Ongoing',
        },
      );

      if (phdStatus == null) return;
    }

    await _handleInternshipAndWorkFlow();
  }

  Future<void> _handleInternshipAndWorkFlow() async {
    final internshipStatus = await _showOptionBottomSheet(
      title: 'Do you have any Internship?',
      options: const {
        'Internship-Yes': 'Yes',
        'Internship-No': 'No',
      },
    );

    if (internshipStatus == null) return;

    if (internshipStatus == 'Internship-No') {
      final workExpStatus = await _showOptionBottomSheet(
        title: 'Do you have any Work Experience?',
        options: const {
          'Work Experience-Yes': 'Yes',
          'Work Experience-No': 'No',
        },
      );

      if (workExpStatus == null) return;

      _navigateBasedOnExperience(workExpStatus);
    } else {
      _navigateToInternshipCompleted();
    }
  }

  void _navigateBasedOnExperience(String experienceStatus) {
    if (experienceStatus == 'Work Experience-No') {
      Navigator.pushNamed(context, '/County_that_you_preferred_page');
    } else {
      _navigateToInternshipCompleted();
    }
  }

  void _navigateToInternshipCompleted() {
    Navigator.pushNamed(context, '/pharmacist_work_experience');
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
      builder: (_) {
        String? selectedValue = postGraduation;
        return StatefulBuilder(
          builder: (context, setStateSheet) => Column(
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
                child: const Text('Are you a Post Graduate?', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RadioOption(
                    text: 'Yes',
                    value: 'PG-Holder',
                    groupValue: selectedValue,
                    onChanged: (val) {
                      setStateSheet(() => selectedValue = val);
                      setState(() => postGraduation = val);
                    },
                  ),
                  const SizedBox(width: 70),
                  _RadioOption(
                    text: 'No',
                    value: 'Not-PG-Holder',
                    groupValue: selectedValue,
                    onChanged: (val) {
                      setStateSheet(() => selectedValue = val);
                      setState(() => postGraduation = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleSubmit();
                },
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
      },
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
          FormsMainHead(text: 'Bsc MLT'),
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
                label: 'Degree Ongoing',
                onTap: () => Navigator.pushNamed(context, '/bsc_mlt_degree_ongoing'),
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

class _RadioOption extends StatelessWidget {
  final String text;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: radioTextStyle),
        Radio<String>(
          value: value,
          groupValue: groupValue,
          activeColor: mainBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _OptionBottomSheet extends StatelessWidget {
  final String title;
  final Map<String, String> options;

  const _OptionBottomSheet({
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedValue;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: inputBorderClr, width: 1.5)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Text(title, style: const TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              children: options.entries.map((entry) {
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
          ElevatedButton(
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}