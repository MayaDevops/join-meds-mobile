import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constant.dart';
import '../../../widgets/main_button.dart';

class CertificateOfSpecialisation extends StatefulWidget {
  const CertificateOfSpecialisation({super.key});

  @override
  State<CertificateOfSpecialisation> createState() =>
      _CertificateOfSpecialisationState();
}

class _CertificateOfSpecialisationState
    extends State<CertificateOfSpecialisation> {
  String? _fileName;
  File? _pickedFile;
  int imageNum = 1;

  @override
  void initState() {
    super.initState();
    _loadSavedFile();
  }

  /// Load previously selected file if any (persistent state)
  Future<void> _loadSavedFile() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('certFilePath');
    final name = prefs.getString('certFileName');
    if (path != null && File(path).existsSync()) {
      setState(() {
        _pickedFile = File(path);
        _fileName = name ?? path.split('/').last;
        imageNum = 2;
      });
    }
  }

  /// Pick file using system picker
  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.first.path != null) {
        final file = File(result.files.first.path!);
        setState(() {
          _pickedFile = file;
          _fileName = result.files.first.name;
          imageNum = 2;
        });

        // Save file path persistently
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('certFilePath', file.path);
        await prefs.setString('certFileName', _fileName!);

        _showSnackBar(
          "Certification uploaded successfully!",
          Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e", Colors.red);
    }
  }

  /// Show snackbar safely
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// File display card
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
              _fileName ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              setState(() {
                _fileName = null;
                _pickedFile = null;
                imageNum = 1;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('certFilePath');
              await prefs.remove('certFileName');
            },
          ),
        ],
      ),
    );
  }

  /// Bottom navigation buttons
  Widget _buildNavigationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MainButton(
          text: 'Next',
          onPressed: () {
            if (_pickedFile == null) {
              _showSnackBar(
                "Please upload a certification first!",
                Colors.red,
              );
              return;
            }

            // Proceed to next page or API upload logic
            Navigator.pushNamed(context, '/next_page');
          },
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            side: const BorderSide(color: mainBlue, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/County_that_you_preferred_page');
          },
          child: const Text(
            'Skip for now',
            style: TextStyle(fontSize: 20.0, color: mainBlue),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Certification", style: appBarText),
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
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: inputBorderClr),
                ),
                const SizedBox(height: 40),
                Image.asset('images/resume_img-$imageNum.png'),
                const SizedBox(height: 25),
                if (_fileName != null) _buildFileCard(),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: pickFile,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(width: 2, color: mainBlue),
                    ),
                  ),
                  child: Text(
                    _fileName == null
                        ? 'Upload Certificate'
                        : 'Change Certificate',
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
}
