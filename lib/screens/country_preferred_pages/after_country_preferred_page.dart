import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';

class AfterCountryPreferredPage extends StatefulWidget {
  const AfterCountryPreferredPage({super.key});

  @override
  State<AfterCountryPreferredPage> createState() =>
      _AfterCountryPreferredPageState();
}

class _AfterCountryPreferredPageState extends State<AfterCountryPreferredPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _testScoreController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  String? userId;
  String? languageTestStatus;
  String? _clearedTestOption;
  String? _selectedClearedTest;
  String? _certificationOptionStatus;

  static const List<String> clearedTests = ['IELTS', 'OET', 'German','PTE'];

  @override
  void initState() {
    super.initState();
    _loadUserIdAndSelections();
  }

  Future<void> _loadUserIdAndSelections() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    // Load previous selections if available
    languageTestStatus = prefs.getString('languageTestStatus');
    _clearedTestOption = prefs.getString('_clearedTestOption');
    _selectedClearedTest = prefs.getString('_selectedClearedTest');
    _testScoreController.text = prefs.getString('_testScoreController') ?? '';
    _certificationOptionStatus = prefs.getString('_certificationOptionStatus');
    _certificateController.text = prefs.getString('_certificateController') ?? '';

    // Fetch latest from API if needed
    if (userId != null) {
      await _fetchUserDetails();
    }

    // Refresh UI after loading
    setState(() {});
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response =
      await http.get(Uri.parse('https://api.joinmeds.in/api/user-details/$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          // Only set if not already loaded from SharedPreferences
          languageTestStatus ??= data['languageTest'];
          _clearedTestOption ??= data['languageTestCleared'] != null ? 'Yes' : 'No';
          _selectedClearedTest ??= data['languageTestCleared']?.split(' ')?.first;
          if (_testScoreController.text.isEmpty) {
            _testScoreController.text =
                data['languageTestCleared']?.split(' ')?.sublist(1).join(' ') ?? '';
          }
          _certificationOptionStatus ??= (data['certification']?.isNotEmpty == true) ? 'Yes' : 'No';
          if (_certificateController.text.isEmpty) {
            _certificateController.text = data['certification'] ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
  }

  Future<void> _saveSelectionsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageTestStatus', languageTestStatus ?? '');
    await prefs.setString('_clearedTestOption', _clearedTestOption ?? '');
    await prefs.setString('_selectedClearedTest', _selectedClearedTest ?? '');
    await prefs.setString('_testScoreController', _testScoreController.text);
    await prefs.setString('_certificationOptionStatus', _certificationOptionStatus ?? '');
    await prefs.setString('_certificateController', _certificateController.text);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _saveSelectionsLocally();

      final clearedTestFinal = _clearedTestOption == 'Yes'
          ? "${_selectedClearedTest ?? ''} ${_testScoreController.text.trim()}"
          : '';
      final certificationFinal = _certificationOptionStatus == 'Yes'
          ? _certificateController.text.trim()
          : '';

      final body = {
        "userId": userId ?? '',
        "languageTest": languageTestStatus ?? '',
        "languageTestCleared": clearedTestFinal,
        "certification": certificationFinal
      };

      try {
        final response = await http.put(
          Uri.parse(
              'https://api.joinmeds.in/api/user-details/update/$userId?userId=$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          Navigator.pushNamed(context, '/success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update. Code: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
            backgroundColor: Colors.red,
          ),
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
      ),
      hintText: hintText,
      initialSelection: value,
      textStyle: hintStyle,
      onSelected: onChanged,
      dropdownMenuEntries:
      items.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
    );
  }

  Widget _buildRadioGroup({
    required String? groupValue,
    required void Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['Yes', 'No'].map((option) {
        return Row(
          children: [
            Text(option, style: radioTextStyle),
            Radio<String>(
              value: option,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ],
        );
      }).toList(),
    );
  }

  String? validateLanguageTestScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your language test score';
    }
    final input = value.trim().toUpperCase();
    final ieltsRegex = RegExp(r'\s*([4-9](\.\d)?)');
    final oetRegex = RegExp(r'\s*[A-C]');
    final germanRegex = RegExp(r'\b(A[1-2]|B[1-2]|C[1-2])\b');

    if (!ieltsRegex.hasMatch(input) &&
        !oetRegex.hasMatch(input) &&
        !germanRegex.hasMatch(input)) {
      return 'Enter a valid score (e.g., IELTS 7.0, OET B, B2)';
    }
    return null;
  }

  @override
  void dispose() {
    _testScoreController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: mainBlue,
        title: const Text('Language & Certification',
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
                const SizedBox(height: spacing + 10),
                const LabelText(labelText: 'Have you written any language test?'),
                const SizedBox(height: 5),
                _buildRadioGroup(
                  groupValue: languageTestStatus,
                  onChanged: (val) => setState(() => languageTestStatus = val),
                ),
                const SizedBox(height: spacing),
                const LabelText(labelText: 'Have you cleared any language test?'),
                const SizedBox(height: 5),
                _buildRadioGroup(
                  groupValue: _clearedTestOption,
                  onChanged: (val) {
                    setState(() {
                      _clearedTestOption = val;
                      if (val == 'No') {
                        _selectedClearedTest = null;
                        _testScoreController.clear();
                      }
                    });
                  },
                ),
                if (_clearedTestOption == 'Yes') ...[
                  const SizedBox(height: spacing),
                  const LabelText(labelText: 'Specify the Test Cleared'),
                  const SizedBox(height: 5),
                  _buildDropdown(
                    hintText: 'Select Test',
                    items: clearedTests,
                    value: _selectedClearedTest,
                    onChanged: (val) => setState(() => _selectedClearedTest = val),
                  ),
                  const SizedBox(height: 10),
                  const LabelText(labelText: 'Score Obtained'),
                  const SizedBox(height: 5),
                  TextFormWidget(
                    controller: _testScoreController,
                    validator: validateLanguageTestScore,
                    keyboardType: TextInputType.text,
                    hintText: 'Eg: IELTS 7.5, OET B, B2 German',
                    obscureText: false,
                  ),
                ],
                const SizedBox(height: spacing),
                const LabelText(labelText: 'Have you done any certifications?'),
                const SizedBox(height: 5),
                _buildRadioGroup(
                  groupValue: _certificationOptionStatus,
                  onChanged: (val) {
                    setState(() {
                      _certificationOptionStatus = val;
                      if (val == 'No') _certificateController.clear();
                    });
                  },
                ),
                if (_certificationOptionStatus == 'Yes') ...[
                  const SizedBox(height: spacing),
                  const LabelText(labelText: 'Mention your certifications'),
                  const SizedBox(height: 5),
                  TextFormWidget(
                    controller: _certificateController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 3) {
                        return 'Please enter at least 3 characters';
                      }
                      if (!RegExp(r"^[a-zA-Z\s]+").hasMatch(value)) {
                        return 'Invalid characters';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    hintText: 'Eg: ACLS, BLS',
                    obscureText: false,
                  ),
                ],
                const SizedBox(height: spacing),
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
