import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/widgets/headers/headers.dart';
import '../../domain/repositories/v2_form_repository.dart';
import '../../domain/models/v2_models.dart';

/// V2 Flow Selection Screen
/// Shows available flows (B.Pharm, M.Pharm, etc.) for a profession
/// Skips automatically if only one flow exists
class V2FlowSelectionScreen extends StatefulWidget {
  final String professionId;
  final String? flowContext;

  const V2FlowSelectionScreen({
    super.key,
    required this.professionId,
    this.flowContext,
  });

  @override
  State<V2FlowSelectionScreen> createState() => _V2FlowSelectionScreenState();
}

class _V2FlowSelectionScreenState extends State<V2FlowSelectionScreen> {
  String? _selectedFlowId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  V2FormConfig? _config;
  List<V2FlowConfig> _flows = [];

  @override
  void initState() {
    super.initState();
    _loadFlows();
  }

  Future<void> _loadFlows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<V2FormRepository>();
      _config = await repository.getProfessionConfig(widget.professionId);

      if (_config == null) {
        throw Exception('Config not found for ${widget.professionId}');
      }

      _flows = _config!.flows.values.toList();

      // If only one flow, skip selection and go directly to form
      if (_flows.length == 1) {
        _navigateToForm(_flows.first.id);
        return;
      }

      // Pre-select saved flow
      await _loadSavedFlow();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSavedFlow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFlow = prefs.getString('courseType_${widget.professionId}');

      if (savedFlow != null && _flows.any((f) => f.id == savedFlow)) {
        _selectedFlowId = savedFlow;
      }
    } catch (e) {
      print('Error loading saved flow: $e');
    }
  }

  void _navigateToForm(String flowId) {
    final flow = widget.flowContext ?? 'signup';

    // Use pushReplacement to avoid back button returning to this screen
    context.pushReplacement(
      '/v2-dynamic-form/${widget.professionId}?courseType=$flowId&flow=$flow',
    );
  }

  Future<void> _selectFlow() async {
    if (_selectedFlowId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Save selected flow
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'courseType_${widget.professionId}', _selectedFlowId!);

      // Get flow display name and save
      final selectedFlow = _flows.firstWhere((f) => f.id == _selectedFlowId);
      await prefs.setString('courseTypeName', selectedFlow.displayName);

      _navigateToForm(_selectedFlowId!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFlows,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          CustomHeaderContainer(
            title: 'Select Your Course',
            subtitle: 'Choose the program you are pursuing',
            backgroundImage: 'assets/v2/Star.png',
          ),

          // Flow List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _flows.length,
              itemBuilder: (context, index) {
                final flow = _flows[index];
                final isSelected = _selectedFlowId == flow.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff00A4E1).withOpacity(0.1)
                        : Colors.white,
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
                        setState(() => _selectedFlowId = flow.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xff00A4E1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.school,
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flow.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xff00A4E1)
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${flow.steps.length} steps',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xff00A4E1),
                                size: 24,
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _selectFlow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff00A4E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Continue',
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
