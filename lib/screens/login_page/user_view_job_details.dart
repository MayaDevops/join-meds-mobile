import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constant.dart';
import '../../models/personal_data_model.dart';

class UserViewJobDetails extends StatefulWidget {
  final String jobId;
  const UserViewJobDetails({super.key, required this.jobId});

  @override
  State<UserViewJobDetails> createState() => _UserViewJobDetailsState();
}

class _UserViewJobDetailsState extends State<UserViewJobDetails> {
  Map<String, dynamic>? jobData;
  bool isLoading = true;
  String? userId, orgId, resumeId, fullName;
  bool isApplied = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo().then((_) {
      fetchJobDetails();
      checkIfAlreadyApplied();
    });
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    resumeId = prefs.getString('resumeId');
    final personalDataJson = prefs.getString('personal_data');
    if (personalDataJson != null) {
      final personalData =
      PersonalDataModel.fromJson(json.decode(personalDataJson));
      fullName = personalData.fullname;
    }
  }

  Future<void> fetchJobDetails() async {
    try {
      final url =
      Uri.parse('https://api.joinmeds.in/api/org-job/fetch/${widget.jobId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            jobData = decoded[0];
            orgId = decoded[0]['orgId'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load job');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching job: $e')),
      );
    }
  }

  Future<void> checkIfAlreadyApplied() async {
    if (userId == null || widget.jobId.isEmpty) return;

    final url = Uri.parse(
        'https://api.joinmeds.in/api/job-applied/search?userId=$userId&jobId=${widget.jobId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);
        setState(() {
          isApplied = responseBody.any((item) =>
          item is Map<String, dynamic> && item['status'] == 'APPLIED');
        });
      }
    } catch (e) {
      debugPrint('Error checking application: $e');
    }
  }

  Future<void> applyToJob() async {
    if ([userId, orgId, widget.jobId, resumeId].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing required profile details')),
      );
      return;
    }

    final applyData = {
      "userId": userId,
      "orgId": orgId,
      "jobId": widget.jobId,
      "resumeId": resumeId,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.joinmeds.in/api/job-applied/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(applyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => isApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        throw Exception('Apply failed: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application error: $e')),
      );
    }
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
          ),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : "N/A",style: TextStyle(fontSize: 18),)),
        ],
      ),
    );
  }

  Widget _buildJobCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization Name
            Text(
              jobData?['orgName'] ?? 'Organization',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: mainBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1.2, color: Colors.grey),
            const SizedBox(height: 16),

            // Job Details
            _buildItem(Icons.person, "Hiring For", jobData?['hiringFor']),
            _buildItem(Icons.work_history, "Experience", jobData?['yearExp']),
            _buildItem(Icons.build, "Skills", jobData?['skills']),
            _buildItem(Icons.accessibility_new, "Nature of Job", jobData?['natureJob']),
            _buildItem(
              Icons.attach_money,
              "Pay Range",
              '₹${jobData?['payFrom'] ?? ''} - ₹${jobData?['payTo'] ?? ''} / ${jobData?['payRange'] ?? ''}',
            ),
            _buildItem(Icons.description_outlined, "Description", jobData?['jobDesc']),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: mainBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.isNotEmpty == true ? value! : 'Not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildApplyButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isApplied
            ? const LinearGradient(colors: [Colors.green, Colors.green])
            : const LinearGradient(colors: [mainBlue, Color(0xFF045DE9)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(isApplied ? Icons.check_circle : Icons.send,color: Colors.white,),
        label: Text(
          isApplied ? 'Applied' : 'Apply Now',
          style: const TextStyle(fontSize: 16,color: Colors.white),
        ),
        onPressed: isApplied ? null : applyToJob,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        titleSpacing: 16,
        title: const Text.rich(
          TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(
                    color: mainBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            _buildJobCard(),
            _buildApplyButton(),
          ],
        ),
      ),

    );
  }
}
