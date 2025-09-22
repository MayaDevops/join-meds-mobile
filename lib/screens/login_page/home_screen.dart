
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/login_page/user_profile_section.dart';
import '../../constants/constant.dart';
import '../login_page/my_jobs_screen.dart';
import '../login_page/user_notification.dart';
import 'widgets/job_search_input.dart';

/// ---------------------------- HOME SCREEN ----------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: _buildPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Each time profile tab is selected, force rebuild with unique key
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const MyJobsScreen();
      case 2:
        return const UserNotification();
      case 3:
        return KeyedSubtree(key: UniqueKey(), child: const UserProfileSection());
      default:
        return const HomeTab();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffD9D9D9),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _confirmLogout(context),
        ),
      ],
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
              setState(() => _selectedIndex = 3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/logOut_loading', (_) => false);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------- HOME TAB ----------------------------

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('images/banner-home.jpg', fit: BoxFit.cover),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Enter job title", style: TextStyle(fontSize: 18)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: JobSearchInput(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}