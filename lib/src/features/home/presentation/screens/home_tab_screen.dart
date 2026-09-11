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

  /// Distance from the bottom (in logical pixels) at which the next page is
  /// requested, so it is ready before the user actually hits the end.
  static const double _loadMoreThreshold = 400;

  final ScrollController _scrollController = ScrollController();

  /// Prevents several scroll events in the same frame from each queueing a
  /// page; the post-frame re-check decides whether another page is needed.
  bool _loadMoreQueued = false;

  /// Job count at the last build, used to re-check after each new page lands.
  int _lastRenderedJobCount = -1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔑 ENSURE USER DATA IS READY FOR HOME HEADER
      await context.read<UserProvider>().ensureUserLoadedForHome();

      // Existing home logic (UNCHANGED)
      await _loadHomeData();
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

  /// ===== PROFILE IMAGE BUILDER =====
  ImageProvider? _buildHomeProfileImage(UserProvider userProvider) {
    final photoId = userProvider.profileImageUrl;

    if (photoId != null && photoId.isNotEmpty) {
      if (photoId.startsWith('http')) {
        return NetworkImage(photoId);
      }
      return NetworkImage('https://api.joinmeds.in/api/images/$photoId');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Color kLightBlueBg = const Color(0xFFD6F3FF);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildCompleteProfileFab(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryBlue,
        child: Consumer2<HomeProvider, UserProvider>(
          builder: (context, homeProvider, userProvider, child) {
            final imageProvider =
            _buildHomeProfileImage(userProvider);

            _scheduleFillCheck(homeProvider);

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ================= USER INFO HEADER =================
                SliverToBoxAdapter(
                  child: Container(
                    color: kLightBlueBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),

                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // ===== AVATAR =====
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipOval(
                                  child: imageProvider != null
                                      ? Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 28,
                                      );
                                    },
                                  )
                                      : const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // ===== USER NAME =====
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                      userProvider.fullName?.isNotEmpty ==
                                          true
                                          ? userProvider.fullName!
                                          : userProvider.isLoading
                                          ? 'Loading...'
                                          : 'User',
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
                                  border: Border.all(
                                      color: Colors.black12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.black87,
                                  ),
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

                // ================= SEARCH BAR =================
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SearchBarWithFilter(
                          onTap: () => context.push('/home/search'),
                          onFilterTap: () =>
                              context.push('/home/filters'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ================= JOB LIST =================
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16),
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

                const SliverToBoxAdapter(
                    child: SizedBox(height: 16)),

                _buildJobList(homeProvider),

                _buildLoadMoreFooter(homeProvider),

                const SliverToBoxAdapter(
                    child: SizedBox(height: 80)),
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
            context.push('/profession-selection?flow=profile');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.sentiment_dissatisfied,
                  color: Colors.red, size: 28),
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

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  /// Loads the next page when the user is near the bottom of the list.
  ///
  /// Runs on every scroll *and* after every new page renders (see
  /// [_scheduleFillCheck]), so loading keeps going on its own when the jobs
  /// don't yet fill the screen or a fling lands past the end -- a scroll-only
  /// trigger would stall in both cases.
  void _maybeLoadMore() {
    if (!mounted || _loadMoreQueued || !_scrollController.hasClients) return;

    final homeProvider = context.read<HomeProvider>();
    if (!homeProvider.hasMoreJobs ||
        homeProvider.isLoadingJobs ||
        homeProvider.isLoadingMoreJobs) {
      return;
    }

    if (_scrollController.position.extentAfter >= _loadMoreThreshold) return;

    _loadMoreQueued = true;
    // Deferred so the provider never notifies from inside a scroll/layout
    // callback.
    Future.microtask(() async {
      try {
        if (mounted) await homeProvider.loadMoreJobs();
      } finally {
        _loadMoreQueued = false;
      }
    });
  }

  /// After a page of jobs is laid out, check whether the list still ends
  /// inside the viewport and, if so, load the next page without waiting for a
  /// scroll gesture.
  void _scheduleFillCheck(HomeProvider homeProvider) {
    final count = homeProvider.recommendedJobs.length;
    if (count == _lastRenderedJobCount) return;
    _lastRenderedJobCount = count;

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  Widget _buildLoadMoreFooter(HomeProvider homeProvider) {
    if (homeProvider.recommendedJobs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (homeProvider.hasMoreJobs) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "You've seen all ${homeProvider.totalJobCount} jobs",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(HomeProvider homeProvider) {
    if (homeProvider.isLoadingJobs &&
        homeProvider.recommendedJobs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryBlue),
        ),
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
                isApplied: jobId != null
                    ? homeProvider.isJobApplied(jobId)
                    : false,
                isApplying: jobId != null
                    ? homeProvider.isApplyingToJob(jobId)
                    : false,
                onTap: () {
                  if (jobId == null) return;
                  context.push('/job-details/$jobId');
                },
                onApplyTap: () {},
              ),
            );
          },
          childCount: homeProvider.recommendedJobs.length,
        ),
      ),
    );
  }
}
