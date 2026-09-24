import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/v2_api_constants.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../../api/personal_data_service.dart';
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

  /// Resume id already stored against this user (UserDetailsDTO.resumeId).
  /// Non-null means a resume can be viewed via GET /api/resume/{resumeId}.
  String? _existingResumeId;
  bool _isLoadingExisting = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndCheckResume();
  }

  /// Debug logger for the resume upload flow.
  /// Search the console for `ResumeUpload:` to follow the whole request.
  void _log(String message) {
    debugPrint('ResumeUpload: $message');
  }

  Future<void> _loadUserIdAndCheckResume() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    _log('--- screen opened (flowContext=${widget.flowContext ?? "signup"}) ---');
    _log('SharedPreferences["userId"] = $id (type=${id.runtimeType})');
    if (id == null || id.isEmpty) {
      _log(
        'WARNING: userId is null/empty -> _uploadResume() will return early '
        'and NO network call will be made.',
      );
      _log('All SharedPreferences keys: ${prefs.getKeys().toList()}');
    }

    if (id != null && mounted) {
      setState(() {
        _userId = id;
      });
    }

    await _loadExistingResume(prefs, id);
  }

  /// Resolves the resume already on file so it can be viewed, not just replaced.
  /// Uses the cached id first for an instant render, then confirms against
  /// GET /api/user-details/{userId}, which is the source of truth.
  Future<void> _loadExistingResume(SharedPreferences prefs, String? id) async {
    final cached = prefs.getString('resumeId') ?? prefs.getString('resume_id');
    if (_isUsableResumeId(cached) && mounted) {
      _log('cached resumeId = $cached');
      setState(() => _existingResumeId = cached);
    }

    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _isLoadingExisting = false);
      return;
    }

    try {
      final data = await PersonalDataService.getPersonalData(id);
      final serverResumeId = data?.resumeId;
      _log('server resumeId (from /user-details/$id) = $serverResumeId');

      if (!mounted) return;
      setState(() {
        _existingResumeId =
            _isUsableResumeId(serverResumeId) ? serverResumeId : null;
        _isLoadingExisting = false;
      });
    } catch (e) {
      _log('could not confirm existing resume: $e');
      if (mounted) setState(() => _isLoadingExisting = false);
    }
  }

  /// Rejects empty values and the literal string "null", which older builds
  /// wrote into SharedPreferences via `resumeId.toString()`.
  bool _isUsableResumeId(String? value) =>
      value != null && value.isNotEmpty && value != 'null';

  /// Absolute URL for GET /api/resume/{filename}.
  String _resumeUrlFor(String resumeId) =>
      '${ApiConstants.baseUrl}${V2ApiConstants.downloadResume(resumeId)}';

  Future<void> _viewResume() async {
    final resumeId = _existingResumeId;
    if (!_isUsableResumeId(resumeId)) return;

    final url = _resumeUrlFor(resumeId!);
    _log('opening resume: $url');

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) _showError('Could not open the resume.');
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        _log('file picker cancelled by user');
      } else if (result.files.single.path == null) {
        _log('ERROR: picker returned a file with a null path: '
            '${result.files.single.name}');
      }

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        _log('picked file -> name=${file.name} path=${file.path} '
            'size=${File(file.path!).lengthSync()} bytes '
            'extension=${file.extension}');
        setState(() {
          _pickedFile = File(file.path!);
          _fileName = file.name;
          _totalBytes = File(file.path!).lengthSync();
          _uploadedBytes = 0;
          _uploadCompleted = false;
        });
      }
    } catch (e, st) {
      _log('EXCEPTION while picking file: $e');
      _log('stack: $st');
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
    if (_pickedFile == null || _userId == null) {
      _log(
        'ABORTED before request: pickedFile=${_pickedFile?.path} userId=$_userId '
        '-> nothing was sent to the server.',
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadedBytes = 0;
    });

    final stopwatch = Stopwatch()..start();
    final uri = Uri.parse('https://api.joinmeds.in/api/resume/upload/$_userId');

    try {
      final request = http.MultipartRequest('POST', uri);

      // Create a stream with progress tracking
      final fileBytes = await _pickedFile!.readAsBytes();
      final totalBytes = fileBytes.length;

      _log('=== REQUEST ===');
      _log('method   : POST');
      _log('url      : $uri');
      _log('userId   : $_userId');
      _log('file     : $_fileName (${_pickedFile!.path})');
      _log('exists   : ${_pickedFile!.existsSync()}');
      _log('bytes    : $totalBytes');
      _log('field    : "file"  contentType: application/pdf');
      _log('headers  : ${request.headers}  (note: no Authorization header is '
          'attached on this screen)');

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
      final responseBody = await response.stream.bytesToString();
      stopwatch.stop();

      _log('=== RESPONSE ===');
      _log('status        : ${response.statusCode} ${response.reasonPhrase}');
      _log('elapsed       : ${stopwatch.elapsedMilliseconds} ms');
      _log('contentLength : ${response.contentLength}');
      _log('headers       : ${response.headers}');
      _log('body          : ${responseBody.isEmpty ? "<empty>" : responseBody}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        _log('NON-2xx status -> upload rejected by the server.');
        _showError('Upload failed (${response.statusCode}). Please try again.');
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      // The endpoint answers 200 with the new resume id as a bare string.
      // A 200 alone is not proof of success: an empty or error body means
      // nothing was stored, and reporting success there is what made failed
      // uploads look like they had worked.
      final returnedResumeId = _extractResumeId(responseBody);

      if (!_isUsableResumeId(returnedResumeId)) {
        _log('2xx but no usable resume id in the body -> treating as FAILURE.');
        _showError('Upload failed: the server did not store the file.');
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      _log('stored resumeId = $returnedResumeId');
      await _persistResumeId(returnedResumeId!);

      if (!mounted) return;

      setState(() {
        _existingResumeId = returnedResumeId;
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
    } catch (e, st) {
      stopwatch.stop();
      _log('=== EXCEPTION after ${stopwatch.elapsedMilliseconds} ms ===');
      _log('url  : $uri');
      _log('error: $e');
      _log('stack: $st');
      _showError('Upload failed: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Pulls the resume id out of the upload response. The endpoint returns a
  /// bare string, but a JSON object is handled too in case that changes.
  String? _extractResumeId(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final id = decoded['resumeId'] ??
              decoded['fileName'] ??
              decoded['fileId'] ??
              decoded['data'];
          return id?.toString();
        }
      } catch (e) {
        _log('response body looked like JSON but did not parse: $e');
      }
      return null;
    }

    // Strip quotes from a JSON-encoded bare string ("abc.pdf").
    return trimmed.replaceAll('"', '');
  }

  /// Writes the new resume id everywhere the app reads it from, then forces a
  /// profile re-fetch. Without this the upload succeeds server-side but every
  /// screen keeps rendering the stale "no resume" state.
  Future<void> _persistResumeId(String resumeId) async {
    final prefs = await SharedPreferences.getInstance();
    // Both spellings are in use across the app (job application flow reads
    // 'resume_id', the profile screens read 'resumeId').
    await prefs.setString('resumeId', resumeId);
    await prefs.setString('resume_id', resumeId);

    if (!mounted) return;
    final userProvider = context.read<UserProvider>();
    await userProvider.updateResume(resumeId);
    await userProvider.refreshUserData(forceRefetch: true);
    _log('local state refreshed -> hasResume=${userProvider.hasResume}');
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
      // Profile/settings flow: return to the screen that opened this one.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.home);
      }
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

  Widget _buildExistingResumeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CV on file',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _existingResumeId!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _viewResume,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('View'),
          ),
        ],
      ),
    );
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
          ]
          // Otherwise surface the resume already on file, so it can be viewed
          // rather than only replaced.
          else if (_isLoadingExisting) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ] else if (_isUsableResumeId(_existingResumeId)) ...[
            const SizedBox(height: 24),
            _buildExistingResumeCard(),
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
                      _uploadCompleted
                          ? 'Submit'
                          : (_isUsableResumeId(_existingResumeId)
                              ? 'Replace CV'
                              : 'Upload'),
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
