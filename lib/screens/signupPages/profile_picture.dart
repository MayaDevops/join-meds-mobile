import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants/constant.dart';
import '../../constants/images.dart';
import '../../widgets/main_button.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  XFile? _imageFile;
  String? _userId;
  String? _serverImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndPhoto();
  }

  Future<void> _loadUserIdAndPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    final photoId = prefs.getString('photoId'); // only local

    if (id != null && mounted) {
      setState(() => _userId = id);

      if (photoId != null && photoId.isNotEmpty) {
        await _loadExistingProfileImage(photoId);
      }
    }
  }

  Future<void> _loadExistingProfileImage(String photoId) async {
    final imageUrl = 'https://api.joinmeds.in/api/images/$photoId';

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200 && mounted) {
        setState(() => _serverImageUrl = imageUrl);
      }
    } catch (e) {
      debugPrint('Failed to load existing profile image: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = pickedFile;
        _serverImageUrl = null; // hide old server image
      });
    }
  }

  Future<bool> _uploadProfileImage() async {
    if (_imageFile == null || _userId == null) return false;

    setState(() => _isUploading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.joinmeds.in/api/images/upload/$_userId'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    try {
      final response = await request.send();
      setState(() => _isUploading = false);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      setState(() => _isUploading = false);
      debugPrint('Upload failed: $e');
      return false;
    }
  }

  Widget _bottomSheet() {
    return Container(
      width: double.infinity,
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
              _buildOptionButton(Icons.camera_alt, "Open Camera", mainBlue, () => _pickImage(ImageSource.camera)),
              _buildOptionButton(Icons.image, "Open Gallery", const Color(0xffFF6F61), () => _pickImage(ImageSource.gallery)),
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
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 35, color: Colors.white),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Image.file(File(_imageFile!.path), width: 200, height: 200, fit: BoxFit.cover);
    } else if (_serverImageUrl != null) {
      return Image.network(_serverImageUrl!, width: 200, height: 200, fit: BoxFit.cover);
    } else {
      return Image.asset(profileDefaultImg, width: 200, height: 200, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile Picture", style: appBarText),
        backgroundColor: mainBlue,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Image.asset(bodyBg, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Set Up Your Profile Picture to Help Others \nIdentify and Connect with You Easily',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: inputBorderClr),
                ),
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white,
                      child: ClipOval(child: _buildProfileImage()),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: mainBlue,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (_) => _bottomSheet(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MainButton(
                      text: _isUploading ? 'Uploading...' : 'Next',
                      onPressed: _isUploading
                          ? null
                          : () async {
                        if (_imageFile == null && _serverImageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload a profile picture first!'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (_imageFile != null) {
                          final success = await _uploadProfileImage();
                          if (success) {
                            Navigator.pushNamed(context, '/resume_upload');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image size should be below 1 MB'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        } else {
                          Navigator.pushNamed(context, '/resume_upload');
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
                      onPressed: () => Navigator.pushNamed(context, '/resume_upload'),
                      child: const Text('Skip for now', style: TextStyle(fontSize: 20.0, color: mainBlue)),
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
