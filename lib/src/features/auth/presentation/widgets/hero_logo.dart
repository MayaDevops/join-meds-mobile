import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HeroLogo extends StatelessWidget {
  final double height;
  final bool animate;

  const HeroLogo({
    super.key,
    this.height = 50,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/v2/appLogo.png',
      height: height,
    );

    if (animate) {
      logo = logo.animate().fadeIn().slideY(begin: -0.2, end: 0);
    }

    return Hero(
      tag: 'app_logo',
      child: logo,
    );
  }
}
