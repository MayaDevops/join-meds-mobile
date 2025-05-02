import 'package:flutter/material.dart';
import 'package:untitled/widgets/repeated_headings.dart';
import '../../constants/constant.dart';

class GnNurseDiplomaAcademicStatus extends StatefulWidget {
  const GnNurseDiplomaAcademicStatus({super.key});

  @override
  State<GnNurseDiplomaAcademicStatus> createState() => _GnNurseDiplomaAcademicStatusState();
}

class _GnNurseDiplomaAcademicStatusState extends State<GnNurseDiplomaAcademicStatus> {
  String? postGraduation;
  String? workExperience;

  void _handleSubmit() async {
    if (postGraduation == null) {
      _showSnackBar('Please select a profession', Colors.red);
      return;
    }

    if (postGraduation == 'PG-Holder') {
      Navigator.pushNamed(context, '/nurse_pg_holder_speciality');
    } else {
      final internshipStatus = await _showOptionBottomSheet(
        title: 'Do you have any Internship?',
        options: {
          'Internship-Yes': 'Yes',
          'Internship-No': 'No',
        },
      );

      if (internshipStatus == null) return;

      // Navigate based on Internship status
      if (internshipStatus == 'Internship-No') {
        showModalBottomSheet(context: context, builder: (context) => WorkExpSheet(),);
      } else {
        Navigator.pushNamed(
            context, '/gn_nurse_internship_completed'); // Navigate to Internship page
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
        onChanged: (value) => setState(() => postGraduation = value),
        onSave: _handleSubmit,
      ),
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
          FormsMainHead(text: 'General Nursing'),
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
                label: 'Diploma Ongoing',
                onTap: () =>
                    Navigator.pushNamed(context, '/gn_nurse_diploma_ongoing'),
              ),
              _AcademicOption(
                icon: Icons.school,
                label: 'Diploma Completed',
                onTap: _openPostGraduationSheet,
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
  final ValueChanged<String?> onChanged;
  final VoidCallback onSave;

  const _PostGraduationSheet({
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedValue;

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
              child: const Text('Do you have post Bsc?',
                  style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RadioOption(
                  text: 'Yes',
                  value: 'Post-Bsc-holder',
                  groupValue: selectedValue,
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                    onChanged(val);
                  },
                ),
                const SizedBox(width: 70),
                _RadioOption(
                  text: 'No',
                  value: 'Not Post-Bsc-holder',
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
          SizedBox(height: 20,),
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
          SizedBox(height: 20,),
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


class WorkExpSheet extends StatefulWidget {
  const WorkExpSheet({super.key});

  @override
  State<WorkExpSheet> createState() => _WorkExpSheetState();
}

class _WorkExpSheetState extends State<WorkExpSheet> {
  String? workExpStatus;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
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
          child: Text('Do you have any Work Experience',style: TextStyle(fontSize: 20),),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Row(
              children: [
                Text('Yes',style: radioTextStyle,),
                Radio(value: 'Work-Experience-Yes', groupValue: workExpStatus, onChanged: (value){
                  setState(() {
                    workExpStatus = value;
                  });
                })
              ],
            ),

            Row(
              children: [
                Text('No',style: radioTextStyle,),
                Radio(value: 'Work-Experience-No', groupValue: workExpStatus, onChanged: (value){
                  setState(() {
                    workExpStatus = value;
                  });
                }),
              ],
            ),

          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: (){
            if(workExpStatus == 'Work-Experience-Yes'){
              Navigator.pushNamed(context, '/nurse_work_experience');
            }else{
              Navigator.pushNamed(context, '/County_that_you_preferred_page');
              // country that you preferred page
            }
          },
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(15),),
            backgroundColor: WidgetStatePropertyAll(mainBlue),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),),),
          ),

          child: Text('continue',style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),),
        ),
      ],
    );
  }
}
