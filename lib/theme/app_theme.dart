import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mirrors STS theme dark shell ([theme wrapper/sts-theme.css](theme%20wrapper/sts-theme.css)).
abstract final class AppTheme {
  static const Color appBg = Color(0xFF020617);
  static const Color appFg = Color(0xFFF1F5F9);
  static const Color destructive = Color(0xFFD4183D);
  static const Color surface = Color(0xFF0F172A);
  static const Color inputFill = Color(0xFF1E293B);
  static const Color mutedFg = Color(0xFF94A3B8);
  static const Color receivableAccent = Color(0xFF38BDF8); // sky-400-ish for “they owe you”
  static const double radius = 10;

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      surface: surface,
      primary: appFg,
      onPrimary: appBg,
      secondary: const Color(0xFF334155),
      onSecondary: appFg,
      error: destructive,
      onError: Colors.white,
      onSurface: appFg,
      outline: const Color(0xFF334155),
      outlineVariant: const Color(0xFF475569),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: appBg,
      colorScheme: scheme,
      dividerColor: scheme.outlineVariant.withValues(alpha: 0.5),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: appFg,
      displayColor: appFg,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBg,
        foregroundColor: appFg,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: TextStyle(color: mutedFg.withValues(alpha: 0.85)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: receivableAccent, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: mutedFg,
        textColor: appFg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
