import 'package:flutter/material.dart';
import 'package:untitled/constants/constant.dart';
import 'package:untitled/widgets/main_button.dart';
import 'package:untitled/widgets/repeated_headings.dart';

class EditJobOrganisation extends StatefulWidget {
  const EditJobOrganisation({super.key});

  @override
  State<EditJobOrganisation> createState() => _EditJobOrganisationState();
}

class _EditJobOrganisationState extends State<EditJobOrganisation> {
  final _formKey = GlobalKey<FormState>();

  final _controllers = {
    'aboutOrg': TextEditingController(),
    'location': TextEditingController(),
    'hiringFor': TextEditingController(),
    'experience': TextEditingController(),
    'skills': TextEditingController(),
    'salaryFrom': TextEditingController(),
    'salaryTo': TextEditingController(),
    'jobDesc': TextEditingController(),
  };

  final _wordCount = ValueNotifier<int>(0);
  final _wordCount2 = ValueNotifier<int>(0);

  String _selectedSymbol = '₹';
  String _selectedUnit = '/hour';

  final _moneySymbols = ['\$', '€', '£', '₹', 'SAR', 'AED', 'QAR', 'KWD', 'BHD'];
  final _units = ['/hour', '/month', '/year'];

  int _countWords(String text) => text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  void _onTextChanged(String text, ValueNotifier<int> counter) {
    counter.value = _countWords(text);
  }

  Widget _buildTextField({
    required String label,
    required String controllerKey,
    required String hintText,
    String? Function(String?)? validator,
    bool isMultiline = false,
    ValueNotifier<int>? wordCounter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(labelText: label),
        TextFormField(
          controller: _controllers[controllerKey],
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
            builder: (_, count, __) => Text(
              "Word count: $count / ${wordCounter == _wordCount ? 250 : 450}",
              style: TextStyle(
                color: count > (wordCounter == _wordCount ? 250 : 450) ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LabelText(labelText: label),
        DropdownButton<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 18))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _wordCount.dispose();
    _wordCount2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: RichText(
          text: const TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: RawScrollbar(
        thumbColor: Colors.black38,
        thickness: 8,
        radius: const Radius.circular(10),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 20),
                _buildTextField(
                  label: 'About your company/organisation',
                  controllerKey: 'aboutOrg',
                  hintText: 'Specify less than (250 words)',
                  validator: (val) => (_countWords(val ?? '') < 50) ? 'At least 50 words required' : null,
                  isMultiline: true,
                  wordCounter: _wordCount,
                ),
                _buildTextField(
                  label: 'Job Location',
                  controllerKey: 'location',
                  hintText: 'Eg: Thiruvananthapuram, Kerala',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildTextField(
                  label: 'Job Hiring For',
                  controllerKey: 'hiringFor',
                  hintText: 'Eg: Nurse',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildTextField(
                  label: 'Year Of Experience',
                  controllerKey: 'experience',
                  hintText: 'Eg: Fresher, 1 year...',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildTextField(
                  label: 'Skills Required',
                  controllerKey: 'skills',
                  hintText: 'Eg: OT, NICU, Surgeon...',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildDropdown(
                  label: 'Pay Currency',
                  value: _selectedSymbol,
                  items: _moneySymbols,
                  onChanged: (val) => setState(() => _selectedSymbol = val!),
                ),
                _buildTextField(
                  label: 'From',
                  controllerKey: 'salaryFrom',
                  hintText: 'Eg: 15,000',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildTextField(
                  label: 'To',
                  controllerKey: 'salaryTo',
                  hintText: 'Eg: 30,000',
                  validator: (val) => (val == null || val.isEmpty) ? 'Required field' : null,
                ),
                _buildDropdown(
                  label: 'Pay Unit',
                  value: _selectedUnit,
                  items: _units,
                  onChanged: (val) => setState(() => _selectedUnit = val!),
                ),
                _buildTextField(
                  label: 'Job Description',
                  controllerKey: 'jobDesc',
                  hintText: 'Specify less than (450 words)',
                  validator: (val) => (_countWords(val ?? '') < 50) ? 'At least 50 words required' : null,
                  isMultiline: true,
                  wordCounter: _wordCount2,
                ),
                const SizedBox(height: 20),
                MainButton(
                  text: 'Submit',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, '/organisation_home');
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
