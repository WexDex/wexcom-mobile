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
  static const Color receivableAccent = Color(0xFF38BDF8);
  /// They owe you — positive cashflow feel.
  static const Color balanceReceivable = Color(0xFF22C55E);
  /// Ledger: new debt / you owe direction.
  static const Color ledgerDebt = Color(0xFFEF4444);
  /// Ledger: payment received.
  static const Color ledgerPayment = Color(0xFF4ADE80);
  /// Cancelled / voided transaction highlight.
  static const Color ledgerCancel = Color(0xFFEAB308);
  static const Color ledgerCancelSurface = Color(0xFF422006);
  /// Navbar / key interactive accent (cyan).
  static const Color brandPrimary = Color(0xFF22D3EE);
  /// Secondary accent (violet) — tags, alternates.
  static const Color brandSecondary = Color(0xFFC4B5FD);
  /// Personal spending (rose), distinct from ledger debt.
  static const Color personalExpense = Color(0xFFFB7185);
  /// Personal income / gains (emerald).
  static const Color personalGain = Color(0xFF34D399);
  static const double radius = 10;
  static const double radiusLg = 14;

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      surface: surface,
      primary: brandPrimary,
      onPrimary: appBg,
      primaryContainer: Color.lerp(surface, brandPrimary, 0.35)!,
      onPrimaryContainer: appFg,
      secondary: brandSecondary,
      onSecondary: appBg,
      secondaryContainer: Color.lerp(surface, brandSecondary, 0.28)!,
      onSecondaryContainer: appFg,
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
        backgroundColor: brandPrimary,
        foregroundColor: appBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: mutedFg,
        textColor: appFg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        deleteIconColor: mutedFg,
        disabledColor: inputFill.withValues(alpha: 0.5),
        selectedColor: receivableAccent.withValues(alpha: 0.22),
        secondarySelectedColor: receivableAccent.withValues(alpha: 0.22),
        labelStyle: TextStyle(color: appFg, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: appFg, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 12,
        shadowColor: Colors.black54,
        indicatorColor: brandPrimary.withValues(alpha: 0.22),
        surfaceTintColor: brandPrimary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? brandPrimary : mutedFg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          );
        }),
      ),
    );
  }
}
