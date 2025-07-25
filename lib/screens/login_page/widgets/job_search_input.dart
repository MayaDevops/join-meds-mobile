import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/widgets/main_button.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Job Title Section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              color: Color(0xFFF5F5F5),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline, color: Colors.black54, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job['hiringFor'] ?? 'Job Title',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Job Info Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization Name
                Row(
                  children: [
                    const Icon(Icons.business, size: 18, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job['orgName'] ?? 'Organization',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags (Salary and Job Type)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (job['payFrom'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'From ₹${job['payFrom']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            job['jobType'] ?? 'Full-time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // View Details Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: ElevatedButton(
              onPressed: () async {
                await _saveJobToPrefs(job);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserViewJobDetails(jobId: job['id']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'View Job Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                FocusScope.of(context).unfocus();
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
