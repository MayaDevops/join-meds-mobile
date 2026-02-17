import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/v2/job/job_details_dto.dart';
import '../providers/home_provider.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String value) {
    context.read<HomeProvider>().searchJobs(searchKey: value);
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jobs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search for jobs, companies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HomeProvider>().searchJobs(searchKey: '');
                    setState(() {});
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(context, value);
              },
            ),
          ),

          /// Results
          Expanded(
            child: _buildSearchResults(homeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(HomeProvider provider) {
    /// Loading
    if (provider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    /// Error
    if (provider.searchError != null) {
      return Center(
        child: Text(
          provider.searchError!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    /// Empty Search
    if (_searchController.text.trim().isEmpty) {
      return _buildEmptyPlaceholder();
    }

    /// No Results
    if (provider.searchedJobs.isEmpty) {
      return const Center(
        child: Text(
          'No jobs found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    /// Job List
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.searchedJobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = provider.searchedJobs[index];
        return _JobTile(job: job);
      },
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter keywords to find relevant positions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Job List Tile
/// ------------------------------------------------------------
class _JobTile extends StatelessWidget {
  final JobDetailsDTO job;

  const _JobTile({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          job.hiringFor ?? 'Untitled Job',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            job.orgName ?? 'Unknown Company',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          /// Navigate to job details if needed
           context.push('/job-details/${job.id}');
        },
      ),
    );
  }
}
