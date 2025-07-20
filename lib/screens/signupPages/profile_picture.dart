import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/widgets/main_button.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  XFile? _imageFile;
  String? _userId;
  String?_photoId;
  String? _serverImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    final photoId = prefs.getString('photoId'); // get from login state

    if (id != null) {
      setState(() {
        _userId = id;
        _photoId = photoId; // ✅ store it in state
      });

      if (_photoId != null && _photoId!.isNotEmpty) {
        await loadExistingProfileImage(_photoId!);
      } else {
        debugPrint('No photoId found in login state.');
      }
    }
  }

  Future<void> loadExistingProfileImage(String photoId) async {
    final imageUrl = 'https://api.joinmeds.in/api/images/$photoId';


    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      setState(() {
        _serverImageUrl = imageUrl;
      });
    } else {
      debugPrint('No existing profile image found. photoId=$photoId');
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.length();

      debugPrint('Image size: $bytes bytes');
      debugPrint('Image size: ${(bytes / 1024).toStringAsFixed(2)} KB');
      debugPrint('Image size: ${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB');

      setState(() {
        _imageFile = pickedFile;
        _serverImageUrl = null; // Hide server image once new one is selected
      });
    }
  }

  Future<bool> uploadProfileImage(String userId) async {
    if (_imageFile == null) return false;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.joinmeds.in/api/images/upload/$userId'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));

    final response = await request.send();
    debugPrint('Image size should below 1 MB: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Widget bottomSheet() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Upload your Profile Picture', style: subHeadForms, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(Icons.camera_alt, "Open Camera", mainBlue, () => takePhoto(ImageSource.camera)),
              _buildOptionButton(Icons.image, "Open Gallery", const Color(0xffFF6F61), () => takePhoto(ImageSource.gallery)),
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

  Widget buildProfileImageWidget() {
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
                      child: ClipOval(child: buildProfileImageWidget()),
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
                            builder: (context) => bottomSheet(),
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
                      text: 'Next',
                      onPressed: () async {
                        if (_imageFile == null && _serverImageUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please upload a profile picture first!'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (_imageFile != null && _userId != null) {
                          bool success = await uploadProfileImage(_userId!);
                          if (success) {
                            Navigator.pushNamed(context, '/resume_upload');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image size should below 1 MB'),
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
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.all(15)),
                        side: WidgetStatePropertyAll(BorderSide(color: mainBlue, width: 3)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
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
