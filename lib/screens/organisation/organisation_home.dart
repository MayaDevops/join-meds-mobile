import 'package:flutter/material.dart';
import 'package:untitled/screens/organisation/about_organisation.dart';
import 'package:untitled/screens/organisation/organisation_profile.dart';
import '../../constants/constant.dart';
import '../../constants/organisation_datas.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrganisationHome(),
  ));
}

class OrganisationHome extends StatefulWidget {
  const OrganisationHome({super.key});

  @override
  State<OrganisationHome> createState() => _OrganisationHomeState();
}

class _OrganisationHomeState extends State<OrganisationHome> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    OrganisationHomeContent(),
    AddJobPage(),
    ContactPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: RichText(
          text: const TextSpan(
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
        actions:  [
          InkWell(
            onTap: (){
              Navigator.pushNamed(context, 'organisation_notifications');
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.notifications, color: Colors.black),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xffD9D9D9),
        selectedItemColor: mainBlue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 16),
        selectedIconTheme: const IconThemeData(size: 35),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Add Job'),
          BottomNavigationBarItem(
              icon: Icon(Icons.messenger), label: 'Contact'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Profile'),
        ],
      ),
    );
  }
}

// =================== Pages ===================

class OrganisationHomeContent extends StatelessWidget {
  const OrganisationHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: Colors.black38,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            OrganisationHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // TODO: jobs cards here
                  JobCard(),
                  JobCard(),
                  JobCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganisationHeader extends StatelessWidget {
  const OrganisationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: inputBorderClr)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        OrganisationNameData().organisationName,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: inputBorderClr,
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: const Color(0xffC1C1C1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          JobTitleHeader(),
          JobInfo(),
          JobTagsRow(),
          SizedBox(height: 20),
          JobActionButtons(),
        ],
      ),
    );
  }
}

class JobTitleHeader extends StatelessWidget {
  const JobTitleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: mainBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
        border: Border(bottom: BorderSide(width: 3, color: Color(0xffC1C1C1))),
      ),
      child: const Text(
        'Doctor MBBS & MD',
        style: TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }
}

class JobInfo extends StatelessWidget {
  const JobInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hospital Name', style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
          Text('Posted : 21 January 2025', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class JobTagsRow extends StatelessWidget {
  const JobTagsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: const [
          JobTag(text: 'From ₹800 an hour'),
          SizedBox(width: 10),
          JobTag(text: 'Full-time'),
        ],
      ),
    );
  }
}

class JobTag extends StatelessWidget {
  final String text;
  const JobTag({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff606060),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
  }
}

class JobActionButtons extends StatelessWidget {
  const JobActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: InkWell(
              onTap: (){
                Navigator.pushNamed(context, '/organisation_edit_job');
              },
                child: const ActionButton(
                    label: 'Edit', color: mainBlue, isLeft: true),),),
        const Expanded(
            child: ActionButton(
                label: 'Remove', color: Colors.red, isLeft: false)),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLeft;

  const ActionButton({
    required this.label,
    required this.color,
    required this.isLeft,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          bottomLeft: isLeft ? const Radius.circular(7) : Radius.zero,
          bottomRight: isLeft ? Radius.zero : const Radius.circular(7),
        ),
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}

// ================= Placeholder Pages =================

class AddJobPage extends StatelessWidget {
  const AddJobPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutOrganisation();
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Contact Page"));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OrganisationProfile();
  }
}
