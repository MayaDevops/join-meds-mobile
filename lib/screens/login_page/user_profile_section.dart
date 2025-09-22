import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../api/personal_data_service.dart';
import '../../models/personal_data_model.dart';
import '../login_page/user_profile_settings.dart';

class UserProfileSection extends StatefulWidget {
  const UserProfileSection({super.key});

  @override
  State<UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<UserProfileSection> {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();
  PersonalDataModel? _personalData;
  String? _userId;
  String? _photoId;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _photoId = prefs.getString('photoId');

    final localImage = prefs.getString('localProfileImage');
    if (localImage != null && localImage.isNotEmpty && File(localImage).existsSync()) {
      _imageFile = XFile(localImage);
    }

    if (_userId != null && _userId!.isNotEmpty) {
      final data = await PersonalDataService.getPersonalData(_userId!);
      if (mounted && data != null) setState(() => _personalData = data);
    }
  }

  Future<bool> _checkAndRequestPermission(Permission permission) async {
    if (await permission.isGranted) return true;

    final status = await permission.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission permanently denied. Enable it in Settings.")),
        );
      }
      await openAppSettings();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied")),
        );
      }
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        permission = (androidInfo.version.sdkInt >= 33) ? Permission.photos : Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    if (!await _checkAndRequestPermission(permission)) return;

    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile == null) return;

      if (!mounted) return;
      setState(() => _imageFile = pickedFile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('localProfileImage', pickedFile.path);

      final photoId = await _uploadProfileImage(File(pickedFile.path));
      if (photoId != null) {
        _photoId = photoId;
        await prefs.setString('photoId', photoId);
        if (mounted) setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload profile picture.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image selection failed: $e")),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile) async {
    if (_userId == null || !imageFile.existsSync()) return null;

    try {
      final fileName = imageFile.path.split("/").last;
      final formData = FormData.fromMap({
        "userId": _userId,
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        "https://api.joinmeds.in/api/upload/profile",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      debugPrint("Upload response: ${response.data}");

      if (response.statusCode == 200) {
        final photoId = response.data["data"]?["photoId"] ?? response.data["photoId"];
        if (photoId != null) return photoId.toString();
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
    return null;
  }

  Widget _imageSourceSheet() {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Upload Profile Picture',
              style: subHeadForms,
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _optionButton(Icons.camera_alt, "Camera", mainBlue, () => _pickImage(ImageSource.camera)),
              _optionButton(Icons.image, "Gallery", Colors.orange, () => _pickImage(ImageSource.gallery)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, color: inputBorderClr)),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _drawerHeader(),
          _drawerItem(Icons.edit, 'Edit Profile', () => Navigator.pushNamed(context, '/personal_data')),
          _drawerItem(Icons.settings, 'Settings', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileSettings()))),
          const Divider(),
          _drawerItem(Icons.logout, 'Logout', _logoutConfirmation),
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    final initials = (_personalData?.fullname?.isNotEmpty ?? false) ? _personalData!.fullname![0].toUpperCase() : 'U';
    final photoUrl = (_photoId?.isNotEmpty ?? false) ? "https://api.joinmeds.in/api/images/$_photoId" : null;

    Widget avatarChild;
    if (_imageFile != null) {
      avatarChild = Image.file(File(_imageFile!.path), width: 76, height: 76, fit: BoxFit.cover);
    } else if (photoUrl != null) {
      avatarChild = Image.network(photoUrl, width: 76, height: 76, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initialsAvatar(initials));
    } else {
      avatarChild = _initialsAvatar(initials);
    }

    return DrawerHeader(
      decoration: const BoxDecoration(color: mainBlue),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: CircleAvatar(radius: 38, backgroundColor: mainBlue, child: ClipOval(child: avatarChild)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _personalData?.fullname ?? 'User Name',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsAvatar(String initials) => Center(child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)));

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );

  void _logoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/logOut_loading', (_) => false);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            const Text(
              "Complete your personal data and academic status to set a perfect profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/personal_data');
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _personalData?.fullname ?? '---';
    final profession = _personalData?.profession ?? '---';
    final dob = _personalData?.dob ?? '---';
    final emailOrPhone = _personalData?.emailOrPhone ?? '---';
    final photoUrl = (_photoId?.isNotEmpty ?? false) ? "https://api.joinmeds.in/api/images/$_photoId" : null;

    Widget profileImage;
    if (_imageFile != null) {
      profileImage = Image.file(File(_imageFile!.path), width: 180, height: 180, fit: BoxFit.cover);
    } else if (photoUrl != null) {
      profileImage = Image.network(photoUrl, width: 180, height: 180, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(profileDefaultImg, width: 180, height: 180));
    } else {
      profileImage = Image.asset(profileDefaultImg, width: 180, height: 180);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: mainBlue,
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _personalData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: inputBorderClr),
                    child: CircleAvatar(radius: 90, backgroundColor: Colors.grey.shade200, child: ClipOval(child: profileImage)),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: inputBorderClr,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () => showModalBottomSheet(context: context, builder: (_) => _imageSourceSheet()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildField("Name", name),
            _buildField("Profession", profession),
            _buildField("DOB", dob),
            _buildField("Email / Phone Number", emailOrPhone),
            const SizedBox(height: 25),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.edit, size: 25),
              label: const Text("Edit Profile"),
              onPressed: _showEditProfileSheet,
            ),
          ],
        ),
      ),
    );
  }
}
