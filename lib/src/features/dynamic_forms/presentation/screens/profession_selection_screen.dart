import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../domain/repositories/v2_form_repository.dart';
import '../../../../shared/services/api/form_api_service.dart';

/// V2 Profession selection screen
/// Lists professions from v2/forms/professions/ path
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

  /// Load professions from V2 Firebase path
  Future<void> _loadProfessions() async {
    setState(() {
      _isLoadingProfessions = true;
      _loadError = null;
    });

    try {
      final repository = context.read<V2FormRepository>();
      final professionIds = await repository.getAllProfessionIds();

      // Load display names from each profession config
      final professionsList = <Map<String, String>>[];
      for (final id in professionIds) {
        final config = await repository.getProfessionConfig(id);
        professionsList.add({
          'id': id,
          'name': config?.profession.displayName ?? _formatProfessionName(id),
        });
      }

      setState(() {
        _professions = professionsList;
        _isLoadingProfessions = false;
      });

      // Pre-select profession if already saved
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
          (p) => p['name'] == savedProfession || p['id'] == savedProfession,
          orElse: () => {},
        );

        if (matchingProfession.isNotEmpty && mounted) {
          setState(() {
            _selectedProfession = matchingProfession['id'];
          });
        }
      }
    } catch (e) {
      print('Error loading saved profession: $e');
    }
  }

  /// Convert profession ID to display name
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
      await prefs.setString('professionId', _selectedProfession!);
      await prefs.setBool('profession_selected', true);

      // Navigate based on flow context
      if (mounted) {
        final flow = widget.flowContext ?? 'signup';

        if (flow == 'profile') {
          // Profile flow: go to flow selection (will auto-skip if only 1 flow)
          context.push('/v2-flow-selection/$_selectedProfession?flow=profile');
        } else {
          // Signup flow: go to resume upload first, then flow selection
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
                    : _professions.isEmpty
                        ? const Center(
                            child: Text('No professions available'),
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
                                    color: isSelected
                                        ? const Color(0xff00A4E1)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
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
                                          Expanded(
                                            child: Text(
                                              profession['name']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isSelected
                                                    ? const Color(0xff00A4E1)
                                                    : Colors.black87,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Color(0xff00A4E1),
                                              size: 20,
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
