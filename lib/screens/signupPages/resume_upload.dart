import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';

class ResumeUpload extends StatefulWidget {
  const ResumeUpload({super.key});

  @override
  State<ResumeUpload> createState() => _ResumeUploadState();
}

class _ResumeUploadState extends State<ResumeUpload> {
  String? _fileName;
  File? _pickedFile;
  int num = 1;

  // Pick a resume file (PDF/DOC/DOCX)
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _fileName = result.files.first.name;
          _pickedFile = File(result.files.first.path!);
          num = 2; // Update num when file is picked
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Resume uploaded successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking file: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Resume", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Image.asset(bodyBg, fit: BoxFit.cover),),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Please upload your Resume',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: inputBorderClr),
                ),
                const SizedBox(height: 40),

                // ✅ Dynamically update the image based on `num`
                Image.asset('images/resume_img-$num.png'),

                const SizedBox(height: 25),

                // Display selected file name
                if (_fileName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
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
                            num = 1; // ✅ Reset num when file is removed
                          }),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 15),

                // Upload Button
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
                    _fileName == null ? 'Upload Resume' : 'Change Resume',
                    style: const TextStyle(fontSize: 17, color: mainBlue),
                  ),
                ),

                const Spacer(),

                // Navigation Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MainButton(
                      text: 'Next',
                      onPressed: () {
                        if (_pickedFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please upload a resume first!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Proceed to next step
                          Navigator.pushNamed(context, '/dr_acd_status');
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
                      onPressed: () {
                        // Skip action
                        Navigator.pushNamed(context, '/dr_acd_status');
                      },
                      child: Text('Skip for now', style: TextStyle(fontSize: 20.0, color: mainBlue)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
