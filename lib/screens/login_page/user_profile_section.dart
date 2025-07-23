import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  PersonalDataModel? _personalData;
  String? _userId;
  String? _photoId;
  String? _profession;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _photoId = prefs.getString('photoId');
    _profession = prefs.getString('profession');

    if (_userId != null && _userId!.isNotEmpty) {
      final data = await PersonalDataService.getPersonalData(_userId!);
      if (data != null) {
        setState(() => _personalData = data);
      }
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Widget bottomSheet() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Upload your Profile Picture', style: subHeadForms, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(Icons.camera_alt, "Camera", mainBlue, () => takePhoto(ImageSource.camera)),
              _buildOptionButton(Icons.image, "Gallery", const Color(0xffFF6F61), () => takePhoto(ImageSource.gallery)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _personalData?.fullname ?? '---';
    final profession = _personalData?.profession ?? '---';
    final academicStatus = _personalData?.academicStatus ?? '---';
    final emailOrPhone = _personalData?.emailOrPhone ?? '---';
    final photoUrl = (_photoId?.isNotEmpty ?? false)
        ? "https://api.joinmeds.in/api/images/$_photoId"
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: mainBlue,
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _personalData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(File(_imageFile!.path), width: 180, height: 180, fit: BoxFit.cover)
                          : (photoUrl != null)
                          ? Image.network(photoUrl,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Image.asset(profileDefaultImg, width: 180, height: 180, fit: BoxFit.cover))
                          : Image.asset(profileDefaultImg, width: 180, height: 180, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: mainBlue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () => showModalBottomSheet(context: context, builder: (_) => bottomSheet()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildField("Name", name),
            _buildField("Profession", profession),
            _buildField("Academic Status", academicStatus),
            _buildField("Email / Phone Number", emailOrPhone),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 18, color: inputBorderClr)),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: mainBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    (_personalData?.fullname?.isNotEmpty ?? false)
                        ? _personalData!.fullname![0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 30, color: mainBlue),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_personalData?.fullname ?? 'User Name', style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.edit, 'Edit Profile', () {
            Navigator.pushNamed(context, '/personal_data');
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileSettings()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', () {
            _showLogoutConfirmation(context);
          }),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/logOut_loading',
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
