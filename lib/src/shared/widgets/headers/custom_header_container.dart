import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../buttons/back_button_widget.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable header container widget
///
/// A flexible widget for full-width container-based headers with backgrounds,
/// images, rounded corners, and custom layouts.
///
/// Example usage:
/// ```dart
/// CustomHeaderContainer(
///   title: 'Choose Your Profession',
///   subtitle: 'Select the Career That Fits Your Future',
///   backgroundImage: 'assets/v2/Star.png',
/// )
/// ```
class CustomHeaderContainer extends StatelessWidget {
  /// Background color of the header
  final Color backgroundColor;

  /// Optional background image asset path
  final String? backgroundImage;

  /// How the background image should fit within the container
  final BoxFit backgroundImageFit;

  /// Whether to apply rounded corners to the bottom of the container
  final bool roundedBottomCorners;

  /// Border radius value for rounded corners
  final double borderRadius;

  /// Main title text
  final String? title;

  /// Subtitle text (appears below title)
  final String? subtitle;

  /// Custom style for the title text
  final TextStyle? titleStyle;

  /// Custom style for the subtitle text
  final TextStyle? subtitleStyle;

  /// Whether to show the back button
  /// If null, automatically detects based on context.canPop()
  final bool? showBackButton;

  /// Custom callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Style of the back button (image, icon, or simple)
  final BackButtonStyle backButtonStyle;

  /// Padding around the header content
  final EdgeInsets padding;

  /// Custom content widget to override default layout
  final Widget? customContent;

  /// Cross-axis alignment for the content
  final CrossAxisAlignment alignment;

  /// Additional widget to display below the title/subtitle
  final Widget? bottomWidget;

  const CustomHeaderContainer({
    super.key,
    this.backgroundColor = AppColors.primaryBlue,
    this.backgroundImage,
    this.backgroundImageFit = BoxFit.cover,
    this.roundedBottomCorners = false,
    this.borderRadius = 30.0,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.showBackButton,
    this.onBackPressed,
    this.backButtonStyle = BackButtonStyle.image,
    this.padding = const EdgeInsets.fromLTRB(20, 60, 20, 30),
    this.customContent,
    this.alignment = CrossAxisAlignment.start,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowBackButton = showBackButton ?? context.canPop();

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: backgroundImageFit,
              )
            : null,
        borderRadius: roundedBottomCorners
            ? BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              )
            : null,
      ),
      child: customContent ?? _buildDefaultContent(context, shouldShowBackButton),
    );
  }

  Widget _buildDefaultContent(BuildContext context, bool shouldShowBackButton) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            if (shouldShowBackButton) ...[
              BackButtonWidget(
                style: backButtonStyle,
                onPressed: onBackPressed,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: titleStyle ?? _defaultTitleStyle,
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: subtitleStyle ?? _defaultSubtitleStyle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (bottomWidget != null) ...[
          const SizedBox(height: 16),
          bottomWidget!,
        ],
      ],
    );
  }

  static const TextStyle _defaultTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _defaultSubtitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );
}
