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
  String? userId;
  String? orgId;
  String? resumeId;
  String? fullName;
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
      final personalData = PersonalDataModel.fromJson(json.decode(personalDataJson));
      fullName = personalData.fullname;
    }
  }

  Future<void> fetchJobDetails() async {
    final url = Uri.parse('https://api.joinmeds.in/api/org-job/fetch/${widget.jobId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is Map<String, dynamic>) {
          setState(() {
            jobData = decoded[0];
            orgId = decoded[0]['orgId'];
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format.');
        }
      } else {
        throw Exception('Failed to load job: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching job details: $e')),
      );
    }
  }

  Future<void> checkIfAlreadyApplied() async {
    if (userId == null || widget.jobId.isEmpty) return;

    final url = Uri.parse(
      'https://api.joinmeds.in/api/job-applied/search?userId=$userId&jobId=${widget.jobId}',
    );

    print('🔍 Checking if already applied...');
    print('userId: $userId');
    print('jobId: ${widget.jobId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> responseBody = json.decode(response.body);

        // Check if any application in the list has status 'APPLIED'
        bool foundApplied = responseBody.any((item) =>
        item is Map<String, dynamic> && item['status'] == 'APPLIED');

        if (foundApplied) {
          setState(() {
            isApplied = true;
          });
          print('✅ User already applied.');
        } else {
          print('ℹ️ No existing application with status APPLIED.');
        }
      } else {
        print('❌ Failed to check applications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during application check: $e');
    }
  }


  Future<void> applyToJob() async {
    if (userId == null || orgId == null || widget.jobId.isEmpty || resumeId == null ) {
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
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/job');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }

  Widget _buildLabelValue(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value?.isNotEmpty == true ? value : 'N/A'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffD9D9D9),
        automaticallyImplyLeading: true,
        titleSpacing: 16,
        title: const Text.rich(
          TextSpan(
            text: 'Join',
            style: TextStyle(fontSize: 22, color: Colors.black),
            children: [
              TextSpan(
                text: 'Meds',
                style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: mainBlue,
              child: Text(
                'Hiring For: ${jobData?['hiringFor'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            _buildLabelValue('Organization Name', jobData?['orgName']),
            _buildLabelValue('Experience Required', jobData?['yearExp']),
            _buildLabelValue('Skills', jobData?['skills']),
            _buildLabelValue('Nature of Job', jobData?['natureJob']),
            _buildLabelValue(
              'Pay Range',
              '₹${jobData?['payFrom'] ?? ''} - ₹${jobData?['payTo'] ?? ''} / ${jobData?['payRange'] ?? ''}',
            ),
            _buildLabelValue('Job Description', jobData?['jobDesc']),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.green; // ✅ Disabled state color
                      }
                      return mainBlue; // ✅ Default state color
                    },
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onPressed: isApplied ? null : applyToJob,
                child: Text(
                  isApplied ? 'Applied' : 'Apply Now',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
