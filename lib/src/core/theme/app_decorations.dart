import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppDecorations {
  // Input Decorations
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool isDense = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: AppTextStyles.formHint,
      labelStyle: AppTextStyles.formLabel,
      errorStyle: AppTextStyles.formError,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderLight, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderFocused, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderError, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderError, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorderLight.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.transparent,
    );
  }

  // Card Decorations
  static BoxDecoration cardDecoration({
    bool isDark = false,
    double borderRadius = 16,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasShadow ? AppColors.cardShadow : null,
    );
  }

  static BoxDecoration cardDecorationWithBorder({
    bool isDark = false,
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (isDark ? AppColors.dividerDark : AppColors.dividerLight),
        width: 1,
      ),
    );
  }

  // Container Decorations
  static BoxDecoration gradientContainer({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: AppColors.buttonShadow,
    );
  }

  static BoxDecoration roundedContainer({
    Color? color,
    double borderRadius = 12,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: color ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Status Container Decorations
  static BoxDecoration statusContainer({
    required Color backgroundColor,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Avatar Decoration
  static BoxDecoration avatarDecoration({
    double size = 50,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.surfaceLight,
      border: hasBorder
          ? Border.all(color: AppColors.primaryBlue, width: 2)
          : null,
      boxShadow: AppColors.cardShadow,
    );
  }

  // Badge Decoration
  static BoxDecoration badgeDecoration({
    Color? color,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.primaryBlue,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Bottom Sheet Decoration
  static BoxDecoration bottomSheetDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    );
  }

  // Chip Decoration
  static BoxDecoration chipDecoration({
    bool isSelected = false,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryBlueAccent
          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
        width: 1.5,
      ),
    );
  }
}
