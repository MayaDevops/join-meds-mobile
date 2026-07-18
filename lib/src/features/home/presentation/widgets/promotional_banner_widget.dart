import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Promotional banner for the home screen.
///
/// A modern, fully code-drawn (no image asset) animated card that highlights
/// the number of open job positions on the platform. Designed to feel premium
/// for a professional job-search product: a branded gradient surface, softly
/// drifting decorative shapes, an animated live counter and a "hiring" pulse.
class PromotionalBannerWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const PromotionalBannerWidget({
    super.key,
    this.onTap,
  });

  @override
  State<PromotionalBannerWidget> createState() =>
      _PromotionalBannerWidgetState();
}

class _PromotionalBannerWidgetState extends State<PromotionalBannerWidget>
    with TickerProviderStateMixin {
  // Continuous background motion for the decorative shapes.
  late final AnimationController _floatController;
  // One-shot entrance animation (fade + slide + count-up).
  late final AnimationController _introController;
  late final Animation<double> _introCurve;

  static const int _targetOpenings = 3000;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _introController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _introCurve,
      child: AnimatedBuilder(
        animation: _introCurve,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 24 * (1 - _introCurve.value)),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              // Always span the full available width (otherwise the Stack
              // would shrink to the width of the text and leave empty side
              // gaps). Height grows with content but keeps a comfortable
              // minimum so it never looks shrunken.
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlueDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Drifting decorative shapes fill the space that the
                    // image used to occupy, so the card never reads as empty.
                    // Positioned.fill so the decor matches the content height.
                    Positioned.fill(child: _buildFloatingDecor()),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Soft, slowly drifting circles + the medical mark on the right side.
  Widget _buildFloatingDecor() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value * 2 * math.pi;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // Large translucent circle, top-right.
            Positioned(
              right: -30 + math.sin(t) * 6,
              top: -40 + math.cos(t) * 6,
              child: _circle(140, Colors.white.withOpacity(0.10)),
            ),
            // Medium circle, bottom-right.
            Positioned(
              right: 40 + math.cos(t) * 8,
              bottom: -50 + math.sin(t) * 8,
              child: _circle(120, Colors.white.withOpacity(0.08)),
            ),
            // Small accent circle, mid-right.
            Positioned(
              right: 90 + math.sin(t + 1) * 5,
              top: 30 + math.cos(t + 1) * 5,
              child: _circle(26, Colors.white.withOpacity(0.16)),
            ),
            // Right-side stacked medical icon replacing the illustration.
            Positioned(
              right: 22,
              top: 0,
              bottom: 0,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, math.sin(t) * 4),
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.30),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.work_outline_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildContent() {
    return Padding(
      // Right padding reserves space for the floating icon so text never
      // collides with it on narrow devices.
      padding: const EdgeInsets.only(
        left: 20,
        right: 96,
        top: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Now Hiring" pill with a pulsing live dot.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(),
                const SizedBox(width: 6),
                const Text(
                  'NOW HIRING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Animated count-up for the headline figure. Wrapped in a left
          // aligned FittedBox so it scales down instead of overflowing on
          // very narrow screens or with large system font settings.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _introCurve,
              builder: (context, child) {
                final value = (_targetOpenings * _introCurve.value).round();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$value+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Job Openings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Across top healthcare facilities',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // Call-to-action chip.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Explore Jobs',
                  style: TextStyle(
                    color: AppColors.primaryBlueDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryBlueDark,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small pulsing dot used inside the "Now Hiring" badge to suggest live
/// activity.
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
