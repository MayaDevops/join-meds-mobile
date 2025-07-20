// Add these imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';
import '../../widgets/selection_of_professions.dart';

class ResumeUpload extends StatefulWidget {
  const ResumeUpload({super.key});

  @override
  State<ResumeUpload> createState() => _ResumeUploadState();
}

class _ResumeUploadState extends State<ResumeUpload> {
  String? _fileName;
  File? _pickedFile;
  bool _isUploading = false;
  String resumeHeader = 'Please upload your Resume';
  String? _userId;
  String? _resumeUrl;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCheckResume();
  }

  Future<void> _loadUserIdAndCheckResume() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    final resumeId = prefs.getString('resumeId'); // fetch from login data

    if (id != null) {
      setState(() {
        _userId = id;
        _fileName = resumeId; // this will now show the correct resume name
        _resumeUrl = resumeId != null
            ? 'https://api.joinmeds.in/api/resume/$resumeId'
            : null;
      });

      // If resumeId is not null, assume it's already uploaded
      if (resumeId != null) {
        final resumeCheck = await http.head(Uri.parse(_resumeUrl!));
        if (resumeCheck.statusCode == 200) {
          setState(() {
            resumeHeader = 'Resume already uploaded';
          });
        } else {
          // fallback if file not found
          setState(() {
            _fileName = null;
            _resumeUrl = null;
            resumeHeader = 'Please upload your Resume';
          });
        }
      }
    }
  }


  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        if (file.path.endsWith(".pdf")) {
          setState(() {
            _fileName = result.files.single.name;
            _pickedFile = file;
            resumeHeader = 'Resume uploaded successfully';
            _resumeUrl = null; // Clear old resume preview if user picks new one
          });
          _showSnackBar("Resume selected!", Colors.green);
        } else {
          _showSnackBar("Only PDF files are allowed.", Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar("Error picking file: ${e.toString()}", Colors.red);
    }
  }

  Future<void> uploadResume() async {
    if (_pickedFile == null) {
      _showSnackBar("Please upload a resume first!", Colors.red);
      return;
    }

    if (_userId == null) {
      _showSnackBar("User not logged in!", Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.joinmeds.in/api/resume/upload/$_userId'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _pickedFile!.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    debugPrint('Upload status code: ${response.statusCode}');
    debugPrint('Upload response body: $respStr');

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectionProfession()),
      );
    } else {
      _showSnackBar("Upload failed: $respStr", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
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
              _resumeUrl = null;
              resumeHeader = 'Please upload your Resume';
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildResumePreview() {
    if (_resumeUrl != null) {
      return Column(
        children: [
          const Text("Preview not supported, but resume is already uploaded.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          const Icon(Icons.check_circle, color: Colors.green, size: 50),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              _showSnackBar("Resume is already uploaded. You may change it.", Colors.blue);
            },
            child: const Text("Resume already exists", style: TextStyle(color: Colors.blue)),
          )
        ],
      );
    } else {
      return Image.asset(
        'images/resume_img-${_fileName == null ? 1 : 2}.png',
      );
    }
  }

  Widget _buildNavigationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: pickFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            _fileName == null ? 'Upload Resume' : 'Change Resume',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 15),
        MainButton(
          text: _isUploading ? 'Uploading...' : 'Next',
          onPressed: _isUploading
              ? null
              : () {
            if (_resumeUrl != null && _pickedFile == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelectionProfession()),
              );
            } else {
              uploadResume();
            }
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SelectionProfession()),
            );
          },
          child: const Text('Skip for now',
              style: TextStyle(fontSize: 20.0, color: mainBlue)),
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
                _buildResumePreview(),
                const SizedBox(height: 25),
                if (_fileName != null) _buildFileCard(),
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
