import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';
import '../../widgets/repeated_headings.dart';
import '../../widgets/text_form_fields.dart';

class AfterCountryPreferredPage extends StatefulWidget {
  const AfterCountryPreferredPage({super.key});

  @override
  State<AfterCountryPreferredPage> createState() => _AfterCountryPreferredPageState();
}

class _AfterCountryPreferredPageState extends State<AfterCountryPreferredPage> {
  final _formKey = GlobalKey<FormState>();

  // Data receiving variables (for backend integration)
  final TextEditingController _testScoreController = TextEditingController(); // Language Test Score
  final TextEditingController _certificateController = TextEditingController(); // Certification Names

  String? _selectedCountry; // Preferred Country (Future use)
  String? _clearedTestOption; // Have you cleared any test? Yes/No
  String? _selectedClearedTest; // Selected Cleared Test: IELTS/OET/German
  String? _certificationOptionStatus; // Certification Status: Yes/No
  String? _selectedWorkExpCountry; // Work Experience Country (not shown here)
  String? _workExpYear; // Years of Work Experience (not shown here)
  String? languageTestStatus; // Have you written any language test? Yes/No

  static const List<String> clearedTests = ['IELTS', 'OET', 'German'];

  @override
  void dispose() {
    _testScoreController.dispose();
    _certificateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Preferred Country: $_selectedCountry');
      print('Cleared Test Option: $_clearedTestOption');
      print('Selected Test: $_selectedClearedTest');
      print('Work Exp Option: $_certificationOptionStatus');
      print('Work Exp Country: $_selectedWorkExpCountry');
      print('Years of Experience: $_workExpYear');
      if (_workExpYear == 'more') {
        print('More Work Exp: ${_testScoreController.text}');
      }
      Navigator.pushNamed(context, '/home');
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

    if (!ieltsRegex.hasMatch(input) && !oetRegex.hasMatch(input) && !germanRegex.hasMatch(input)) {
      return 'Enter a valid score (e.g., IELTS 7.0, OET B, B2)';
    }

    return null;
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
                      if (val == 'No') _selectedClearedTest = null;
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
                      if (val == 'No') {
                        _selectedWorkExpCountry = null;
                        _workExpYear = null;
                        _testScoreController.clear();
                      }
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
                    hintText: 'Eg: ACLS',
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
          child: const Text('Continue', style: TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
      ),
    );
  }
}
