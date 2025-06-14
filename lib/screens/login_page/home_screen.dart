import 'package:flutter/material.dart';
import 'package:untitled/screens/login_page/my_jobs_screen.dart';
import 'package:untitled/screens/login_page/user_notification.dart';
import '../../constants/constant.dart';
import 'widgets/job_search_input.dart';
import '../login_page/user_profile_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    MyJobsScreen(),
    UserNotification(),
    UserProfileSection(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffD9D9D9),
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: const Text.rich(
        TextSpan(
          text: 'Join',
          style: TextStyle(fontSize: 22, color: Colors.black),
          children: [
            TextSpan(
              text: 'Meds',
              style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
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
          const DrawerHeader(
            decoration: BoxDecoration(color: mainBlue),
            child: Center(
              child: Text(
                'Welcome!',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3); // Go to UserProfileSection
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Add logout logic here
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: const Color(0xffD9D9D9),
      selectedItemColor: mainBlue,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 16),
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      iconSize: 28,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'My Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset('images/banner-home.jpg', fit: BoxFit.cover),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Enter job title", style: TextStyle(fontSize: 18)),
        ),
        const JobSearchInput(),
      ],
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Contact Page", style: TextStyle(fontSize: 18)),
    );
  }
}
