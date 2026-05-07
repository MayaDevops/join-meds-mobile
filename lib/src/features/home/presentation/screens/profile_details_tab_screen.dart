import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../../api/personal_data_service.dart';
import 'package:url_launcher/url_launcher.dart';


/// Profile details tab screen - Shows user profile with sectioned layout
class ProfileDetailsTabScreen extends StatefulWidget {
  const ProfileDetailsTabScreen({super.key});

  @override
  State<ProfileDetailsTabScreen> createState() =>
      _ProfileDetailsTabScreenState();
}

class _ProfileDetailsTabScreenState extends State<ProfileDetailsTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Basic user data from API
  String? _fullName;
  String? _email;
  String? _phone;
  String? _profession;
  String? _photoId;

  // Additional data from API
  String? _dob;
  String? _address;
  String? _aadhaarNo;
  String? _resumeId;
  String? _academicStatus;
  String? _workExperience;
  String? _speciality;
  String? _clinicalNonclinical;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    // Get userId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      debugPrint('No userId found, cannot load profile data');
      return;
    }

    if (mounted) {
      setState(() => _isLoadingData = true);
    }

    try {
      // Fetch data from API
      final data = await PersonalDataService.getPersonalData(userId);

      if (data != null && mounted) {
        // Update local state with all data from API
        setState(() {
          // Basic user data
          _fullName = data.fullname;
          _email = data.email;
          _phone = data.emailOrPhone; // API returns phone in emailOrPhone field
          _profession = data.profession;
          _photoId = data.photoId;

          // Additional data
          _dob = data.dob;
          _address = data.address;
          _aadhaarNo = data.aadhaarNo;
          _resumeId = data.resumeId;
          _academicStatus = data.academicStatus;
          _workExperience = data.workExperience;
          _speciality = data.speciality;
          _clinicalNonclinical = data.clinicalNonclinical;
        });

        // Save to SharedPreferences for offline access
        await prefs.setString('dob', data.dob ?? '');
        await prefs.setString('address', data.address ?? '');
        await prefs.setString('aadhaarNo', data.aadhaarNo ?? '');
        await prefs.setString('resumeId', data.resumeId ?? '');
        await prefs.setString('academicStatus', data.academicStatus ?? '');
        await prefs.setString('workExperience', data.workExperience ?? '');
        await prefs.setString('speciality', data.speciality ?? '');
        await prefs.setString('clinicalNonclinical', data.clinicalNonclinical ?? '');

        // Update UserProvider-related data in SharedPreferences
        if (data.fullname != null && data.fullname!.isNotEmpty) {
          await prefs.setString('fullName', data.fullname!);
        }
        if (data.email != null && data.email!.isNotEmpty) {
          await prefs.setString('email', data.email!);
        }
        if (data.profession != null && data.profession!.isNotEmpty) {
          await prefs.setString('profession', data.profession!);
        }
        if (data.photoId != null && data.photoId!.isNotEmpty) {
          await prefs.setString('photoId', data.photoId!);
        }

        // ALSO save data in UserProvider format (as JSON object)
        // This fixes the profile validation error where UserProvider couldn't find the data
        final userProfileData = {
          'fullName': data.fullname,
          'email': data.email,
          'phone': data.emailOrPhone,
          'profession': data.profession,
          'profileImageUrl': data.photoId,
          'resumeUrl': data.resumeId,
        };
        await prefs.setString('user_profile', jsonEncode(userProfileData));
        debugPrint('ProfileDetailsTabScreen: Saved profile data in UserProvider format');
      }
    } catch (e) {
      debugPrint('Error loading profile data from API: $e');

      // Fallback: Load from SharedPreferences if API fails
      if (mounted) {
        setState(() {
          // Basic user data from cache
          _fullName = prefs.getString('fullName');
          _email = prefs.getString('email');
          _phone = prefs.getString('phone');
          _profession = prefs.getString('profession');
          _photoId = prefs.getString('photoId');

          // Additional data from cache
          _dob = prefs.getString('dob');
          _address = prefs.getString('address');
          _aadhaarNo = prefs.getString('aadhaarNo');
          _resumeId = prefs.getString('resumeId');
          _academicStatus = prefs.getString('academicStatus');
          _workExperience = prefs.getString('workExperience');
          _speciality = prefs.getString('speciality');
          _clinicalNonclinical = prefs.getString('clinicalNonclinical');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          //   onPressed: () {
          //     context.push(RouteNames.settings);
          //   },
          // ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return RefreshIndicator(
                  onRefresh: _loadAdditionalData,
                  color: AppColors.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Section 1: Basic Details
                        _buildBasicDetailsSection(context, userProvider),

                        const SizedBox(height: 16),

                        // Section 2: Resume
                        _buildResumeSection(context, userProvider),

                        const SizedBox(height: 16),

                        // Section 3: Professions
                        _buildProfessionsSection(context, userProvider),

                        const SizedBox(height: 16),

                        // Section 4: Settings & Support
                        _buildSettingsSupportSection(context, userProvider),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ========== SECTION 1: BASIC DETAILS ==========
  Widget _buildBasicDetailsSection(
      BuildContext context, UserProvider userProvider) {
    // Use local state variables from API instead of UserProvider
    final name = _fullName ?? 'Guest User';
    final email = _email;
    final phone = _phone;

    return _buildProfileSection(
      title: 'Basic Details',
      icon: Icons.person_outline,
      children: [
        // Profile Picture
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                backgroundImage: _buildProfileImageProvider(),
                child: _buildProfileImageProvider() == null
                    ? Text(
                        _getInitials(name),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Name
        _buildInfoRow(
          label: 'Full Name',
          value: name,
          icon: Icons.person,
        ),

        // DOB
        _buildInfoRow(
          label: 'Date of Birth',
          value: _dob,
          icon: Icons.cake,
        ),

        // Email
        _buildInfoRow(
          label: 'Email',
          value: email,
          icon: Icons.email,
        ),

        // Phone
        if (phone != null && phone.isNotEmpty)
          _buildInfoRow(
            label: 'Phone',
            value: phone,
            icon: Icons.phone,
          ),

        // Address
        _buildInfoRow(
          label: 'Address',
          value: _address,
          icon: Icons.location_on,
        ),

        // Aadhaar (masked)
        if (_aadhaarNo != null && _aadhaarNo!.isNotEmpty)
          _buildInfoRow(
            label: 'Aadhaar Number',
            value: _maskAadhaar(_aadhaarNo!),
            icon: Icons.badge,
          ),

        const SizedBox(height: 16),

        // Edit Button
        _buildActionButton(
          text: 'Edit Basic Details',
          icon: Icons.edit_outlined,
          onPressed: () {
            context.push(RouteNames.personalDataEdit);
          },
        ),
      ],
    );
  }

  // ========== SECTION 2: RESUME ==========
  Widget _buildResumeSection(BuildContext context, UserProvider userProvider) {
    // Use local state variable from API
    final hasResume = _resumeId != null && _resumeId!.isNotEmpty;

    return _buildProfileSection(
      title: 'Resume',
      icon: Icons.description_outlined,
      children: [
        // Resume Status
        Row(
          children: [
            Icon(
              hasResume ? Icons.check_circle : Icons.upload_outlined,
              color: hasResume ? AppColors.success : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasResume ? 'Resume Uploaded' : 'Resume Not Uploaded',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasResume ? AppColors.success : Colors.black54,
                    ),
                  ),
                  if (hasResume)
                    const Text(
                      'Your CV is ready for applications',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Upload/Change Button
        _buildActionButton(
          text: hasResume ? 'View/Change Resume' : 'Upload Resume',
          icon: hasResume ? Icons.visibility_outlined : Icons.upload_file,
          onPressed: () {
            context.push(RouteNames.profileResume);
          },
        ),
      ],
    );
  }

  // ========== SECTION 3: PROFESSIONS ==========
  Widget _buildProfessionsSection(
      BuildContext context, UserProvider userProvider) {
    // Use local state variable from API instead of UserProvider
    final profession = _profession ?? 'Not selected';

    return _buildProfileSection(
      title: 'Professions',
      icon: Icons.work_outline,
      children: [
        // Current Profession
        _buildInfoRow(
          label: 'Current Profession',
          value: profession,
          icon: Icons.medical_services,
        ),

        // Specialization
        if (_speciality != null && _speciality!.isNotEmpty)
          _buildInfoRow(
            label: 'Specialization',
            value: _speciality,
            icon: Icons.school,
          ),

        // Academic Status
        if (_academicStatus != null && _academicStatus!.isNotEmpty)
          _buildInfoRow(
            label: 'Academic Status',
            value: _academicStatus,
            icon: Icons.menu_book,
          ),

        // Work Experience
        if (_workExperience != null && _workExperience!.isNotEmpty)
          _buildInfoRow(
            label: 'Work Experience',
            value: _workExperience,
            icon: Icons.business_center,
          ),

        // Clinical/Non-clinical
        if (_clinicalNonclinical != null && _clinicalNonclinical!.isNotEmpty)
          _buildInfoRow(
            label: 'Type',
            value: _clinicalNonclinical,
            icon: Icons.category,
          ),

        const SizedBox(height: 16),

        // Change Profession Button
        _buildActionButton(
          text: 'Change Profession',
          icon: Icons.swap_horiz,
          onPressed: () {
            context.push('/profession-selection?flow=profile');
          },
        ),
      ],
    );
  }

  // ========== SECTION 4: SETTINGS & SUPPORT ==========
  Widget _buildSettingsSupportSection(
      BuildContext context, UserProvider userProvider) {
    return _buildProfileSection(
      title: 'Settings & Support',
      icon: Icons.settings_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () {
            context.push(RouteNames.userPrivacyPolicy);
          },
        ),
        const Divider(height: 1, indent: 56),

        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms & Conditions'),
          onTap: () {
            context.push(RouteNames.userTermsAndConditions);
          },
        ),
        const Divider(height: 1, indent: 56),

        /// 🔹 Help & Support (Expandable)
        ExpansionTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.only(left: 56),
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email Support'),
              onTap: _launchEmailSupport,
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text('Call Support'),
              onTap: _launchCallSupport,
            ),
          ],
        ),

        const Divider(height: 1, indent: 56),

        ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text('Saved Jobs'),
          onTap: () {
            context.push(RouteNames.myJobs);
          },
        ),
        const Divider(height: 1, indent: 56),

        ListTile(
          leading: const Icon(
            Icons.logout,
            color: AppColors.error,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: AppColors.error),
          ),
          onTap: () {
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }


  // ========== HELPER WIDGETS ==========

  /// Reusable section container
  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Info row widget
  Widget _buildInfoRow({
    required String label,
    String? value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Not provided',
                  style: TextStyle(
                    fontSize: 16,
                    color: value != null ? Colors.black87 : Colors.black38,
                    fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Action button widget
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Menu item widget for settings section
 
  // ========== HELPER METHODS ==========

  String _getInitials(String name) {
    if (name.isEmpty) return 'G';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length < 4) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }

  ImageProvider? _buildProfileImageProvider() {
    // Use local state variable from API
    if (_photoId != null && _photoId!.isNotEmpty) {
      // Check if it's already a full URL
      if (_photoId!.startsWith('http')) {
        return NetworkImage(_photoId!);
      }
      // Otherwise, construct URL from photoId
      return NetworkImage('https://api.joinmeds.in/api/images/$_photoId');
    }
    return null;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Perform logout
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();

              // Navigate to login screen
              if (context.mounted) {
                context.go(RouteNames.loginPage);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _launchEmailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'joinmedsofficial@gmail.com',
      queryParameters: {
        'subject': 'Support Request',
      },
    );

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }


  Future<void> _launchCallSupport() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '8086664415',
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
