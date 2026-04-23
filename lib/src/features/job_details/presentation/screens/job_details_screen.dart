import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled/src/features/job_details/presentation/widgets/icon_card.dart';

import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../core/router/route_names.dart';
import '../providers/job_details_providers.dart';
import '../widgets/expandable_tile.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key, required this.jobId});
  final String jobId;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();

    /// Fetch job details once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobDetailsProvider>().fetchJobDetails(widget.jobId);
    });
  }

  void _showIncompleteProfileDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Profile Incomplete'),
          ],
        ),
        content: const Text(
          'Your profile is incomplete. Please fill in all required details '
          '(full name, date of birth, email, phone, address, Aadhaar number, '
          'profession, academic status, work experience, and resume) before applying for jobs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go(RouteNames.profile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff00AEEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Consumer<JobDetailsProvider>(
        builder: (context, provider, _) {
          /// ================= LOADING =================
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// ================= ERROR =================
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchJobDetails(
                        widget.jobId,
                        forceRefresh: true,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          /// ================= SUCCESS =================
          final JobDetailsDTO job = provider.jobDetails!;

          return Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff00AEEF), Color(0xff0095DA)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white)),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            job.hiringFor ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.orgName ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// LOGO
                      Image.asset(
                        "assets/v2/images/icons/profile.png",
                        height: 80,
                      ),
                      const SizedBox(height: 12),

                      /// TITLE
                      Text(
                        job.hiringFor ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${job.jobDesc ?? ''} · ${job.createdAt ?? ''}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// INFO CARDS
                      GridView.count(
                        crossAxisCount: size.width > 400 ? 2 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.4,
                        children: [
                          InfoCard(
                            icon: Icons.work,
                            title: "Experience needed",
                            value: job.yearExp ?? '-',
                          ),
                          InfoCard(
                            icon: Icons.currency_rupee,
                            title: "Expected Salary",
                            value: job.payFrom ?? '',
                          ),
                          InfoCard(
                            icon: Icons.access_time,
                            title: "Working Hours",
                            value: job.natureJob ?? '-',
                          ),
                          InfoCard(
                            icon: Icons.group,
                            title: "Pay range",
                            value: job.payRange ?? 'All',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// ABOUT HOSPITAL
                      ExpandableTile(
                        title: "About Hospital",
                        content: job.orgName ?? '-',
                      ),

                      const SizedBox(height: 12),

                      /// JOB REQUIREMENTS
                      ExpandableTile(
                        title: "Job Requirements",
                        content: job.skills ?? '-',
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      /// APPLY BUTTON
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        color: Colors.white,
        child: Consumer<JobDetailsProvider>(
          builder: (context, provider, _) {
            return ElevatedButton(
              onPressed: provider.isApplying
                  ? null
                  : () async {
                      final userProvider = context.read<UserProvider>();
                      if (!userProvider.isProfileComplete) {
                        _showIncompleteProfileDialog();
                        return;
                      }

                      final messenger = ScaffoldMessenger.of(context);
                      final success = await provider.applyForJob();

                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Job applied successfully'
                                : provider.applyError ?? 'Apply failed',
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xff00AEEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isApplying
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Apply",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
      ),
    );
  }
}

