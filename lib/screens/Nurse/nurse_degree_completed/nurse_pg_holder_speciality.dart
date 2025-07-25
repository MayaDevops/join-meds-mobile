import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants/constant.dart';
import '../../../../widgets/repeated_headings.dart';

class SelectingNurseSpeciality extends StatefulWidget {
  const SelectingNurseSpeciality({super.key});

  @override
  State<SelectingNurseSpeciality> createState() => _SelectingNurseSpecialityState();
}

class _SelectingNurseSpecialityState extends State<SelectingNurseSpeciality> {
  String? _selectedSpeciality;
  String? userId;
  bool isLoading = true;

  final List<String> _nurseSpecialities = [
    'Medical Surgical',
    'Psychiatry',
    'Community Nursing',
    'Child Health / Pediatrics',
    'Obstetric and Gynaecological Nursing',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchSpeciality();
  }

  Future<void> _loadUserIdAndFetchSpeciality() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    print('userId=$userId');

    if (userId != null) {
      final url = Uri.parse("https://api.joinmeds.in/api/user-details/$userId?userId=$userId");
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _selectedSpeciality = data['speciality'];
            isLoading = false;
          });
        } else {
          _showSnackBar('Failed to fetch user data');
          setState(() => isLoading = false);
        }
      } catch (e) {
        _showSnackBar('Error: $e');
        setState(() => isLoading = false);
      }
    }
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

    final body = jsonEncode({
      "userId": userId,
      "speciality": _selectedSpeciality,
    });

    final response = await http.put(
      Uri.parse("https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId"),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackBar('Speciality saved: $_selectedSpeciality', color: Colors.green);
      await _handleNextSteps();
    } else {
      _showSnackBar('Failed to update speciality');
    }
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
          ? '/County_that_you_preferred_page'
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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10),),),
          ),
          child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
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
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewPadding.bottom + 20,
          ),
          child: ElevatedButton(
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10),),),
            ),
            child: const Text('Save', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

