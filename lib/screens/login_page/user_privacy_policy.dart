import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class UserPrivacyPolicy extends StatelessWidget {
  const UserPrivacyPolicy({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: mainBlue,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Effective Date: 15/09/2025",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            _buildSectionTitle("1. Introduction"),
            _buildParagraph(
                "Welcome to JoinMeds, a mobile application and online platform designed to assist medical professionals in their job search. Your privacy is of the utmost importance to us. This Privacy Policy explains how JoinMeds ('we,' 'us,' or 'our') collects, uses, shares, and protects the personal data of medical professionals ('users,' 'you') who use our services. By using the JoinMeds app, you agree to the collection and use of your data in accordance with this policy."),

            _buildSectionTitle("2. Data We Collect"),
            _buildBullet(
                "Personal Identification and Contact Information: This includes your full name, email address, phone number, and residential address."),
            _buildBullet(
                "Professional Information: This includes your resume/CV, educational background, professional licenses and certifications, work experience, specializations, professional affiliations, and other data you provide to build your professional profile."),
            _buildBullet(
                "Sensitive Personal Data: We may collect sensitive personal data as defined under applicable laws, including HIPAA, GDPR, and DPDP Act. This includes professional licenses, criminal background checks (where legally required and with your explicit consent), medical records, and other necessary data. We handle this data with the highest level of care and security."),
            _buildBullet(
                "Usage Data: We may collect information about how you access and use the app, including device IP, type, OS, pages visited, time spent, and other usage statistics."),

            _buildSectionTitle("3. How We Use Your Data"),
            _buildBullet(
                "To Provide and Maintain Our Service: We use your data to create and manage your profile, process job applications, and provide relevant job opportunities."),
            _buildBullet(
                "To Connect You with Third-Party Employers: We share your profile and job-related data with Third Parties who use our platform to find suitable candidates."),
            _buildBullet(
                "To Improve Our Service: We may use aggregated, anonymized data to analyze trends, track effectiveness, and improve user experience."),
            _buildBullet(
                "To Communicate with You: We may send notifications about job opportunities, profile updates, and service-related communications."),
            _buildBullet(
                "For Legal and Compliance Purposes: We may use your data to comply with legal obligations, resolve disputes, and enforce agreements."),

            _buildSectionTitle("4. Data Sharing and Disclosure"),
            _buildBullet(
                "Employers and Recruiters: We will share your resume, professional profile, and application-related information with potential employers and recruiters."),
            _buildBullet(
                "Service Providers: We may share data with providers who assist us (e.g., cloud hosting, analytics, background checks). They are contractually obligated to protect your data."),
            _buildBullet(
                "Legal Compliance: We may disclose data if required by law or in response to valid requests by public authorities."),

            _buildSectionTitle("5. Your Privacy Rights"),
            _buildBullet("Right to Access – request a copy of your personal data."),
            _buildBullet("Right to Rectification – request corrections of inaccurate data."),
            _buildBullet(
                "Right to Erasure (Right to be Forgotten) – request deletion under certain conditions."),
            _buildBullet("Right to Restrict Processing – request limited data processing."),
            _buildBullet(
                "Right to Data Portability – receive your data in machine-readable format."),
            _buildBullet("Right to Object – object to processing, especially for marketing."),
            _buildBullet(
                "Right to Withdraw Consent – withdraw consent anytime."),
            _buildBullet(
                "Right to Nominate (as per DPDP Act) – nominate someone to exercise your rights on your behalf in case of death or incapacity."),

            _buildSectionTitle("6. Data Security"),
            _buildParagraph(
                "We implement reasonable and appropriate security measures to prevent unauthorized access, disclosure, alteration, or destruction of your personal information. Methods include data encryption, secure servers, and access controls. No method is 100% secure, but we strive to protect your data."),

            _buildSectionTitle("7. Data Retention"),
            _buildParagraph(
                "We retain your personal data while your account is active or as needed to provide services, comply with legal obligations, resolve disputes, and enforce agreements. Once no longer necessary, data will be securely deleted or anonymized."),

            _buildSectionTitle("8. Changes to This Privacy Policy"),
            _buildParagraph(
                "We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated 'Effective Date'. Please review periodically."),

            _buildSectionTitle("9. Contact Us and Grievance Officer"),
            _buildParagraph(
                "If you have any questions, concerns, or grievances, contact our designated Grievance Officer:"),
            _buildParagraph(
                "Name: Sam Oommen\nEmail: medlandplacementservices@gmail.com\nPhone: +919035002005"),
          ],
        ),
      ),
    );
  }
}
