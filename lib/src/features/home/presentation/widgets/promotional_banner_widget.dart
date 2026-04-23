import 'package:flutter/material.dart';


/// Promotional banner widget for home screen
class PromotionalBannerWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const PromotionalBannerWidget({
    super.key,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: _buildPlaceholderImage(),
        ),
      ),
    );
  }



  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/v2/bhanner.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if asset not found
        return const Icon(
          Icons.medical_services,
          size: 80,
          color: Colors.white70,
        );
      },
    );
  }


}
