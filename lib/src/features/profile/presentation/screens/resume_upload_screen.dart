import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../../../shared/widgets/buttons/back_button_widget.dart';

class ResumeUploadScreen extends StatefulWidget {
  final String? flowContext;

  const ResumeUploadScreen({
    super.key,
    this.flowContext,
  });

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  File? _pickedFile;
  bool _isUploading = false;
  String? _userId;
  String? _fileName;
  int? _uploadedBytes;
  int? _totalBytes;
  bool _uploadCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCheckResume();
  }

  Future<void> _loadUserIdAndCheckResume() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id != null && mounted) {
      setState(() {
        _userId = id;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          _pickedFile = File(file.path!);
          _fileName = file.name;
          _totalBytes = File(file.path!).lengthSync();
          _uploadedBytes = 0;
          _uploadCompleted = false;
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _pickAndUploadFile() async {
    await _pickFile();

    if (_pickedFile != null) {
      await _uploadResume();
    }
  }

  Future<void> _uploadResume() async {
    if (_pickedFile == null || _userId == null) return;

    setState(() {
      _isUploading = true;
      _uploadedBytes = 0;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.joinmeds.in/api/resume/upload/$_userId'),
      );

      // Create a stream with progress tracking
      final fileBytes = await _pickedFile!.readAsBytes();
      final totalBytes = fileBytes.length;

      // Simulate progress updates
      setState(() {
        _totalBytes = totalBytes;
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: _fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      // Simulate progress (since http package doesn't support real progress)
      _simulateProgress();

      final response = await request.send();
      await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        setState(() {
          _uploadCompleted = true;
          _uploadedBytes = _totalBytes;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        _showError('Upload failed. Please try again.');
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      _showError('Upload failed: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _simulateProgress() {
    if (_totalBytes == null) return;

    // Simulate progress over 2 seconds
    const steps = 20;
    const delay = Duration(milliseconds: 100);
    int currentStep = 0;

    Future.doWhile(() async {
      await Future.delayed(delay);
      if (!_isUploading || _uploadCompleted || !mounted) return false;

      currentStep++;
      final progress = (currentStep / steps).clamp(0.0, 0.95);

      if (mounted) {
        setState(() {
          _uploadedBytes = (_totalBytes! * progress).toInt();
        });
      }

      return currentStep < steps && _isUploading && !_uploadCompleted;
    });
  }

  void _navigateToNext() {
    final flow = widget.flowContext ?? 'signup';

    if (flow == 'signup') {
      // Signup flow: go to completion screen
      context.push(RouteNames.signupCompletion);
    } else {
      // Profile flow: should not reach here, but navigate back safely
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _skipForNow() {
    _navigateToNext();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _submitAndNavigate() {
    // File is already uploaded, just navigate
    _navigateToNext();
  }

  void _removeFile() {
    setState(() {
      _pickedFile = null;
      _fileName = null;
      _uploadedBytes = null;
      _totalBytes = null;
      _uploadCompleted = false;
      _isUploading = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Widget _buildUploadProgressCard() {
    if (_fileName == null) return const SizedBox.shrink();

    final progress = _totalBytes != null && _uploadedBytes != null
        ? _uploadedBytes! / _totalBytes!
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // PDF Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/v2/pdfplaceholder.png',
              // size: 32,
            ),
          ),
          const SizedBox(width: 12),

          // File info and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File name
                Text(
                  _fileName!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // File size and status
                Text(
                  _uploadCompleted
                      ? '${_formatBytes(_totalBytes!)} • Completed'
                      : '${_formatBytes(_uploadedBytes ?? 0)} of ${_formatBytes(_totalBytes!)} • Uploading...',
                  style: TextStyle(
                    fontSize: 12,
                    color: _uploadCompleted ? AppColors.success : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _uploadCompleted
                          ? AppColors.success
                          : AppColors.primaryBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _removeFile,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header with file icon
          CustomHeaderContainer(
            backgroundImage: 'assets/v2/Star.png',
            customContent: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    BackButtonWidget(),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 40),
                // Centered file icon
                Image.asset(
                  'assets/v2/fileplaceholder.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Upload CV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'You need to upload your CV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Upload progress card (shows when file is selected)
          if (_fileName != null) ...[
            const SizedBox(height: 24),
            _buildUploadProgressCard(),
          ],

          // Spacer to push buttons to bottom
          const Spacer(),

          // Bottom section with dynamic buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Primary button (Upload/Submit)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _uploadCompleted
                        ? _submitAndNavigate
                        : (_isUploading ? null : _pickAndUploadFile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _uploadCompleted ? 'Submit' : 'Upload',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Secondary action (Skip for now/Remove)
                TextButton(
                  onPressed: _uploadCompleted ? _removeFile : _skipForNow,
                  child: Text(
                    _uploadCompleted ? 'Remove' : 'Skip for now',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
