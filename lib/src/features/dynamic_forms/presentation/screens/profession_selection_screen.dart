import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../domain/repositories/form_repository.dart';
import '../../../../shared/services/api/form_api_service.dart';

/// Profession selection screen
/// Grid of 12 professions loaded dynamically from Firebase
class ProfessionSelectionScreen extends StatefulWidget {
  final String? flowContext;

  const ProfessionSelectionScreen({
    super.key,
    this.flowContext,
  });

  @override
  State<ProfessionSelectionScreen> createState() =>
      _ProfessionSelectionScreenState();
}

class _ProfessionSelectionScreenState extends State<ProfessionSelectionScreen> {
  String? _selectedProfession;
  bool _isLoading = false;
  bool _isLoadingProfessions = true;
  String? _loadError;
  List<Map<String, String>> _professions = [];

  @override
  void initState() {
    super.initState();
    _loadProfessions();
  }

  /// Load professions from Firebase
  Future<void> _loadProfessions() async {
    setState(() {
      _isLoadingProfessions = true;
      _loadError = null;
    });

    try {
      final repository = context.read<FormRepository>();
      final professionIds = await repository.getAvailableProfessions();

      setState(() {
        _professions = professionIds.map((id) {
          return {
            'id': id,
            'name': _formatProfessionName(id),
          };
        }).toList();
        _isLoadingProfessions = false;
      });

      // Pre-select profession if already saved in SharedPreferences
      await _loadSavedProfession();
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load professions: $e';
        _isLoadingProfessions = false;
      });
    }
  }

  /// Load saved profession from SharedPreferences and pre-select it
  Future<void> _loadSavedProfession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProfession = prefs.getString('profession');

      if (savedProfession != null && savedProfession.isNotEmpty) {
        // Find the profession ID that matches the saved profession name
        final matchingProfession = _professions.firstWhere(
          (p) => p['name'] == savedProfession,
          orElse: () => {},
        );

        if (matchingProfession.isNotEmpty && mounted) {
          setState(() {
            _selectedProfession = matchingProfession['id'];
          });
        }
      }
    } catch (e) {
      // Silently fail - pre-selection is optional
      print('Error loading saved profession: $e');
    }
  }

  /// Convert profession ID to display name
  /// Example: "lab_technician" → "Lab Technician"
  String _formatProfessionName(String id) {
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _selectProfession() async {
    if (_selectedProfession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profession'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found. Please log in again.');
      }

      // Get profession display name
      final professionName = _professions
          .firstWhere((p) => p['id'] == _selectedProfession)['name']!;

      // Save profession to backend API
      final apiService = context.read<FormApiService>();
      final result = await apiService.updateUserDetails(
        userId: userId,
        data: {'profession': professionName},
      );

      if (!result['success']) {
        throw Exception(result['error'] ?? 'Failed to save profession');
      }

      // Save profession to SharedPreferences
      await prefs.setString('profession', professionName);
      await prefs.setBool('profession_selected', true);

      // Navigate based on flow context
      if (mounted) {
        final flow = widget.flowContext ?? 'signup';

        if (flow == 'profile') {
          // Profile flow: go to dynamic forms
          context.push('/dynamic-form/$_selectedProfession?flow=profile');
        } else {
          // Signup flow: go to resume upload
          context.push('/profile/resume?flow=signup');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          CustomHeaderContainer(
            title: 'Choose Your Profession',
            subtitle: 'Select the Career That Fits Your Future',
            backgroundImage: 'assets/v2/Star.png',
          ),

          // Content
          Expanded(
            child: _isLoadingProfessions
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xff00A4E1)),
                    ),
                  )
                : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_loadError!,
                                style: const TextStyle(color: Colors.red)),
                            TextButton(
                              onPressed: _loadProfessions,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _professions.length,
                        itemBuilder: (context, index) {
                          final profession = _professions[index];
                          final isSelected =
                              _selectedProfession == profession['id'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    _selectedProfession = profession['id'];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 24,
                                        width: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xff00A4E1)
                                                : Colors.grey.shade400,
                                            width: isSelected ? 6 : 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        profession['name']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Next Button
          if (!_isLoadingProfessions && _loadError == null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _selectProfession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00A4E1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
