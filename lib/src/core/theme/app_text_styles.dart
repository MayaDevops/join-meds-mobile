import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get _baseStyle => GoogleFonts.poppins();

  // Headings
  static TextStyle get h1 => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle get h2 => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get h3 => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get h4 => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body Text
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Button Text
  static TextStyle get buttonLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // Form Styles
  static TextStyle get formLabel => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get formInput => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get formHint => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textHintLight,
      );

  static TextStyle get formError => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.error,
      );

  // AppBar
  static TextStyle get appBarTitle => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // Link
  static TextStyle get link => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryBlue,
        decoration: TextDecoration.underline,
      );

  // Special Styles
  static TextStyle get priceTag => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      );

  static TextStyle get badge => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
