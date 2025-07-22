import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class NurseAcademicStatus extends StatefulWidget {
  const NurseAcademicStatus({super.key});

  @override
  State<NurseAcademicStatus> createState() => _NurseAcademicStatusState();
}

class _NurseAcademicStatusState extends State<NurseAcademicStatus> {
  String? postGraduation;
  String? userId;
  String? profession;
  String academicStatus = 'Degree Completed';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetch();
  }

  Future<void> _loadUserIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    profession = prefs.getString('profession') ?? 'Nurse';

    if (userId != null) {
      final url = Uri.parse("https://api.joinmeds.in/api/user-details/$userId?userId=$userId");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            academicStatus = data['academicStatus'] ?? 'Degree Completed';
            postGraduation = data['pgStatus'];
            isLoading = false;
          });
        } else {
          _showSnackBar('Failed to fetch user data', Colors.red);
          setState(() => isLoading = false);
        }
      } catch (e) {
        _showSnackBar('Error: $e', Colors.red);
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _updateStatusAndNavigate(String status) async {
    academicStatus = status;

    final Map<String, dynamic> requestData = {
      "academicStatus": academicStatus,
      "pgStatus": postGraduation,
      "userId": userId
    };

    final response = await http.put(
      Uri.parse("https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (status == 'Degree Ongoing') {
        Navigator.pushNamed(context, '/nurse_degree_ongoing');
      } else if (status == 'Degree Completed') {
        _openPostGraduationSheet();
      }
    } else {
      _showSnackBar('Failed to update academic status', Colors.red);
    }
  }

  void _handleSubmit() async {
    if (postGraduation == null) {
      _showSnackBar('Please select post-graduation status', Colors.red);
      return;
    }

    final Map<String, dynamic> requestData = {
      "academicStatus": academicStatus,
      "pgStatus": postGraduation,
      "userId": userId
    };

    final response = await http.put(
      Uri.parse("https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      _showSnackBar('Failed to update details', Colors.red);
      return;
    }

    if (postGraduation == 'PG-Holder') {
      Navigator.pushNamed(context, '/nurse_pg_holder_speciality');
    } else {
      final workExpStatus = await _showOptionBottomSheet(
        title: 'Do you have any Work Experience?',
        options: {
          'Work Experience-Yes': 'Yes',
          'Work Experience-No': 'No',
        },
      );

      if (workExpStatus == null) return;

      if (workExpStatus == 'Work Experience-No') {
        Navigator.pushNamed(context, '/County_that_you_preferred_page');
      } else if(workExpStatus == 'Work Experience-Yes') {
        Navigator.pushNamed(context, '/work_experience');
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
      builder: (_) => _PostGraduationSheet(
        initialValue: postGraduation,
        onChanged: (value) => setState(() => postGraduation = value),
        onSave: _handleSubmit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Academic Status", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          FormsMainHead(text: 'BSc Nursing'),
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
              _AcademicOption(
                icon: Icons.menu_book,
                label: 'Degree Ongoing',
                onTap: () => _updateStatusAndNavigate('Degree Ongoing'),
              ),
              _AcademicOption(
                icon: Icons.school,
                label: 'Degree Completed',
                onTap: () => _updateStatusAndNavigate('Degree Completed'),
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
              style: const TextStyle(
                fontSize: 18,
                color: mainBlue,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostGraduationSheet extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final VoidCallback onSave;

  const _PostGraduationSheet({
    required this.onChanged,
    required this.onSave,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedValue = initialValue;

    return StatefulBuilder(
      builder: (context, setState) => SafeArea(
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
              child: const Text('Are you a Post Graduate?',
                  style: TextStyle(fontSize: 20)),
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
                    setState(() => selectedValue = val);
                    onChanged(val);
                  },
                ),
                const SizedBox(width: 70),
                _RadioOption(
                  text: 'No',
                  value: 'Not-PG-Holder',
                  groupValue: selectedValue,
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                    onChanged(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: mainBlue,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 20, color: Colors.white),
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
              border:
              Border(bottom: BorderSide(color: inputBorderClr, width: 1.5)),
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
                      onChanged: (value) =>
                          setState(() => selectedValue = value),
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
              shape:
              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('Save',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
