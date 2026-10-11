import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color darkButton = Color(0xFF111827); // Dark Charcoal

  // Backgrounds & Surface
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF3F4F6);

  // Border & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFEEF2F6);

  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status Badges & Priorities
  static const Color highPriority = Color(0xFFEF4444);
  static const Color highPriorityBg = Color(0xFFFEE2E2);
  static const Color highPriorityText = Color(0xFFDC2626);

  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color mediumPriorityBg = Color(0xFFFEF3C7);
  static const Color mediumPriorityText = Color(0xFFD97706);

  static const Color lowPriority = Color(0xFF10B981);
  static const Color lowPriorityBg = Color(0xFFD1FAE5);
  static const Color lowPriorityText = Color(0xFF059669);

  static const Color doneBg = Color(0xFFECFDF5);
  static const Color doneText = Color(0xFF059669);
  static const Color success = Color(0xFF16A34A);

  // Danger / Delete
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);

  // Category Colors
  // Personal: Cyan
  static const Color categoryPersonalBg = Color(0xFFE0F2FE);
  static const Color categoryPersonalText = Color(0xFF0284C7);
  static const Color categoryPersonalBorder = Color(0xFFBAE6FD);

  // Educational: Lavender
  static const Color categoryEducationalBg = Color(0xFFF3E8FF);
  static const Color categoryEducationalText = Color(0xFF7E22CE);
  static const Color categoryEducationalBorder = Color(0xFFE9D5FF);

  // Work: Mint
  static const Color categoryWorkBg = Color(0xFFD1FAE5);
  static const Color categoryWorkText = Color(0xFF059669);
  static const Color categoryWorkBorder = Color(0xFFA7F3D0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.textMuted,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
