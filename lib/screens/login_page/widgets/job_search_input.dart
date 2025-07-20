import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constant.dart';
import '../user_view_job_details.dart';

class JobSearchInput extends StatefulWidget {
  const JobSearchInput({super.key});

  @override
  State<JobSearchInput> createState() => _JobSearchInputState();
}

class _JobSearchInputState extends State<JobSearchInput> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  List<dynamic> searchResults = [];

  Future<void> searchJobs(String keyword) async {
    final uri = Uri.parse("https://api.joinmeds.in/api/org-job/list/hiring-for/$keyword");

    setState(() => isLoading = true);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          searchResults = json.decode(response.body);
        });
      } else {
        setState(() {
          searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No jobs found or server error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch jobs')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveJobToPrefs(Map<String, dynamic> job) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jobId', job['id'] ?? '');
    await prefs.setString('orgId', job['orgId'] ?? '');
    await prefs.setString('applicantName', job['hiringFor'] ?? '');
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: mainBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainBlue),
      ),
      child: Text(text, style: const TextStyle(color: mainBlue)),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mainBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              job['hiringFor'] ?? 'Job Title',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  job['orgName'] ?? 'Organization',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (job['payFrom'] != null) _buildTag('From ₹${job['payFrom']}'),
                    const SizedBox(width: 8),
                    _buildTag(job['jobType'] ?? 'Full-time'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: TextButton(
              onPressed: () async {
                await _saveJobToPrefs(job);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserViewJobDetails(jobId: job['id']),
                  ),
                );
              },
              child: const Text(
                'View Details',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Eg: Doctor, Nurse...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final keyword = _controller.text.trim();
              if (keyword.isNotEmpty) {
                searchJobs(keyword);
              }
            },
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
              backgroundColor: const WidgetStatePropertyAll(mainBlue),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            child: const Text('Search jobs', style: TextStyle(fontSize: 16.0, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (searchResults.isNotEmpty)
            ...searchResults.map((job) => _buildJobCard(job)).toList()
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
