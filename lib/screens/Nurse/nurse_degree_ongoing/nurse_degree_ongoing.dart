import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constant.dart';

class NurseDegreeOngoing extends StatefulWidget {
  const NurseDegreeOngoing({super.key});

  @override
  State<NurseDegreeOngoing> createState() => _NurseDegreeOngoingState();
}

class _NurseDegreeOngoingState extends State<NurseDegreeOngoing> {
  final TextEditingController _universityController = TextEditingController();
  String? _university;
  String? academicYear;
  String? userId;

  final List<String> academicYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  final List<String> universities = [
    'AIIMS, New Delhi',
    'Christian Medical College, Vellore',
    'Kasturba Medical College, Manipal',
    'Amrita School of Medicine, Kochi',
    'JIPMER, Puducherry',
    'Sri Ramachandra Medical College, Chennai',
    'St. Johns Medical College, Bangalore',
    'Madras Medical College, Chennai',
    'Lady Hardinge Medical College, New Delhi',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      await _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.joinmeds.in/api/user-details/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          academicYear = data['currentYear'];
          _university = data['university'];
          _universityController.text = data['university'] ?? '';
        });
      } else {
        debugPrint('User details not found or error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  Future<void> updateUserDetails() async {
    final universityFinal = _university ?? _universityController.text;

    final url = Uri.parse(
        'https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId');

    final body = {
      "currentYear": academicYear ?? "",
      "university": universityFinal,
      "userId": userId ?? "",
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pushNamed(context, '/County_that_you_preferred_page');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildRadioOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          activeColor: mainBlue,
          value: value,
          groupValue: academicYear,
          onChanged: (val) => setState(() => academicYear = val),
        ),
        Text(value, style: radioTextStyle),
      ],
    );
  }

  @override
  void dispose() {
    _universityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("BSc Nursing", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose Your Current Year',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 30,
              runSpacing: 10,
              children: academicYears.map(buildRadioOption).toList(),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'University of Education',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 15),
            DropdownMenu<String>(
              controller: _universityController,
              requestFocusOnTap: true,
              enableSearch: true,
              enableFilter: true,
              keyboardType: TextInputType.text,
              hintText: 'Select University of Education',
              textStyle: hintStyle,
              onSelected: (value) => setState(() => _university = value),
              dropdownMenuEntries: universities
                  .toSet()
                  .map((university) =>
                  DropdownMenuEntry(value: university, label: university))
                  .toList(),
              menuStyle: const MenuStyle(
                fixedSize: WidgetStatePropertyAll(Size.fromHeight(300)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          FocusScope.of(context).unfocus();

          final selectedUniversity =
              _university ?? _universityController.text.trim();

          if ((academicYear ?? "").isNotEmpty &&
              selectedUniversity.isNotEmpty &&
              userId != null) {
            _university = selectedUniversity;
            updateUserDetails();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                Text('Please select both current year and university.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
          backgroundColor: const WidgetStatePropertyAll(mainBlue),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }
}
