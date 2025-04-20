import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';
import 'package:untitled/widgets/main_button.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import 'package:untitled/widgets/text_form_fields.dart';

class AboutOrganisation extends StatefulWidget {
  const AboutOrganisation({super.key});

  @override
  _AboutOrganisationState createState() => _AboutOrganisationState();
}

class _AboutOrganisationState extends State<AboutOrganisation> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _aboutOrgController = TextEditingController();
  final _hiringForController = TextEditingController();
  final _yearExpController = TextEditingController();
  final _skillsReqController = TextEditingController();
  final _salaryFromController = TextEditingController();
  final _salaryToController = TextEditingController();
  final _jobDescController = TextEditingController();

  final _wordCount = ValueNotifier<int>(0);
  final _wordCount2 = ValueNotifier<int>(0);

  static const int _maxWords = 250;
  static const int _maxWords2 = 450;

  String _selectedSymbol = '₹';
  final List<String> _moneySymbols = ['\$', '€', '£', '₹', 'SAR', 'AED', 'QAR', 'KWD', 'BHD'];

  // Helper Methods
  int _countWords(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  void _onTextChanged(String text, ValueNotifier<int> counter) {
    counter.value = _countWords(text);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool isMultiline = false,
    ValueNotifier<int>? wordCounter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(labelText: label),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? null : 1,
          keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
          validator: validator,
          onChanged: wordCounter != null ? (text) => _onTextChanged(text, wordCounter) : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: focusedErrorBorder,
            hintText: hintText,
            hintStyle: hintStyle,
          ),
        ),
        if (wordCounter != null)
          ValueListenableBuilder<int>(
            valueListenable: wordCounter,
            builder: (context, count, _) => Text(
              "Word count: $count / ${wordCounter == _wordCount ? _maxWords : _maxWords2}",
              style: TextStyle(color: count > (wordCounter == _wordCount ? _maxWords : _maxWords2) ? Colors.red : Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  void dispose() {
    _aboutOrgController.dispose();
    _hiringForController.dispose();
    _yearExpController.dispose();
    _skillsReqController.dispose();
    _salaryFromController.dispose();
    _salaryToController.dispose();
    _jobDescController.dispose();
    _wordCount.dispose();
    _wordCount2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "About Organisation",
          style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
        ),
        backgroundColor: mainBlue,
      ),
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'About your company/organisation',
                  controller: _aboutOrgController,
                  hintText: 'Specify less than (250 words)',
                  validator: (value) => (value == null || _countWords(value) < 50) ? 'At least 50 words required' : null,
                  isMultiline: true,
                  wordCounter: _wordCount,
                ),
                _buildTextField(
                  label: 'Job Hiring For',
                  controller: _hiringForController,
                  hintText: 'Eg: Nurse',
                  validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
                ),
                _buildTextField(
                  label: 'Year Of Experience',
                  controller: _yearExpController,
                  hintText: 'Eg: Fresher, 1 year, etc...',
                  validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
                ),
                _buildTextField(
                  label: 'Skills Required',
                  controller: _skillsReqController,
                  hintText: 'Eg: OT, NICU, Surgeon...',
                  validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LabelText(labelText: 'Pay'),
                    DropdownButton<String>(
                      value: _selectedSymbol,
                      items: _moneySymbols.map((symbol) {
                        return DropdownMenuItem(value: symbol, child: Text(symbol, style: const TextStyle(fontSize: 20)));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedSymbol = value!),
                    ),
                  ],
                ),
                _buildTextField(
                  label: 'From',
                  controller: _salaryFromController,
                  hintText: 'Eg: 15,000',
                  validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
                ),
                _buildTextField(
                  label: 'To',
                  controller: _salaryToController,
                  hintText: 'Eg: 30,000',
                  validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
                ),
                _buildTextField(
                  label: 'Job Description',
                  controller: _jobDescController,
                  hintText: 'Specify less than (450 words)',
                  validator: (value) => (value == null || _countWords(value) < 50) ? 'At least 50 words required' : null,
                  isMultiline: true,
                  wordCounter: _wordCount2,
                ),
                const SizedBox(height: 40),
                MainButton(
                  text: 'Submit',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
