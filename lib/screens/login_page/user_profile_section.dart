import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/screens/login_page/user_profile_settings.dart';
import '../../constants/constant.dart';
import '../../constants/images.dart';

class UserProfileSection extends StatefulWidget {
  const UserProfileSection({super.key});

  @override
  State<UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<UserProfileSection> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Upload your Profile Picture',
              style: subHeadForms, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOptionButton(Icons.camera_alt, "Open Camera", mainBlue,
                      () => takePhoto(ImageSource.camera)),
              _buildOptionButton(
                  Icons.image,
                  "Open Gallery",
                  const Color(0xffFF6F61),
                      () => takePhoto(ImageSource.gallery)),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildOptionButton(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: color),
        width: 170,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 35, color: Colors.white),
            const SizedBox(height: 10),
            Text(text,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: mainBlue,
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Drawer icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: _imageFile == null
                          ? Image.asset(profileDefaultImg,
                          width: 200, height: 200, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path),
                          width: 200, height: 200, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: mainBlue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 22),
                        onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => bottomSheet()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Name",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              'John',
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Profession",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              'Doctor',
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Academic Status" ,
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              'Degree Ongoing',
              // if user is post-graduated add post graduated here. or user is phD holder add phD holder
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Email',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            Text(
              'User@gmail.com',
              style: TextStyle(fontSize: 18, color: inputBorderClr),
            ),

          ],
        ),
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
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    'U',
                    style: TextStyle(fontSize: 30, color: mainBlue),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'User Name',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          _buildDrawerItem(Icons.edit, 'Edit Profile', () {
            Navigator.pushNamed(context, '/organisation_edit_profile');
          }),
          _buildDrawerItem(Icons.settings, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileSettings()),
            );
          }),
          const Divider(),

          _buildDrawerItem(Icons.logout, 'Logout', () {
            // Add logout logic here
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
}
