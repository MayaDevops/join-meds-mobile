import 'package:flutter/material.dart';
import '../../constants/constant.dart'; // Adjust the path as per your project

class OrganisationNotificationPage extends StatelessWidget {
  const OrganisationNotificationPage({super.key});

  final List<Map<String, String>> orgNotifications = const [
    {
      'title': 'New Application Received',
      'message': 'A user has applied for your Doctor job post.',
      'time': 'Just now',
      'icon': '📥',
    },
    {
      'title': 'Job Post Approved',
      'message': 'Your Nurse job post is now live.',
      'time': '30 min ago',
      'icon': '✅',
    },
    {
      'title': 'Profile Verification Pending',
      'message': 'Please upload the required documents for verification.',
      'time': 'Yesterday',
      'icon': '⚠️',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organisation Notifications'),
        centerTitle: true,
        backgroundColor: mainBlue,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orgNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = orgNotifications[index];
          return NotificationCard(
            title: item['title']!,
            message: item['message']!,
            time: item['time']!,
            icon: item['icon']!,
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String icon;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(message,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(time,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
