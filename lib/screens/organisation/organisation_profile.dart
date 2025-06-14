import 'package:flutter/material.dart';
import '../../constants/constant.dart';
import '../../constants/organisation_datas.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrganisationProfile(),
  ));
}

class OrganisationProfile extends StatefulWidget {
  const OrganisationProfile({super.key});

  @override
  State<OrganisationProfile> createState() => _OrganisationProfileState();
}

class _OrganisationProfileState extends State<OrganisationProfile> {
  String _selectedJobStatus = 'Open';

  void _handleJobStatusChanged(String value) {
    setState(() {
      _selectedJobStatus = value;
      debugPrint('Selected Job Status: $_selectedJobStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    final organisationName = OrganisationNameData().organisationName;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: mainBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      organisationName.isNotEmpty
                          ? organisationName[0].toUpperCase()
                          : '',
                      style: const TextStyle(fontSize: 30, color: mainBlue),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    organisationName,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.person, 'View Profile', () {
              Navigator.pushNamed(context, '/organisation_view_profile');
            }),
            _buildDrawerItem(Icons.edit, 'Edit Profile', () {
              Navigator.pushNamed(context, '/organisation_edit_profile');
            }),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.pushNamed(context, '/organisation_profile_settings');
            }),

            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () {}),
          ],
        ),
      ),
      body: OrganisationProfileContent(
        selectedJobStatus: _selectedJobStatus,
        onJobStatusChanged: _handleJobStatusChanged,
      ),
    );
  }

  ListTile _buildDrawerItem(IconData? icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class OrganisationProfileContent extends StatelessWidget {
  final String selectedJobStatus;
  final ValueChanged<String> onJobStatusChanged;

  const OrganisationProfileContent({
    required this.selectedJobStatus,
    required this.onJobStatusChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: Colors.black38,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OrganisationHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // TODO: add repeated job cards here
                  JobCard(
                    selectedJobStatus: selectedJobStatus,
                    onJobStatusChanged: onJobStatusChanged,
                  ),
                  JobCard(
                    selectedJobStatus: selectedJobStatus,
                    onJobStatusChanged: onJobStatusChanged,
                  ),

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: inputBorderClr)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            OrganisationNameData().organisationName,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: inputBorderClr,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 40),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String selectedJobStatus;
  final ValueChanged<String> onJobStatusChanged;

  const JobCard({
    required this.selectedJobStatus,
    required this.onJobStatusChanged,
    super.key,
  });

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
        children: [
          const JobTitleHeader(),
          const JobInfo(),
          const SizedBox(height: 10),
          JobStatusSelector(
            selectedValue: selectedJobStatus,
            onChanged: onJobStatusChanged,
          ),
          const SizedBox(height: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Doctor MBBS & MD',
            style: TextStyle(fontSize: 22, color: Colors.white),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert, size: 35, color: Colors.white),
              onPressed: () async {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

                final selected = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + button.size.height,
                    overlay.size.width - position.dx - button.size.width,
                    0,
                  ),
                  items: const [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Text('View Details',style: TextStyle(fontSize: 16),),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit Job',style: TextStyle(fontSize: 16),),
                    ),
                  ],
                );

                if (selected == 'view') {
                  Navigator.pushNamed(context, '/organisation_view_job_details');
                } else if (selected == 'edit') {
                  Navigator.pushNamed(context, '/organisation_edit_job');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobInfo extends StatelessWidget {
  const JobInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hospital Name', style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
          Text('Posted : 21 January 2025', style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Text('Year of Experience : 2 years', style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Text('Skills Required : Surgeon', style: TextStyle(fontSize: 16)),
          SizedBox(height: 5),
          Text('Job Location : Thiruvananthapuram, Kerala', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class JobStatusSelector extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const JobStatusSelector({
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Job Status:',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['Open', 'Pause', 'Close'].map((status) {
            return Row(
              children: [
                Radio<String>(
                  value: status,
                  groupValue: selectedValue,
                  onChanged: (value) => onChanged(value!),
                ),
                Text(status, style: const TextStyle(fontSize: 16)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
