import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration using Material Design 3
class AppTheme {
  AppTheme._();

  // Default brand color when dynamic colors aren't available
  static const Color _brandColor = Color(0xFF6750A4);

  /// Light theme with optional dynamic color support
  static ThemeData lightTheme(ColorScheme? dynamicScheme) {
    final colorScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: _brandColor,
          brightness: Brightness.light,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      floatingActionButtonTheme: _buildFabTheme(colorScheme),
      navigationRailTheme: _buildNavRailTheme(colorScheme),
      drawerTheme: _buildDrawerTheme(colorScheme),
      inputDecorationTheme: _buildInputTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
    );
  }

  /// Dark theme with optional dynamic color support
  static ThemeData darkTheme(ColorScheme? dynamicScheme) {
    final colorScheme = dynamicScheme ??
        ColorScheme.fromSeed(
          seedColor: _brandColor,
          brightness: Brightness.dark,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme),
      floatingActionButtonTheme: _buildFabTheme(colorScheme),
      navigationRailTheme: _buildNavRailTheme(colorScheme),
      drawerTheme: _buildDrawerTheme(colorScheme),
      inputDecorationTheme: _buildInputTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.interTextTheme().copyWith(
      bodyLarge: GoogleFonts.inter(color: colorScheme.onSurface),
      bodyMedium: GoogleFonts.inter(color: colorScheme.onSurface),
      bodySmall: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        color: colorScheme.primary,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }

  static CardTheme _buildCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static FloatingActionButtonThemeData _buildFabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      elevation: 2,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static NavigationRailThemeData _buildNavRailTheme(ColorScheme colorScheme) {
    return NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer),
      unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      indicatorColor: colorScheme.secondaryContainer,
    );
  }

  static DrawerThemeData _buildDrawerTheme(ColorScheme colorScheme) {
    return DrawerThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ListTileThemeData _buildListTileTheme(ColorScheme colorScheme) {
    return ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  static DividerThemeData _buildDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
  }
}

/// Editor-specific theme for syntax highlighting
class EditorTheme {
  EditorTheme._();

  /// Get code editor text style with configured font
  static TextStyle editorTextStyle({
    required String fontFamily,
    required double fontSize,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  /// Light mode syntax highlighting colors
  static Map<String, TextStyle> lightSyntaxColors = {
    'keyword': const TextStyle(color: Color(0xFF0000FF), fontWeight: FontWeight.bold),
    'string': const TextStyle(color: Color(0xFFA31515)),
    'comment': const TextStyle(color: Color(0xFF008000), fontStyle: FontStyle.italic),
    'number': const TextStyle(color: Color(0xFF098658)),
    'function': const TextStyle(color: Color(0xFF795E26)),
    'class': const TextStyle(color: Color(0xFF267F99)),
    'variable': const TextStyle(color: Color(0xFF001080)),
    'operator': const TextStyle(color: Color(0xFF000000)),
    'punctuation': const TextStyle(color: Color(0xFF000000)),
    'type': const TextStyle(color: Color(0xFF267F99)),
    'annotation': const TextStyle(color: Color(0xFF808000)),
  };

  /// Dark mode syntax highlighting colors
  static Map<String, TextStyle> darkSyntaxColors = {
    'keyword': const TextStyle(color: Color(0xFF569CD6), fontWeight: FontWeight.bold),
    'string': const TextStyle(color: Color(0xFFCE9178)),
    'comment': const TextStyle(color: Color(0xFF6A9955), fontStyle: FontStyle.italic),
    'number': const TextStyle(color: Color(0xFFB5CEA8)),
    'function': const TextStyle(color: Color(0xFFDCDCAA)),
    'class': const TextStyle(color: Color(0xFF4EC9B0)),
    'variable': const TextStyle(color: Color(0xFF9CDCFE)),
    'operator': const TextStyle(color: Color(0xFFD4D4D4)),
    'punctuation': const TextStyle(color: Color(0xFFD4D4D4)),
    'type': const TextStyle(color: Color(0xFF4EC9B0)),
    'annotation': const TextStyle(color: Color(0xFFDCDCAA)),
  };
}
