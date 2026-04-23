import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

enum LoadingType { circular, lottie, dots }

class LoadingIndicator extends StatelessWidget {
  final LoadingType type;
  final double size;
  final String? lottiePath;
  final String? message;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.size = 50,
    this.lottiePath,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader() {
    switch (type) {
      case LoadingType.lottie:
        return Lottie.asset(
          lottiePath ?? AppAssets.v1Loading,
          width: size,
          height: size,
        );
      case LoadingType.dots:
        return _DotsLoading(size: size, color: color);
      case LoadingType.circular:
      default:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primaryBlue,
            ),
          ),
        );
    }
  }
}

/// Animated dots loading indicator
class _DotsLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const _DotsLoading({
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? AppColors.primaryBlue;
    final dotSize = size / 4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: dotSize / 4),
          child: _AnimatedDot(
            size: dotSize,
            color: dotColor,
            delay: Duration(milliseconds: index * 200),
          ),
        );
      }),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final double size;
  final Color color;
  final Duration delay;

  const _AnimatedDot({
    required this.size,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.3, 1.3),
          duration: 400.ms,
          delay: delay,
          curve: Curves.easeInOut,
        )
        .fadeIn(delay: delay);
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: LoadingIndicator(
              message: message,
              type: LoadingType.circular,
            ),
          ).animate().fadeIn(duration: 200.ms),
      ],
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 1500.ms,
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
        );
  }
}

/// Card shimmer placeholder
class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({
    super.key,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: MediaQuery.of(context).size.width * 0.4, height: 16),
                    const SizedBox(height: 8),
                    ShimmerLoading(width: MediaQuery.of(context).size.width * 0.3, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const ShimmerLoading(height: 14),
          const SizedBox(height: 8),
          ShimmerLoading(width: MediaQuery.of(context).size.width * 0.6, height: 14),
        ],
      ),
    );
  }
}
