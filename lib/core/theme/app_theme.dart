import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Theme chính thức Quyen Auto — Material 3.
/// Sử dụng: MaterialApp.router(theme: AppTheme.light)
abstract final class AppTheme {
  static const double _radiusSm = 8;
  static const double _radiusMd = 12;
  static const double _radiusLg = 16;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      primary:   AppColors.primaryOrange,
      onPrimary: AppColors.textWhite,
      secondary:   AppColors.primaryNavy,
      onSecondary: AppColors.textWhite,
      error:     AppColors.errorRed,
      surface:   AppColors.surface,
      onSurface: AppColors.textDark,
    );

    final base = GoogleFonts.robotoTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme:  colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: base.copyWith(
        displayLarge:   base.displayLarge?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700),
        displayMedium:  base.displayMedium?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700),
        headlineLarge:  base.headlineLarge?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700),
        headlineMedium: base.headlineMedium?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleLarge:     base.titleLarge?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600),
        titleMedium:    base.titleMedium?.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
        bodyLarge:      base.bodyLarge?.copyWith(color: AppColors.textDark),
        bodyMedium:     base.bodyMedium?.copyWith(color: AppColors.textDark),
        bodySmall:      base.bodySmall?.copyWith(color: AppColors.textGray),
        labelSmall:     base.labelSmall?.copyWith(color: AppColors.textGray),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.roboto(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.primaryOrange,
          foregroundColor:         AppColors.textWhite,
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textGray,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
          elevation: 0,
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusMd),
          ),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          textStyle: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:  GoogleFonts.roboto(color: AppColors.textGray,  fontSize: 14),
        labelStyle: GoogleFonts.roboto(color: AppColors.textGray,  fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── BottomNavigationBar ───────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:     AppColors.surface,
        selectedItemColor:   AppColors.primaryOrange,
        unselectedItemColor: AppColors.textGray,
        selectedLabelStyle:   GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.roboto(fontSize: 11, fontWeight: FontWeight.w400),
        type:                BottomNavigationBarType.fixed,
        elevation:           8,
        showSelectedLabels:   true,
        showUnselectedLabels: true,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusSm)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.textWhite,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     AppColors.borderLight,
        thickness: 1,
        space:     1,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusLg)),
        elevation: 8,
        titleTextStyle: GoogleFonts.roboto(
          color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.roboto(color: AppColors.textDark, fontSize: 14),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryNavy,
        contentTextStyle: GoogleFonts.roboto(color: AppColors.textWhite, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusSm)),
        behavior:    SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
