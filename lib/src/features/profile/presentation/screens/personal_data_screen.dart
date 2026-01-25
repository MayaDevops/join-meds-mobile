import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:untitled/src/shared/widgets/buttons/back_button_widget.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/custom_date_picker_field.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../../api/personal_data_service.dart';
import '../../../../../models/personal_data_model.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _personalDataKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadhaarNumController = TextEditingController();

  String? userId;
  XFile? _imageFile;
  String? _photoId;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // --- Logic Methods (Kept largely the same, focusing on UI) ---

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null && mounted) {
      setState(() => _imageFile = pickedFile);
      await _uploadProfileImage(pickedFile);
    }
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _uploadProfileImage(XFile imageFile) async {
    if (userId == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.joinmeds.in/api/images/upload/$userId'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // final jsonResponse = json.decode(responseBody);

        String? photoId;
        if (responseBody.contains(':')) {
          photoId = responseBody.split(':').last.trim();
        }
        if (photoId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('photoId', photoId.toString());

          if (mounted) {
            setState(() {
              _photoId = photoId.toString();
              _isUploadingImage = false;
            });

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile picture uploaded successfully!')),
              );
            }
          }
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Camera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text('Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitData() async {
    if (!_personalDataKey.currentState!.validate() || userId == null) return;
    setState(() => _isLoading = true);

    try {
      // Create PersonalDataModel with form data
      final data = PersonalDataModel(
        fullname: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        aadhaarNo: _aadhaarNumController.text.trim(),
        userId: userId!,
        photoId: _photoId, // Include existing photoId if available
      );

      // Call the API to save personal data
      final success = await PersonalDataService.updatePersonalData(userId!, data);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Refresh UserProvider to update the home screen
          await context.read<UserProvider>().refreshUserData();

          // Navigate to profession selection with signup flow context
          context.push('/profession-selection?flow=signup');
        } else {
          // Show error message if API call failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save personal data. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving personal data: $e')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    // Screen height helper
    final topHeight = MediaQuery.of(context).size.height * 0.30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stack for Header + Profile Picture Overlap
            SizedBox(
              height: topHeight + 70, // Header height + half of profile picture overlap
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // 1. Blue Header Background
                  Container(
                    height: topHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      // gradient: LinearGradient(
                      //   begin: Alignment.topCenter,
                      //   end: Alignment.bottomCenter,
                      //   colors: [AppColors.primaryBlue,AppColors.primaryBlue],
                      // ),
                    ),
                    // Subtle pattern overlay (optional, mimics the "stars/grid" in image)
                    child: Container(
                     decoration: BoxDecoration(
                       image: DecorationImage(image: AssetImage('assets/v2/Star.png'),fit: BoxFit.fill)
                     ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              // Back Button Row
                              Row(
                                children: [
                                  BackButtonWidget(),
                                  SizedBox(width: 16,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    // Title Text
                                    const Text(
                                      'Personal Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
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
                                  ],)
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Profile Picture (Positioned to overlap bottom of header)
                  Positioned(
                    bottom: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE0E0E0),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _imageFile != null
                                ? Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            )
                                : _photoId != null
                                ? Image.network(
                              'https://api.joinmeds.in/api/images/$_photoId',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                                : _buildPlaceholder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Upload Button
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 24),
              child: ElevatedButton(
                onPressed: _showImageSourceBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9), // Specific Cyan/Blue
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Profile Picture',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 4. Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _personalDataKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomDatePickerField(
                      controller: _dobController,
                      hintText: 'Date of birth',
                      validator: (v) => v!.isEmpty ? 'Date of birth is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Address',
                      validator: (v) => v!.isEmpty ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _aadhaarNumController,
                      hintText: 'Aadhaar Number (Optional)',
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Bottom Safe Area
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFD9D9D9),
      child: Center(
        child: Icon(Icons.person, size: 80, color: Colors.white),

      ),
    );
  }
}



