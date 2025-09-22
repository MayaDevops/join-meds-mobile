import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class UserProfileSettings extends StatelessWidget {
  const UserProfileSettings({super.key});

  /// List of settings options
  final List<_SettingItem> _settings = const [
    _SettingItem(
      title: 'Privacy Policy',
      route: 'user_privacy_policy',
    ),
    _SettingItem(
      title: 'Terms and Conditions',
      route: 'user_terms_and_conditions',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: RichText(
          text: const TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(
                  color: mainBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: _settings.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          color: Colors.black26,
        ),
        itemBuilder: (context, index) {
          final item = _settings[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            child: Container(
              padding:
              const EdgeInsets.only(left: 16, top: 15, bottom: 15),
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Model for each settings item
class _SettingItem {
  final String title;
  final String route;
  const _SettingItem({required this.title, required this.route});
}
