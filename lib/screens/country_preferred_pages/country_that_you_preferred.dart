import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';

class CountryThatYouPreferred extends StatefulWidget {
  const CountryThatYouPreferred({super.key});

  @override
  State<CountryThatYouPreferred> createState() =>
      _CountryThatYouPreferredState();
}

class _CountryThatYouPreferredState extends State<CountryThatYouPreferred> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _moreExperienceDetails = TextEditingController();
  String? userId;

  // Submitted Data
  String? _preferredCountry;
  String? _hasClearedTest;
  String? _clearedTestName;
  String? _hasForeignWorkExperience;
  String? _workExperienceCountry;
  String? _workExperienceDuration;

  static const List<String> countries = [
    "United Kingdom (UK)",
    "Germany",
    "Ireland",
    "Australia",
    "Canada",
    "United States (USA)",
    "New Zealand",
    "United Arab Emirates (UAE)",
    "Saudi Arabia",
    "Qatar",
    "Oman",
    "Kuwait",
    "Singapore",
    "Norway",
    "Sweden",
    "Italy",
    "Finland",
    "France",
    "Japan",
    "Malta",
    "South Africa",
    "Malaysia",
    "Denmark",
    "Switzerland",
    "Netherlands",
    "Belgium",
    "Spain",
    "Portugal",
    "Austria",
    "Czech Republic",
    "Poland",
    "Hungary",
    "Lithuania",
    "Luxembourg",
    "Bahrain",
    "Jordan",
    "Turkey",
    "China",
    "South Korea",
    "Thailand",
    "Philippines",
    "Indonesia",
    "Vietnam",
    "Brunei",
    "Mauritius",
    "Fiji",
    "Trinidad and Tobago",
    "Jamaica",
    "Guyana"
  ];
  static const List<String> clearedTests = ['DHA', 'MOH', 'HAAD'];
  static const List<String> years = [
    '1 Year',
    '2 Years',
    '3 Years',
    '4 Years',
    '5 Years',
    'more'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();
    _loadPreferences();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      await _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.joinmeds.in/api/user-details/$userId?userId=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _preferredCountry ??= data['countryPreffered'];
          _hasClearedTest ??= data['foreignTest'];
          _clearedTestName ??= data['foreignTestDetails'];
          _hasForeignWorkExperience ??= data['foreignCountryExp'];
          _workExperienceCountry ??=
              data['foreignCountryWorked']?.split(' - ')?.first;
          _workExperienceDuration ??=
              data['foreignCountryWorkExp']?.split(' - ')?.last;
          if (_workExperienceDuration == 'more') {
            _moreExperienceDetails.text =
                data['workExperience']?.split(':')?.last ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _preferredCountry = prefs.getString('preferredCountry') ?? _preferredCountry;
      _hasClearedTest = prefs.getString('hasClearedTest') ?? _hasClearedTest;
      _clearedTestName = prefs.getString('clearedTestName') ?? _clearedTestName;
      _hasForeignWorkExperience = prefs.getString('hasForeignWorkExperience') ?? _hasForeignWorkExperience;
      _workExperienceCountry = prefs.getString('workExperienceCountry') ?? _workExperienceCountry;
      _workExperienceDuration = prefs.getString('workExperienceDuration') ?? _workExperienceDuration;
      _moreExperienceDetails.text = prefs.getString('moreExperienceDetails') ?? _moreExperienceDetails.text;
    });
  }

  Future<void> _saveToPrefs(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save selections locally
      await _saveToPrefs('preferredCountry', _preferredCountry);
      await _saveToPrefs('hasClearedTest', _hasClearedTest);
      await _saveToPrefs('clearedTestName', _clearedTestName);
      await _saveToPrefs('hasForeignWorkExperience', _hasForeignWorkExperience);
      await _saveToPrefs('workExperienceCountry', _workExperienceCountry);
      await _saveToPrefs('workExperienceDuration', _workExperienceDuration);
      await _saveToPrefs('moreExperienceDetails', _moreExperienceDetails.text);

      final formData = {
        "countryPreffered": _preferredCountry,
        "foreignTest": _hasClearedTest,
        "foreignTestDetails": _clearedTestName,
        "foreignCountryWorkExp": _hasForeignWorkExperience,
        "foreignCountryWorked": _hasForeignWorkExperience == 'Yes'
            ? "${_workExperienceCountry ?? ''} - ${_workExperienceDuration ?? ''}${_workExperienceDuration == 'more' ? ": ${_moreExperienceDetails.text}" : ''}"
            : null,
        "userId": userId
      };

      try {
        final response = await http.put(
          Uri.parse(
              'https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          Navigator.pushNamed(context, '/after_County_preferred_page');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update. Code: ${response.statusCode}'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget buildPersistentDropdown({
    required String keyName,
    required String hintText,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return DropdownMenu<String>(
      width: double.infinity,
      requestFocusOnTap: true,
      enableSearch: true,
      enableFilter: true,
      keyboardType: TextInputType.text,
      menuStyle: const MenuStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(200)),
      ),
      hintText: hintText,
      initialSelection: value,
      textStyle: hintStyle,
      onSelected: (val) {
        onChanged(val);
        _saveToPrefs(keyName, val);
      },
      dropdownMenuEntries:
      items.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
    );
  }

  Widget buildPersistentRadioGroup({
    required String keyName,
    required String? groupValue,
    required void Function(String?) onChanged,
    List<String> options = const ['Yes', 'No'],
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options
          .map((option) => Row(
        children: [
          Text(option, style: radioTextStyle),
          Radio<String>(
              value: option,
              groupValue: groupValue,
              onChanged: (val) {
                onChanged(val);
                _saveToPrefs(keyName, val);
              }),
        ],
      ))
          .toList(),
    );
  }

  Widget _buildExperienceOptions() {
    return Column(
      children: [
        for (int i = 0; i < years.length; i += 2)
          Row(
            children: [
              for (int j = 0; j < 2 && i + j < years.length; j++)
                Container(
                  width: 150,
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    children: [
                      Text(years[i + j], style: radioTextStyle),
                      Radio<String>(
                        value: years[i + j],
                        groupValue: _workExperienceDuration,
                        onChanged: (value) {
                          setState(() => _workExperienceDuration = value);
                          _saveToPrefs('workExperienceDuration', value);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        if (_workExperienceDuration == 'more') ...[
          const SizedBox(height: 20),
          const LabelText(labelText: 'Specify Years of Experience'),
          const SizedBox(height: 5),
          TextFormWidget(
            controller: _moreExperienceDetails,
            validator: (value) {
              if (value == null || value.isEmpty || value.isEmpty) {
                return 'Please enter at least 1 character';
              }
              if (!RegExp(r"^[a-zA-Z0-9\s,.-]+$").hasMatch(value)) {
                return 'Invalid characters';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            hintText: 'Eg: 6, 7, etc.',
            obscureText: false,
            onChanged: (val) => _saveToPrefs('moreExperienceDetails', val),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _moreExperienceDetails.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: mainBlue,
        title: const Text('Preferred Country',
            style: TextStyle(color: Colors.white)),
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                const LabelText(labelText: 'Country you prefer to work'),
                const SizedBox(height: 5),
                buildPersistentDropdown(
                  keyName: 'preferredCountry',
                  hintText: 'Select Country',
                  items: countries,
                  value: _preferredCountry,
                  onChanged: (val) => setState(() => _preferredCountry = val),
                ),
                const SizedBox(height: 20),
                const LabelText(labelText: 'Have you Cleared any Foreign Test?'),
                const SizedBox(height: 5),
                buildPersistentRadioGroup(
                  keyName: 'hasClearedTest',
                  groupValue: _hasClearedTest,
                  onChanged: (val) {
                    setState(() {
                      _hasClearedTest = val;
                      if (val == 'No') _clearedTestName = null;
                    });
                  },
                ),
                if (_hasClearedTest == 'Yes') ...[
                  const SizedBox(height: 20),
                  const LabelText(labelText: 'Specify the Test Cleared'),
                  const SizedBox(height: 5),
                  buildPersistentDropdown(
                    keyName: 'clearedTestName',
                    hintText: 'Select Test',
                    items: clearedTests,
                    value: _clearedTestName,
                    onChanged: (val) => setState(() => _clearedTestName = val),
                  ),
                ],
                const SizedBox(height: 20),
                const LabelText(
                    labelText:
                    'Do you have Work Experience in any Foreign Countries?'),
                const SizedBox(height: 5),
                buildPersistentRadioGroup(
                  keyName: 'hasForeignWorkExperience',
                  groupValue: _hasForeignWorkExperience,
                  onChanged: (val) {
                    setState(() {
                      _hasForeignWorkExperience = val;
                      if (val == 'No') {
                        _workExperienceCountry = null;
                        _workExperienceDuration = null;
                        _moreExperienceDetails.clear();
                      }
                    });
                  },
                ),
                if (_hasForeignWorkExperience == 'Yes') ...[
                  const SizedBox(height: 20),
                  const LabelText(labelText: 'Which Country did you Work?'),
                  const SizedBox(height: 5),
                  buildPersistentDropdown(
                    keyName: 'workExperienceCountry',
                    hintText: 'Select Country',
                    items: countries,
                    value: _workExperienceCountry,
                    onChanged: (val) =>
                        setState(() => _workExperienceCountry = val),
                  ),
                  const SizedBox(height: 20),
                  const LabelText(labelText: 'Years of experience'),
                  const SizedBox(height: 5),
                  _buildExperienceOptions(),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ElevatedButton(
          onPressed: _submit,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(mainBlue),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          child: const Text('Continue',
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
      ),
    );
  }
}
