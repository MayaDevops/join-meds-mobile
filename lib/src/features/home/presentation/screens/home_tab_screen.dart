import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../widgets/promotional_banner_widget.dart';
import '../widgets/search_bar_with_filter.dart';
import '../widgets/job_card_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/user_provider.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    final homeProvider = context.read<HomeProvider>();
    await homeProvider.initialize();
  }

  Future<void> _refreshData() async {
    final homeProvider = context.read<HomeProvider>();
    await homeProvider.refreshHome();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Light blue background color from the design
    final Color kLightBlueBg = const Color(0xFFD6F3FF);

    return Scaffold(
      backgroundColor: Colors.white,
      // The "Complete Your Profile" bubble
      floatingActionButton: _buildCompleteProfileFab(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryBlue,
        child: Consumer2<HomeProvider, UserProvider>(
          builder: (context, homeProvider, userProvider, child) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Header Section (User Info + Banner)
                // We use SliverToBoxAdapter with a specific background container
                SliverToBoxAdapter(
                  child: Container(
                    color: kLightBlueBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 50), // SafeArea top padding

                        // User Info Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: const DecorationImage(
                                    image: NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hello',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      userProvider.fullName?.isNotEmpty == true
                                        ? userProvider.fullName!
                                        : userProvider.isLoading
                                          ? 'Loading...' // Show loading text while data is being fetched
                                          : 'User', // Fallback to 'User' if name is not available
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Notification Bell
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                  color: Colors.transparent,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Promotional Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: PromotionalBannerWidget(
                            onTap: () => context.push('/home/search'),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Decorative bottom curve for the blue section could go here
                        // For now, we just end the container and switch to white
                        Container(
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Search Bar
                // Sits on the white background
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SearchBarWithFilter(
                          onTap: () => context.push('/home/search'),
                          onFilterTap: () => context.push('/home/filters'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 3. Section Heading
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Job recommendations for you',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 4. Job List
                _buildJobList(homeProvider),

                // Bottom padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompleteProfileFab() {
    return Container(
      width: 75,
      height: 75,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            // Navigate to profession selection (same as Change Profession)
            context.push('/profession-selection?flow=profile');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 28),
              SizedBox(height: 2),
              Text(
                'Complete\nYour Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(HomeProvider homeProvider) {
    if (homeProvider.isLoadingJobs && homeProvider.recommendedJobs.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (homeProvider.recommendedJobs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No jobs found')),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final job = homeProvider.recommendedJobs[index];
            final jobId = job.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCardWidget(
                job: job,
                isApplied: jobId != null ? homeProvider.isJobApplied(jobId) : false,
                isApplying: jobId != null ? homeProvider.isApplyingToJob(jobId) : false,
                onTap: (){
                  if (jobId == null) return;
                  context.push('/job-details/$jobId');
                }, // Disabled - no navigation on card tap
                onApplyTap: () async {
                  // final error = await homeProvider.applyToJob(job);
                  // if (!context.mounted) return;
                  //
                  // if (error == null) {
                  //   // Success - show success message
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(
                  //       content: Text('Successfully applied to job!'),
                  //       backgroundColor: Colors.green,
                  //       duration: Duration(seconds: 2),
                  //     ),
                  //   );
                  // } else {
                  //   // Error - show error message
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text(error),
                  //       backgroundColor: Colors.red,
                  //       duration: const Duration(seconds: 3),
                  //     ),
                  //   );
                  // }
                },
              ),
            );
          },
          childCount: homeProvider.recommendedJobs.length,
        ),
      ),
    );
  }
}