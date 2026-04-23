import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable back button widget
/// Supports both image and icon styles with customizable appearance
class BackButtonWidget extends StatelessWidget {
  /// The callback when the button is pressed
  /// If null, defaults to Navigator.pop() or context.pop()
  final VoidCallback? onPressed;

  /// Whether to use the image asset or icon
  final BackButtonStyle style;

  /// Custom size for the button
  final double? size;

  /// Background color (for icon style with CircleAvatar)
  final Color? backgroundColor;

  /// Icon color (for icon style)
  final Color? iconColor;

  /// Whether to show the button only when navigation is possible
  /// If true, button won't show on first screen
  final bool showOnlyIfCanPop;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.style = BackButtonStyle.image,
    this.size,
    this.backgroundColor,
    this.iconColor,
    this.showOnlyIfCanPop = false,
  });

  /// Factory constructor for image style (default)
  const BackButtonWidget.image({
    Key? key,
    VoidCallback? onPressed,
    double? size,
    bool showOnlyIfCanPop = false,
  }) : this(
          key: key,
          onPressed: onPressed,
          style: BackButtonStyle.image,
          size: size,
          showOnlyIfCanPop: showOnlyIfCanPop,
        );

  /// Factory constructor for icon style with CircleAvatar background
  const BackButtonWidget.icon({
    Key? key,
    VoidCallback? onPressed,
    double? size,
    Color? backgroundColor,
    Color? iconColor,
    bool showOnlyIfCanPop = false,
  }) : this(
          key: key,
          onPressed: onPressed,
          style: BackButtonStyle.icon,
          size: size,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          showOnlyIfCanPop: showOnlyIfCanPop,
        );

  /// Factory constructor for simple icon style without background
  const BackButtonWidget.simple({
    Key? key,
    VoidCallback? onPressed,
    double? size,
    Color? iconColor,
    bool showOnlyIfCanPop = false,
  }) : this(
          key: key,
          onPressed: onPressed,
          style: BackButtonStyle.simple,
          size: size,
          iconColor: iconColor,
          showOnlyIfCanPop: showOnlyIfCanPop,
        );

  void _handlePress(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      // Try GoRouter first, fallback to Navigator
      if (context.canPop()) {
        context.pop();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should show the button
    if (showOnlyIfCanPop && !context.canPop()) {
      return const SizedBox.shrink();
    }

    switch (style) {
      case BackButtonStyle.image:
        return InkWell(
          onTap: () => _handlePress(context),
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/v2/backbutton.png',
            width: size ?? 40,
            height: size ?? 40,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image not found
              return Icon(
                Icons.arrow_back,
                color: iconColor ?? Colors.white,
                size: size ?? 24,
              );
            },
          ),
        );

      case BackButtonStyle.icon:
        return CircleAvatar(
          radius: (size ?? 40) / 2,
          backgroundColor:
              backgroundColor ?? Colors.white.withOpacity(0.3),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: iconColor ?? Colors.white,
            ),
            onPressed: () => _handlePress(context),
          ),
        );

      case BackButtonStyle.simple:
        return IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: iconColor ?? Colors.white,
            size: size ?? 24,
          ),
          onPressed: () => _handlePress(context),
        );
    }
  }
}

/// Enum for back button styles
enum BackButtonStyle {
  /// Uses the image asset from assets/v2/backbutton.png
  image,

  /// Uses an icon with CircleAvatar background
  icon,

  /// Uses a simple icon without background
  simple,
}
