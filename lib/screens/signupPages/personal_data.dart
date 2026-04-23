import 'dart:convert';
import 'dart:io';
import 'package:untitled/src/core/router/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants/constant.dart';
import '../../src/shared/widgets/inputs/custom_text_field.dart';
import '../../src/shared/widgets/buttons/primary_button.dart';
import '../../models/personal_data_model.dart';
import '../../api/personal_data_service.dart';

class PersonalData extends StatefulWidget {
  const PersonalData({super.key});

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  final _personalDataKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarNumController = TextEditingController();

  String? userId;

  // Profile picture upload
  XFile? _imageFile;
  String? _photoId;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id != null && mounted) {
      setState(() => userId = id);
      _fetchAndFillPersonalData(id);
    }
  }

  Future<void> _fetchAndFillPersonalData(String userId) async {
    try {
      final data = await PersonalDataService.getPersonalData(userId);
      if (data != null && mounted) {
        setState(() {
          _nameController.text = data.fullname ?? '';
          _dobController.text = data.dob ?? '';
          _emailController.text = data.email ?? '';
          _addressController.text = data.address ?? '';
          _aadhaarNumController.text = data.aadhaarNo ?? '';
          _photoId = data.photoId;
        });
      }
    } catch (e) {
      debugPrint('Error fetching personal data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _aadhaarNumController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1965),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final formattedDate = DateFormat("dd-MM-yyyy").format(date);
      setState(() => _dobController.text = formattedDate);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null && mounted) {
      setState(() => _imageFile = pickedFile);
      await _uploadProfileImage();
    }
    if (mounted) Navigator.pop(context); // Close bottom sheet
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null || userId == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.joinmeds.in/api/images/upload/$userId'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', _imageFile!.path),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final photoId = jsonResponse['photoId'] ?? jsonResponse['id'];

        if (photoId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('photoId', photoId.toString());

          if (mounted) {
            setState(() => _photoId = photoId.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile picture uploaded successfully!')),
            );
          }
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: mainBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        // Circular profile picture
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: _buildProfileImage(),
              ),
            ),
            if (_isUploadingImage) const CircularProgressIndicator(),
          ],
        ),
        const SizedBox(height: 16),

        // Upload button
        ElevatedButton(
          onPressed: _showImageSourceBottomSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Upload Profile Picture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Image.file(
        File(_imageFile!.path),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if (_photoId != null && _photoId!.isNotEmpty) {
      return Image.network(
        'https://api.joinmeds.in/api/images/$_photoId',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.grey[600],
    );
  }

  Future<void> _submitData() async {
    if (!_personalDataKey.currentState!.validate() || userId == null) return;

    final data = PersonalDataModel(
      fullname: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      aadhaarNo: _aadhaarNumController.text.trim(),
      userId: userId!,
    );

    debugPrint("Submitting JSON: ${jsonEncode(data.toJson())}");

    final success = await PersonalDataService.updatePersonalData(userId!, data);
    if (!mounted) return;

    if (success) {
      NavigationHelper.pushNamed(context, '/resume_upload');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: const BoxDecoration(
                color: mainBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Back button
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Personal Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter accurate information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Rest of content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _personalDataKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile picture section
                      _buildProfilePictureSection(),
                      const SizedBox(height: 30),

                      // Name field
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          if (value.length < 3) return 'Name too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of birth field
                      CustomTextField(
                        controller: _dobController,
                        hintText: 'Date of birth',
                        readOnly: true,
                        onTap: _selectDate,
                        // suffixIcon: const Icon(Icons.calendar_today, color: mainBlue),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Date of birth is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address field
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          if (value.length < 5) return 'Address too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Aadhaar Number field
                      CustomTextField(
                        controller: _aadhaarNumController,
                        hintText: 'Aadhaar Number (Optional)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),

                      // Continue button
                      PrimaryButton(
                        text: 'Continue',
                        onPressed: _submitData,
                        borderRadius: 10,
                        animate: false,
                        textStyle: const TextStyle(

                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
