import 'package:flutter/material.dart';
import '../../constants/constant.dart';

class UserTermsAndCondition extends StatelessWidget {
  const UserTermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        titleSpacing: 16,
        automaticallyImplyLeading: true,
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
      body: const TermsContent(),
    );
  }
}

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  Text _heading(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: mainBlue,
    ),
  );

  Text _paragraph(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, height: 1.5),
  );

  Widget _bullet(String text) => Padding(
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paragraph("Effective Date: 15/09/2025"),
          _paragraph("Last Updated: 15/09/2025"),
          const SizedBox(height: 12),
          _paragraph(
              'These Terms of Service ("Terms") govern your access to and use of the mobile application ("App") JoinMeds provided by MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED ("we", "our", or "us"). By accessing or using the App, you agree to be bound by these Terms.'),
          const SizedBox(height: 20),

          _heading("1. Eligibility"),
          _paragraph(
              "You must be at least 18 years old to use the App. By registering, you confirm that you meet this requirement and that all information provided is accurate and truthful."),
          const SizedBox(height: 16),

          _heading("2. Account Registration and Security"),
          _paragraph(
              "You are responsible for maintaining the confidentiality of your login credentials."),
          _paragraph("You agree to notify us immediately of any unauthorized use of your account."),
          _paragraph(
              "We reserve the right to suspend or terminate accounts that violate these Terms or our Privacy Policy."),
          const SizedBox(height: 16),

          _heading("3. Use of the App"),
          _paragraph("You agree to use the App only for lawful and professional purposes, including:"),
          _bullet("Creating and updating your professional profile"),
          _bullet("Uploading resumes and career-related content"),
          _bullet("Connecting with other professionals and recruiters"),
          _paragraph("You must not:"),
          _bullet("Post false, misleading, or offensive content"),
          _bullet("Harass, spam, or solicit other users"),
          _bullet("Use automated tools to scrape or extract data"),
          const SizedBox(height: 16),

          _heading("4. Content Ownership and License"),
          _paragraph(
              "You retain ownership of the content you upload (e.g., resume, profile details)."),
          _paragraph(
              "By uploading content, you grant MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED a non-exclusive, royalty-free license to use, display, and distribute your content within the App for networking and recruitment purposes."),
          const SizedBox(height: 16),

          _heading("5. Intellectual Property"),
          _paragraph(
              "All intellectual property rights in the App, including design, code, and branding, are owned by MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED. You may not copy, modify, or distribute any part of the App without prior written consent."),
          const SizedBox(height: 16),

          _heading("6. Account Deletion"),
          _paragraph("You may delete your account at any time via the App settings. Upon deletion:"),
          _bullet("Your data will be removed from active systems within 30 days"),
          _bullet("Backup data may be retained for up to 90 days"),
          _bullet("You will lose access to all features and connections"),
          const SizedBox(height: 16),

          _heading("7. Data Protection and Privacy"),
          _paragraph(
              "Your personal data is handled in accordance with our Privacy Policy. We comply with the Digital Personal Data Protection Act, 2023 and other applicable Indian laws."),
          const SizedBox(height: 16),

          _heading("8. Termination"),
          _paragraph("We may suspend or terminate your access to the App if:"),
          _bullet("You violate these Terms or applicable laws"),
          _bullet("Your account remains inactive for an extended period"),
          _bullet("We discontinue the App or its services"),
          const SizedBox(height: 16),

          _heading("9. Limitation of Liability"),
          _paragraph("MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED shall not be liable for:"),
          _bullet("Any indirect or consequential damages"),
          _bullet("Loss of data or business opportunities"),
          _bullet("Actions of third-party recruiters or users"),
          const SizedBox(height: 16),

          _heading("10. Indemnification"),
          _paragraph(
              "You agree to indemnify and hold MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED harmless from any claims, damages, or liabilities arising from your use of the App or violation of these Terms."),
          const SizedBox(height: 16),

          _heading("11. Governing Law and Dispute Resolution"),
          _paragraph(
              "These Terms shall be governed by the laws of India. Any disputes shall be resolved through arbitration under the Arbitration and Conciliation Act, 1996, with the seat of arbitration in Trivandrum, Kerala."),
          const SizedBox(height: 16),

          _heading("12. Disclaimer"),
          _paragraph(
              "The App is provided on an \"as-is\" and \"as-available\" basis. We do not guarantee uninterrupted access, accuracy of job listings, or success in employment outcomes."),
          _paragraph(
              "MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED does not verify the authenticity of every recruiter or job post. Users are advised to conduct their own due diligence before engaging with third parties."),
          _paragraph(
              "We are not responsible for any loss, damage, or harm resulting from interactions between users or from reliance on content posted within the App."),
          _paragraph(
              "MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED disclaims all warranties, express or implied, including but not limited to merchantability, fitness for a particular purpose, and non-infringement."),
          const SizedBox(height: 16),

          _heading("13. Community Guidelines"),
          _paragraph(
              "To maintain a safe and professional environment, all users must adhere to the following:"),
          _bullet("Be respectful: Treat others with courtesy and professionalism."),
          _bullet("Be authentic: Use your real identity and provide accurate information."),
          _bullet("No harassment: Do not engage in bullying, hate speech, or discriminatory behavior."),
          _bullet("No spam or solicitation: Avoid sending unsolicited messages or promotional content."),
          _bullet("Report violations: Use the in-app reporting tools to flag inappropriate behavior or content."),
          _paragraph(
              "Violations of these guidelines may result in warnings, suspension, or permanent account termination."),
          const SizedBox(height: 16),

          _heading("14. Changes to Terms"),
          _paragraph(
              "We may update these Terms from time to time. Continued use of the App after changes implies acceptance of the revised Terms."),
          const SizedBox(height: 16),

          _heading("15. Contact Us"),
          _paragraph(
              "MEDLAND EDUCATION AND PLACEMENT SERVICE PRIVATE LIMITED\nICONIC ARCADE,\nFIRST FLOOR,\nKALLUVATHUKKAL, KOLLAM,\nKOLLAM-691578, KERALA\nPhone: 7558885566"),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
