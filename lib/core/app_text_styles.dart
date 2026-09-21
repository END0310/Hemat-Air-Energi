import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: -0.6,
        height: 32 / 24,
      );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.24,
        height: 32 / 24,
      );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 24 / 16,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textMedium,
        height: 20 / 14,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
        height: 16 / 12,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 14 / 10,
        letterSpacing: 0.4,
      );

  static TextStyle get labelBold => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 14 / 10,
        letterSpacing: 0.4,
      );

  static TextStyle get metricValue => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        letterSpacing: -0.6,
        height: 32 / 24,
      );

  static TextStyle get splashSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xE6EAF1FF),
        height: 20 / 14,
      );

  static TextStyle get splashCaption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xD9EAF1FF),
        height: 16 / 12,
      );
}
