import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_tab_provider.dart';
import '../widgets/job_card_widget.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/models/v2/job/job_applied_dto.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../../../../core/theme/app_colors.dart';

/// Jobs tab screen showing user's applied jobs
class JobsTabScreen extends StatefulWidget {
  const JobsTabScreen({super.key});

  @override
  State<JobsTabScreen> createState() => _JobsTabScreenState();
}

class _JobsTabScreenState extends State<JobsTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  Future<void> _loadJobs() async {
    final userProvider = context.read<UserProvider>();
    final jobsProvider = context.read<JobsTabProvider>();

    final userId = userProvider.userId;
    if (userId != null && userId.isNotEmpty) {
      await jobsProvider.fetchAppliedJobs(userId);
    }
  }

  Future<void> _refreshJobs() async {
    final userProvider = context.read<UserProvider>();
    final jobsProvider = context.read<JobsTabProvider>();

    final userId = userProvider.userId;
    if (userId != null && userId.isNotEmpty) {
      await jobsProvider.refresh(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Applications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<JobsTabProvider>(
        builder: (context, jobsProvider, child) {
          return Column(
            children: [
              // Filter chips
              _buildFilterChips(jobsProvider),
              const Divider(height: 1),
              // Job list
              Expanded(
                child: _buildJobList(jobsProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(JobsTabProvider jobsProvider) {
    final filters = [
      {'label': 'All', 'value': 'all', 'count': jobsProvider.totalCount},
      {'label': 'Pending', 'value': 'pending', 'count': jobsProvider.pendingCount},
      {'label': 'Accepted', 'value': 'accepted', 'count': jobsProvider.acceptedCount},
      {'label': 'Rejected', 'value': 'rejected', 'count': jobsProvider.rejectedCount},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = jobsProvider.filterStatus == filter['value'];
            final count = filter['count'] as int;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${filter['label']} ($count)',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  jobsProvider.filterByStatus(filter['value'] as String);
                },
                selectedColor: AppColors.primaryBlue,
                backgroundColor: Colors.grey.shade200,
                checkmarkColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildJobList(JobsTabProvider jobsProvider) {
    // Loading state
    if (jobsProvider.isLoading && jobsProvider.appliedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading your applications...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (jobsProvider.error != null && jobsProvider.appliedJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load applications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                jobsProvider.error!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadJobs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (jobsProvider.appliedJobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                jobsProvider.filterStatus == 'all'
                    ? 'No applications yet'
                    : 'No ${jobsProvider.filterStatus} applications',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start applying to jobs to see them here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Job list - using same style as HomeTabScreen
    return RefreshIndicator(
      onRefresh: _refreshJobs,
      color: AppColors.primaryBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: jobsProvider.appliedJobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final application = jobsProvider.appliedJobs[index];

          return JobCardWidget(
            job: _mapApplicationToJob(application),
            statusBadge: application.status,
            isApplied: true, // All jobs in this tab are already applied
            onTap: () {
              // Navigate to job details or application details
              if (application.jobId != null) {
                context.push('/home/job/${application.jobId}');
              }
            },
            onApplyTap: null, // Can't apply again - already applied
          );
        },
      ),
    );
  }

  /// Map JobAppliedDTO to JobDetailsDTO for display
  JobDetailsDTO _mapApplicationToJob(JobAppliedDTO application) {
    return JobDetailsDTO(
      id: application.jobId,
      hiringFor: application.hiringFor ?? 'Job Title',
      orgName: application.orgName ?? 'Organization',
      yearExp: null,
      skills: null,
      natureJob: application.natureJob,
      payFrom: application.payFrom,
      payTo: application.payTo,
      payRange: application.payRange,
      jobDesc: null,
      createdAt: application.submittedAt ?? application.createdAt,
    );
  }
}
