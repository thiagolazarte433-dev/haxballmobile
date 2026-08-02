import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF12081F);
  static const Color surface = Color(0xFF1E1033);
  static const Color surfaceVariant = Color(0xFF2A1846);
  static const Color primary = Color(0xFF9D4EDD);
  static const Color primaryVariant = Color(0xFF7B2CBF);
  static const Color accentPink = Color(0xFFE0AAFF);
  static const Color neonCyan = Color(0xFF5BE9FF);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFFB84D);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color textPrimary = Color(0xFFF3EAFF);
  static const Color textSecondary = Color(0xFFB3A0D6);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF120821), Color(0xFF23103F), Color(0xFF34125A)],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF5A189A)],
  );

  static BoxShadow neonGlow({Color color = primary, double opacity = 0.55}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 24,
      spreadRadius: 1,
    );
  }

  static ThemeData get darkViolet {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: neonCyan,
        surface: surface,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: surface),
      cardTheme: CardThemeData(
        color: surfaceVariant,
        elevation: 6,
        shadowColor: primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(accentPink),
        trackColor: WidgetStateProperty.all(primaryVariant),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: accentPink,
        inactiveTrackColor: surfaceVariant,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
