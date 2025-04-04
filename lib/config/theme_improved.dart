// lib/config/theme_improved.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:math' as math;

/// Extension on Color to provide safe opacity and color manipulation
extension ColorExtension on Color {
  /// Creates a new color with the specified opacity while preserving RGB values
  /// This properly handles opacity without precision loss
  Color withAlpha(double opacity) {
    return Color.fromRGBO(
      red,
      green,
      blue,
      opacity.clamp(0.0, 1.0),
    );
  }

  /// Creates a new color with modified RGBA values
  /// Any parameter left as null will use the original color's value
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.opacity,
    );
  }

  /// Creates a lighter version of this color
  Color lighter([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  /// Creates a darker version of this color
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }
}

/// Comprehensive design system for KounselMe
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // =========================================================================
  // FONTS
  // =========================================================================
  static const String fontInter = 'Inter';

  // =========================================================================
  // COLORS
  // =========================================================================

  // Primary Colors
  static const Color electricViolet = Color(0xFF8A4FFF);
  static const Color electricVioletLight = Color(0xFFA47AFF);
  static const Color electricVioletDark = Color(0xFF6E3FCC);
  static const Color heliotrope = Color(0xFFAC8FFF);
  static const Color heliotropeLight = Color(0xFFEEE8FF);

  // Secondary Colors
  static const Color robinsGreen = Color(0xFF00C6A2);
  static const Color robinsGreenLight = Color(0xFF5DDFC8);
  static const Color robinsGreenDark = Color(0xFF009E82);

  // Neutrals
  static const Color codGray = Color(0xFF121212);
  static const Color mineShaft = Color(0xFF2D2D2D);
  static const Color doveGray = Color(0xFF646464);
  static const Color silver = Color(0xFFBDBDBD);
  static const Color mercury = Color(0xFFE5E5E5);
  static const Color alabaster = Color(0xFFF8F8F8);
  static const Color snowWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF121212);
  static const Color secondaryText = Color(0xFF646464);
  static const Color disabledText = Color(0xFFBDBDBD);

  // Utility Colors
  static const Color divider = Color(0xFFE5E5E5);
  static const Color background = Color(0xFFF8F8F8);
  static const Color disabledBackground = Color(0xFFF0F0F0);

  // Feedback Colors
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF43A047);
  static const Color info = Color(0xFF1E88E5);

  // =========================================================================
  // TYPOGRAPHY
  // =========================================================================

  // Headings
  static const TextStyle headingXL = TextStyle(
    fontFamily: fontInter,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: primaryText,
  );

  static const TextStyle headingL = TextStyle(
    fontFamily: fontInter,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: primaryText,
  );

  static const TextStyle headingM = TextStyle(
    fontFamily: fontInter,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    color: primaryText,
  );

  static const TextStyle headingS = TextStyle(
    fontFamily: fontInter,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    color: primaryText,
  );

  static const TextStyle headingXS = TextStyle(
    fontFamily: fontInter,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
    color: primaryText,
  );

  // Subtitles
  static const TextStyle subtitleL = TextStyle(
    fontFamily: fontInter,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    color: primaryText,
  );

  static const TextStyle subtitleM = TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.15,
    color: primaryText,
  );

  static const TextStyle subtitleS = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: primaryText,
  );

  // Body Text
  static const TextStyle bodyL = TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle bodyS = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: primaryText,
  );

  // Labels
  static const TextStyle labelL = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle labelM = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle labelS = TextStyle(
    fontFamily: fontInter,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  // Buttons
  static const TextStyle buttonL = TextStyle(
    fontFamily: fontInter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle buttonM = TextStyle(
    fontFamily: fontInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  static const TextStyle buttonS = TextStyle(
    fontFamily: fontInter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: primaryText,
  );

  // =========================================================================
  // SPACING
  // =========================================================================

  // Spacing Scale
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXL = 24;
  static const double spaceXXL = 32;
  static const double space3XL = 40;
  static const double space4XL = 48;
  static const double space5XL = 64;
  static const double space6XL = 80;
  static const double space7XL = 96;
  static const double space8XL = 128;

  // =========================================================================
  // RADIUS
  // =========================================================================

  // Border Radius Scale
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusRound = 100;

  // =========================================================================
  // ELEVATION
  // =========================================================================

  // Elevation Scale
  static const double elevationXS = 1;
  static const double elevationS = 2;
  static const double elevationM = 4;
  static const double elevationL = 8;
  static const double elevationXL = 16;
  static const double elevationXXL = 24;

  // Shadow Generator
  static List<BoxShadow> getShadow({
    required double elevation,
    Color? shadowColor,
  }) {
    final color = shadowColor ?? Colors.black.withAlpha((0.2 * 255).toInt());

    switch (elevation.round()) {
      case 1:
        return [
          BoxShadow(
            color: color.withAlpha((0.05 * 255).toInt()),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case 4:
        return [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case 8:
        return [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case 16:
        return [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
      case 24:
        return [
          BoxShadow(
            color: color.withAlpha((0.11 * 255).toInt()),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: color.withAlpha((0.1 * 255).toInt()),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ];
    }
  }

  // =========================================================================
  // ICONS
  // =========================================================================

  // Icon Sizes
  static const double iconXS = 12;
  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24;
  static const double iconXL = 32;
  static const double iconXXL = 40;

  // =========================================================================
  // DECORATIONS
  // =========================================================================

  // Card Decoration
  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    double borderRadius = radiusL,
    double elevation = elevationS,
    Color? shadowColor,
    Color? borderColor,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? snowWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: getShadow(
        elevation: elevation,
        shadowColor:
            shadowColor ?? electricViolet.withAlpha((0.08 * 255).toInt()),
      ),
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
    );
  }

  // Gradient Decoration
  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    double borderRadius = radiusL,
    double elevation = elevationS,
    Color? shadowColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: getShadow(
        elevation: elevation,
        shadowColor: shadowColor ?? colors.first.withAlpha((0.3 * 255).toInt()),
      ),
    );
  }

  // Glass Decoration
  static BoxDecoration glassDecoration({
    required Color baseColor,
    double opacity = 0.1,
    double borderRadius = radiusL,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      color: baseColor.withAlpha((opacity * 255).toInt()),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: baseColor.withAlpha((borderOpacity * 255).toInt()),
        width: 1,
      ),
    );
  }

  // =========================================================================
  // BUTTON STYLES
  // =========================================================================

  // Primary Button Style
  static ButtonStyle primaryButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = elevationS,
    double borderRadius = radiusL,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    final baseColor = backgroundColor ?? electricViolet;
    final textColor = foregroundColor ?? snowWhite;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledBackground;
          }
          if (states.contains(WidgetState.pressed)) {
            return baseColor == electricViolet ? electricVioletDark : baseColor;
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor == electricViolet
                ? electricVioletLight
                : baseColor;
          }
          return baseColor;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledText;
          }
          return textColor;
        },
      ),
      elevation: WidgetStateProperty.resolveWith<double>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return 0;
          }
          if (states.contains(WidgetState.pressed)) {
            return elevation / 2;
          }
          return elevation;
        },
      ),
      shadowColor: WidgetStateProperty.all(
          electricViolet.withAlpha((0.3 * 255).toInt())),
      padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
      minimumSize: WidgetStateProperty.all(minimumSize ?? const Size(64, 48)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          return states.contains(WidgetState.disabled)
              ? buttonM.copyWith(color: disabledText)
              : buttonM;
        },
      ),
    );
  }

  // Secondary Button Style
  static ButtonStyle secondaryButtonStyle({
    Color? foregroundColor,
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = radiusL,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    final baseColor = foregroundColor ?? electricViolet;
    final baseBorderColor = borderColor ?? baseColor;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return baseColor.withAlpha((0.05 * 255).toInt());
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withAlpha((0.03 * 255).toInt());
          }
          return Colors.transparent;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledText;
          }
          if (states.contains(WidgetState.pressed)) {
            return baseColor == electricViolet ? electricVioletDark : baseColor;
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor == electricViolet
                ? electricVioletLight
                : baseColor;
          }
          return baseColor;
        },
      ),
      side: WidgetStateProperty.resolveWith<BorderSide>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: disabledText, width: borderWidth);
          }
          if (states.contains(WidgetState.pressed)) {
            return BorderSide(
              color: baseColor == electricViolet
                  ? electricVioletDark
                  : baseBorderColor,
              width: borderWidth,
            );
          }
          if (states.contains(WidgetState.hovered)) {
            return BorderSide(
              color: baseColor == electricViolet
                  ? electricVioletLight
                  : baseBorderColor,
              width: borderWidth,
            );
          }
          return BorderSide(color: baseBorderColor, width: borderWidth);
        },
      ),
      padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
      minimumSize: WidgetStateProperty.all(minimumSize ?? const Size(64, 48)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return buttonM.copyWith(color: disabledText);
          }
          return buttonM.copyWith(color: baseColor);
        },
      ),
    );
  }

  // Text Button Style
  static ButtonStyle textButtonStyle({
    Color? textColor,
    EdgeInsetsGeometry? padding,
    double borderRadius = radiusM,
  }) {
    final baseColor = textColor ?? electricViolet;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledText;
          }
          if (states.contains(WidgetState.pressed)) {
            return baseColor == electricViolet ? electricVioletDark : baseColor;
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor == electricViolet
                ? electricVioletLight
                : baseColor;
          }
          return baseColor;
        },
      ),
      padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return baseColor.withAlpha((0.1 * 255).toInt());
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withAlpha((0.05 * 255).toInt());
          }
          return Colors.transparent;
        },
      ),
      textStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return buttonS.copyWith(color: disabledText);
          }
          return buttonS.copyWith(color: baseColor);
        },
      ),
    );
  }

  // Icon Button Style
  static ButtonStyle iconButtonStyle({
    Color? iconColor,
    Color? backgroundColor,
    double size = 40,
    double? iconSize,
    double borderRadius = radiusS,
  }) {
    final baseColor = iconColor ?? electricViolet;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (backgroundColor != null) return backgroundColor;

          if (states.contains(WidgetState.pressed)) {
            return baseColor.withAlpha((0.1 * 255).toInt());
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withAlpha((0.05 * 255).toInt());
          }
          return Colors.transparent;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledText;
          }
          return baseColor;
        },
      ),
      minimumSize: WidgetStateProperty.all(Size(size, size)),
      maximumSize: WidgetStateProperty.all(Size(size, size)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      iconSize: WidgetStateProperty.all(iconSize ?? iconM),
    );
  }

  // =========================================================================
  // INPUT STYLES
  // =========================================================================

  // Text Field Decoration
  static InputDecoration textFieldDecoration({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    Color? borderColor,
    double borderRadius = radiusL,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? snowWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor ?? divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor ?? divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: electricViolet, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: labelL.copyWith(color: secondaryText),
      hintStyle: bodyM.copyWith(color: secondaryText),
      errorStyle: labelM.copyWith(color: error),
    );
  }

  // =========================================================================
  // SYSTEM THEME
  // =========================================================================

  // Get the system theme adjusted for the current platform
  static ThemeData get theme {
    // Base theme
    ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: electricViolet,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: electricViolet,
        secondary: heliotrope,
        tertiary: robinsGreen,
        surface: snowWhite,
        error: error,
        onPrimary: snowWhite,
        onSecondary: snowWhite,
        onSurface: primaryText,
        onError: snowWhite,
      ),

      // Convert our text styles to theme data
      textTheme: TextTheme(
        displayLarge: headingXL,
        displayMedium: headingL,
        displaySmall: headingM,
        headlineLarge: headingS,
        headlineMedium: headingXS,
        headlineSmall: subtitleL,
        titleLarge: subtitleL,
        titleMedium: subtitleM,
        titleSmall: subtitleS,
        bodyLarge: bodyL,
        bodyMedium: bodyM,
        bodySmall: bodyS,
        labelLarge: labelL,
        labelMedium: labelM,
        labelSmall: labelS,
      ),

      // Set up component themes
      appBarTheme: AppBarTheme(
        backgroundColor: electricViolet,
        foregroundColor: snowWhite,
        elevation: 0,
        centerTitle: Platform.isIOS, // Center on iOS, left-aligned on Android
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle(),
      ),

      textButtonTheme: TextButtonThemeData(
        style: textButtonStyle(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: snowWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: electricViolet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        labelStyle: labelL.copyWith(color: secondaryText),
        hintStyle: bodyM.copyWith(color: secondaryText),
      ),

      cardTheme: CardTheme(
        color: snowWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        shadowColor: electricViolet.withAlpha((0.08 * 255).toInt()),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: snowWhite,
        selectedItemColor: electricViolet,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: snowWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: snowWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
        ),
        modalElevation: 16,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: codGray,
        contentTextStyle: bodyS.copyWith(color: snowWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: alabaster,
        disabledColor: disabledBackground,
        selectedColor: electricViolet.withAlpha((0.2 * 255).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
          side: BorderSide.none,
        ),
        labelStyle: labelM,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );

    // Platform-specific adjustments
    if (Platform.isIOS) {
      // iOS-specific theme adjustments
      baseTheme = baseTheme.copyWith(
        // iOS prefers more rounded corners
        cardTheme: baseTheme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXL),
          ),
        ),
        // iOS has different button padding
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle(
            borderRadius: radiusXL,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        // iOS bottom nav bar is different
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: snowWhite,
          selectedItemColor: electricViolet,
          unselectedItemColor: secondaryText,
          selectedLabelStyle: TextStyle(fontSize: 10, fontFamily: fontInter),
          unselectedLabelStyle: TextStyle(fontSize: 10, fontFamily: fontInter),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );
    } else {
      // Android-specific theme adjustments
      baseTheme = baseTheme.copyWith(
        // Material Design 3 uses less rounded corners
        cardTheme: baseTheme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
        ),
        // Material buttons have more distinct touch ripple
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle(
            borderRadius: radiusL,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return snowWhite.withAlpha((0.15 * 255).toInt());
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
      );
    }

    return baseTheme;
  }
}
