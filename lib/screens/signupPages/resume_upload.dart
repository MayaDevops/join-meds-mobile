import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';
import '../../widgets/nurse_course_type_selection.dart';
import '../../widgets/selection_of_professions.dart';
import '../Doctor/dr_academic_status.dart';

class ResumeUpload extends StatefulWidget {
  const ResumeUpload({super.key});

  @override
  State<ResumeUpload> createState() => _ResumeUploadState();
}

class _ResumeUploadState extends State<ResumeUpload> {
  String? _fileName;
  File? _pickedFile;
  String resumeHeader = 'Please upload your Resume';

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
          resumeHeader = 'Resume uploaded successfully';
        });
        _showSnackBar("Resume uploaded successfully!", Colors.green);
      }
    } catch (e) {
      _showSnackBar("Error picking file: ${e.toString()}", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _navigateToProfessionSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectionProfession()),
    );
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
          Positioned.fill(
            child: Image.asset(bodyBg, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  resumeHeader,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: inputBorderClr),
                ),
                const SizedBox(height: 40),
                Image.asset(
                    'images/resume_img-${_fileName == null ? 1 : 2}.png'),
                const SizedBox(height: 25),
                if (_fileName != null) _buildFileCard(),
                const SizedBox(height: 15),
                UploadButton(fileName: _fileName, onPickFile: pickFile),
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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() {
              _fileName = null;
              _pickedFile = null;
              resumeHeader = 'Please upload your Resume';
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
              _showSnackBar("Please upload a resume first!", Colors.red);
            } else {
              _navigateToProfessionSelection();
            }
          },
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            side: const BorderSide(color: mainBlue, width: 3),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _navigateToProfessionSelection,
          child: const Text('Skip for now',
              style: TextStyle(fontSize: 20.0, color: mainBlue)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class UploadButton extends StatelessWidget {
  final String? fileName;
  final Function onPickFile;

  const UploadButton({super.key, required this.fileName, required this.onPickFile});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPickFile(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(width: 2, color: mainBlue),
        ),
      ),
      child: Text(
        fileName == null ? 'Upload Resume' : 'Change Resume',
        style: const TextStyle(fontSize: 17, color: mainBlue),
      ),
    );
  }
}



