import 'package:flutter/material.dart';

/// Navigation bar widget for form screens
/// Shows Back, Skip, and Next/Save buttons with progress
class NavigationBarWidget extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool showBack;
  final bool showSkip;
  final bool isLoading;
  final double progress;
  final bool showProgress;
  final String nextButtonText;
  final String backButtonText;

  const NavigationBarWidget({
    super.key,
    this.onBack,
    this.onNext,
    this.onSkip,
    this.showBack = true,
    this.showSkip = false,
    this.isLoading = false,
    this.progress = 0.0,
    this.showProgress = true,
    this.nextButtonText = 'Submit',
    this.backButtonText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            if (showProgress && progress > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff00A4E1),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff00A4E1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Buttons
            Row(
              children: [
                // Back/Cancel button
                if (showBack && onBack != null)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        backButtonText,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (showBack && onBack != null) const SizedBox(width: 12),

                // Skip button
                if (showSkip && onSkip != null)
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: isLoading ? null : onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                if (showSkip && onSkip != null) const SizedBox(width: 12),

                // Next/Submit button
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff00A4E1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : Text(
                      nextButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}