import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../constants/constant.dart';
import '../../../widgets/main_button.dart';


class CertificateOfSpecialisation extends StatefulWidget {
  const CertificateOfSpecialisation({super.key});

  @override
  State<CertificateOfSpecialisation> createState() => _CertificateOfSpecialisationState();
}

class _CertificateOfSpecialisationState extends State<CertificateOfSpecialisation> {
  String? _fileName;
  File? _pickedFile;
  int num = 1;

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.first.name;
          _pickedFile = File(result.files.first.path!);
          num = 2;
        });

        _showSnackBar("certification of specialisation uploaded successfully!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("certification", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Add certification of specialisation if any',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: inputBorderClr),
                ),
                const SizedBox(height: 40),
                Image.asset('images/resume_img-$num.png'),
                const SizedBox(height: 25),

                if (_fileName != null)
                  _buildFileCard(),
                const SizedBox(height: 15),

                TextButton(
                  onPressed: pickFile,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(width: 2, color: mainBlue),
                    ),
                  ),
                  child: Text(
                    _fileName == null ? 'Upload Certificate' : 'Change Certificate',
                    style: const TextStyle(fontSize: 17, color: mainBlue),
                  ),
                ),

                const Spacer(),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _fileName!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() {
              _fileName = null;
              _pickedFile = null;
              num = 1;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MainButton(
          text: 'Next',
          onPressed: () {
            if (_pickedFile == null) {
              _showSnackBar("Please upload a certification of specialisation first!", Colors.red);
            } else {

            }
          },
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            side: const BorderSide(color: mainBlue, width: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: (){},
          child: const Text('Skip for now', style: TextStyle(fontSize: 20.0, color: mainBlue)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

