import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/form_state_provider.dart';
import '../widgets/renderers/form_step_renderer.dart';
import '../widgets/renderers/navigation_bar_widget.dart';
import '../../../../shared/widgets/headers/custom_header_container.dart';

/// Main dynamic form screen that renders forms based on JSON configuration
class DynamicFormScreen extends StatefulWidget {
  final String professionId;
  final String? courseType;
  final String? flowContext;

  const DynamicFormScreen({
    super.key,
    required this.professionId,
    this.courseType,
    this.flowContext,
  });

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    final provider = context.read<FormStateProvider>();
    await provider.initialize(
      professionId: widget.professionId,
      courseType: widget.courseType,
      flowContext: widget.flowContext,
      forceRefresh: true, // Force refresh to bypass cache
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with dynamic title and subtitle
          Consumer<FormStateProvider>(
            builder: (context, provider, child) {
              return CustomHeaderContainer(
                title: provider.currentStep?.title ?? 'Dynamic Form',
                subtitle: provider.currentStep?.subtitle,
                backgroundImage: 'assets/v2/Star.png',
                onBackPressed: () {
                  if (provider.canGoBack) {
                    provider.navigateBack();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),

          // Body content
          Expanded(
            child: Consumer<FormStateProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.currentStep == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00A4E1)),
                    ),
                  );
                }

                if (provider.errorMessage != null && provider.currentStep == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading form',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xff606060)),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _initializeForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff00A4E1),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.currentStep == null) {
                  return const Center(
                    child: Text('No steps configured'),
                  );
                }

                return FormStepRenderer(step: provider.currentStep!);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<FormStateProvider>(
        builder: (context, provider, child) {
          if (provider.currentStep == null) return const SizedBox.shrink();

          final isLastStep = provider.currentStepIndex == provider.totalSteps - 1;

          return NavigationBarWidget(
            onBack: provider.canGoBack ? () => provider.navigateBack() : null,
            onNext: () => provider.navigateNext(context),
            onSkip: provider.canSkip ? () => provider.skipStep(context) : null,
            showBack: provider.canGoBack,
            showSkip: provider.canSkip,
            isLoading: provider.isLoading,
            progress: provider.progress,
            showProgress: provider.currentStep!.showProgress,
            nextButtonText: isLastStep ? 'Save' : 'Next',
          );
        },
      ),
    );
  }
}
