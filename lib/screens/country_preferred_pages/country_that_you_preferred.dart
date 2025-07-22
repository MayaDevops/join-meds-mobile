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
  State<CountryThatYouPreferred> createState() => _CountryThatYouPreferredState();
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
   "India", "United States", "United Kingdom","Canada","Ireland"];
  static const List<String> clearedTests = ['DHA', 'MOH', 'HAD'];
  static const List<String> years = ['1 Year', '2 Years', '3 Years', '4 Years', '5 Years', 'more'];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();
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
      final response = await http.get(Uri.parse('https://api.joinmeds.in/api/user-details/$userId?userId=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _preferredCountry = data['countryPreffered'];
          _hasClearedTest = data['foreignTest'];
          _clearedTestName = data['foreignTestDetails'];
          _hasForeignWorkExperience = data['foreignCountryExp'];
          _workExperienceCountry = data['foreignCountryWorked']?.split(' - ')?.first;
          _workExperienceDuration = data['foreignCountryWorkExp']?.split(' - ')?.last;
          if (_workExperienceDuration == 'more') {
            _moreExperienceDetails.text = data['workExperience']?.split(':')?.last ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
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
          Uri.parse('https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(formData),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          Navigator.pushNamed(context, '/after_County_preferred_page');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update. Code: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDropdown({
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
      onSelected: onChanged,
      dropdownMenuEntries: items.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
    );
  }

  Widget _buildRadioGroup({
    required String? groupValue,
    required void Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Yes', 'No'].map((option) => Row(
        children: [
          Text(option, style: radioTextStyle),
          Radio<String>(value: option, groupValue: groupValue, onChanged: onChanged),
        ],
      )).toList(),
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
                        onChanged: (value) => setState(() => _workExperienceDuration = value),
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
                return 'Please enter at least 5 characters';
              }
              if (!RegExp(r"^[a-zA-Z0-9\s,.-]+$").hasMatch(value)) {
                return 'Invalid characters';
              }
              return null;
            },
            keyboardType: TextInputType.text,
            hintText: 'Eg: 6, 7, etc.',
            obscureText: false,
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: mainBlue,
        title: const Text('Preferred Country', style: TextStyle(color: Colors.white)),
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
                _buildDropdown(
                  hintText: 'Select Country',
                  items: countries,
                  value: _preferredCountry,
                  onChanged: (val) => setState(() => _preferredCountry = val),
                ),
                const SizedBox(height: 20),
                const LabelText(labelText: 'Have you Cleared any Foreign Test?'),
                const SizedBox(height: 5),
                _buildRadioGroup(
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
                  _buildDropdown(
                    hintText: 'Select Test',
                    items: clearedTests,
                    value: _clearedTestName,
                    onChanged: (val) => setState(() => _clearedTestName = val),
                  ),
                ],
                const SizedBox(height: 20),
                const LabelText(labelText: 'Do you have Work Experience in any Foreign Countries?'),
                const SizedBox(height: 5),
                _buildRadioGroup(
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
                  _buildDropdown(
                    hintText: 'Select Country',
                    items: countries,
                    value: _workExperienceCountry,
                    onChanged: (val) => setState(() => _workExperienceCountry = val),
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
          child: const Text('Continue', style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
      ),
    );
  }
}
