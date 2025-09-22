import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constant.dart';
import '../login_page/user_view_job_details.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<dynamic> appliedJobs = [];
  String? userId;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');

    if (userId != null) {
      await fetchAppliedJobs();
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> fetchAppliedJobs() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.joinmeds.in/api/job-applied/search?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> jobs = [];

        if (decoded is List) {
          jobs = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          jobs = decoded['data'];
        }

        if (!mounted) return;
        setState(() {
          appliedJobs = jobs;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load jobs (code ${response.statusCode})');
      }
    } catch (e) {
      debugPrint("❌ Error fetching jobs: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load jobs. Please try again.')),
      );
    }
  }

  Widget _buildJobCard(dynamic job) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              job['hiringFor'] ?? 'Position',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Job Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.business, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job['orgName'] ?? 'Organization',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _colorChip(
                      Icons.monetization_on,
                      'Salary: ${_formatSalary(job['payFrom'], job['payTo'], job['payRange'])}',
                      Colors.green.shade100,
                      Colors.green.shade800,
                    ),
                    _colorChip(
                      Icons.date_range,
                      'Applied On: ${job['submittedAt']?.toString().substring(0, 10) ?? 'Date'}',
                      Colors.blue.shade100,
                      Colors.blue.shade800,
                    ),
                    _colorChip(
                      Icons.info,
                      'Status: ${job['status'] ?? 'N/A'}',
                      Colors.orange.shade100,
                      Colors.orange.shade800,
                    ),
                    _colorChip(
                      Icons.work,
                      'Type: ${job['natureJob'] ?? 'N/A'}',
                      Colors.purple.shade100,
                      Colors.purple.shade800,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Button
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserViewJobDetails(jobId: job['jobId']),
                  ),
                );
              },
              child: const Text(
                'View Details',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorChip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
automaticallyImplyLeading: false,
        title: const Text('My Jobs', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: fetchAppliedJobs,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text("Unable to load jobs. Please try again."))
            : appliedJobs.isEmpty
            ? const Center(child: Text("No jobs applied yet."))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appliedJobs.length,
          itemBuilder: (context, index) =>
              _buildJobCard(appliedJobs[index]),
        ),
      ),
    );
  }
}

String _formatSalary(dynamic payFrom, dynamic payTo, String? payRange) {
  if (payFrom == null && payTo == null) return 'N/A';
  if (payFrom != null && payTo != null) {
    return '$payFrom - $payTo / ${payRange ?? "N/A"}';
  } else if (payFrom != null) {
    return '$payFrom / ${payRange ?? "N/A"}';
  } else {
    return '$payTo / ${payRange ?? "N/A"}';
  }
}
