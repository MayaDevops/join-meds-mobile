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

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId != null) {
      fetchAppliedJobs();
    }
  }

  Future<void> fetchAppliedJobs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.joinmeds.in/api/job-applied/search?userId=$userId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          appliedJobs = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: mainBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: mainBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(color: mainBlue, fontSize: 14),
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mainBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              job['hiringFor'] ?? 'hiringFor',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['orgName'] ?? 'Data Not available',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildTag('Salary Range: ${_formatSalary(job['payFrom'], job['payTo'], job['payRange'])}'),
                    ),


                  ],
                ),
                const SizedBox(height: 8),
                // Rest of the tags vertically
                _buildTag('Applied On: ${job['submittedAt']?.toString().substring(0, 10) ?? 'Date'}'),
                const SizedBox(height: 8),
                /// ✅ Horizontal scrolling tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTag('Status: ${job['status'] ?? 'N/A'}'),
                      const SizedBox(width: 7),
                      _buildTag('Job Type: ${job['natureJob'] ?? 'N/A'}'),
                      // _buildTag(job['natureJob'] ?? 'natureJob'),
                    //  _buildTag(job['submittedAt']?.toString().substring(0, 10) ?? 'Date'),
                    ],
                  ),
                ),
              ],

            ),

          ),


          // View Button
          Container(
            decoration: const BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Jobs', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appliedJobs.isEmpty
          ? const Center(child: Text("No jobs applied yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appliedJobs.length,
        itemBuilder: (context, index) => _buildJobCard(appliedJobs[index]),
      ),
    );
  }
}

String _formatSalary(dynamic payFrom, dynamic payTo, String? payRange) {
  if (payFrom == null && payTo == null) return 'N/A';
  if (payFrom != null && payTo != null) {
    return '$payFrom-$payTo/${payRange ?? "N/A"}';
  } else if (payFrom != null) {
    return '$payFrom/${payRange ?? "N/A"}';
  } else {
    return '$payTo/${payRange ?? "N/A"}';
  }
}

