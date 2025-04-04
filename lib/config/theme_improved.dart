// lib/config/theme_improved.dart
// Enhanced theme with improved typography, icon system, and platform compliance
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Comprehensive design system for KounselMe
/// Focuses on premium look, cross-platform consistency, and modern UI principles
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // =========================================================================
  // COLORS
  // =========================================================================

  // Brand Colors
  static const Color electricViolet = Color(0xFF5700E6);
  static const Color electricVioletLight =
      Color(0xFF7940EA); // Lighter shade for hover states
  static const Color electricVioletDark =
      Color(0xFF4500B8); // Darker shade for pressed states

  static const Color heliotrope = Color(0xFFB27BFB);
  static const Color heliotropeLight = Color(0xFFC496FC); // Lighter shade
  static const Color heliotropeDark = Color(0xFF9F5CF9); // Darker shade

  static const Color robinsGreen = Color(0xFF07D4BC);
  static const Color robinsGreenLight = Color(0xFF20E0C9); // Lighter shade
  static const Color robinsGreenDark = Color(0xFF06B09B); // Darker shade

  static const Color yellowSea = Color(0xFFFFB00C);
  static const Color yellowSeaLight = Color(0xFFFFBE3D); // Lighter shade
  static const Color yellowSeaDark = Color(0xFFE69C00); // Darker shade

  static const Color pink = Color(0xFFFFC5CB);

  // Neutrals
  static const Color snowWhite = Color(0xFFFFFFFF);
  static const Color alabaster = Color(0xFFF8F8F8); // Off-white for backgrounds
  static const Color gallery = Color(0xFFEEEEEE); // Light gray for dividers
  static const Color silver = Color(0xFFCCCCCC); // Medium gray
  static const Color boulder =
      Color(0xFF767676); // Dark gray for secondary text
  static const Color mineShaft = Color(0xFF333333); // Very dark gray
  static const Color codGray = Color(0xFF0D0D0D); // Almost black

  // Semantic Colors
  static const Color success = Color(0xFF34A853); // Google green
  static const Color successLight = Color(0xFFE6F4EA); // Light green background

  static const Color error = Color(0xFFEA4335); // Google red
  static const Color errorLight = Color(0xFFFCE8E6); // Light red background

  static const Color warning = Color(0xFFFBBC05); // Google yellow
  static const Color warningLight =
      Color(0xFFFEF7E0); // Light yellow background

  static const Color info = Color(0xFF4285F4); // Google blue
  static const Color infoLight = Color(0xFFE8F0FE); // Light blue background

  // Functional Colors
  static const Color background = snowWhite;
  static const Color surfaceBackground = alabaster;
  static const Color primaryText = codGray;
  static const Color secondaryText = boulder;
  static const Color divider = gallery;
  static const Color disabledText = silver;
  static const Color disabledBackground = gallery;

  // =========================================================================
  // TYPOGRAPHY
  // =========================================================================

  // Font Families (direct references instead of GoogleFonts for better performance)
  static const String fontInter = 'Inter';
  static const String fontManrope = 'Manrope';

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.7;

  // Font Weights
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;

  // Text Styles - Consistent naming pattern and solid colors (no opacity)
  static TextStyle get headingXL => TextStyle(
        fontFamily: fontManrope,
        fontSize: 32,
        fontWeight: weightBold,
        height: lineHeightTight,
        letterSpacing: -0.5,
        color: primaryText,
      );

  static TextStyle get headingL => TextStyle(
        fontFamily: fontManrope,
        fontSize: 28,
        fontWeight: weightBold,
        height: lineHeightTight,
        letterSpacing: -0.5,
        color: primaryText,
      );

  static TextStyle get headingM => TextStyle(
        fontFamily: fontManrope,
        fontSize: 24,
        fontWeight: weightBold,
        height: lineHeightTight,
        letterSpacing: -0.3,
        color: primaryText,
      );

  static TextStyle get headingS => TextStyle(
        fontFamily: fontManrope,
        fontSize: 20,
        fontWeight: weightBold,
        height: lineHeightTight,
        letterSpacing: -0.2,
        color: primaryText,
      );

  static TextStyle get headingXS => TextStyle(
        fontFamily: fontManrope,
        fontSize: 18,
        fontWeight: weightSemiBold,
        height: lineHeightTight,
        letterSpacing: -0.2,
        color: primaryText,
      );

  static TextStyle get subtitleL => TextStyle(
        fontFamily: fontManrope,
        fontSize: 18,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: -0.1,
        color: primaryText,
      );

  static TextStyle get subtitleM => TextStyle(
        fontFamily: fontManrope,
        fontSize: 16,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: -0.1,
        color: primaryText,
      );

  static TextStyle get subtitleS => TextStyle(
        fontFamily: fontManrope,
        fontSize: 14,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: 0,
        color: primaryText,
      );

  static TextStyle get bodyL => TextStyle(
        fontFamily: fontInter,
        fontSize: 18,
        fontWeight: weightRegular,
        height: lineHeightRelaxed,
        letterSpacing: -0.1,
        color: primaryText,
      );

  static TextStyle get bodyM => TextStyle(
        fontFamily: fontInter,
        fontSize: 16,
        fontWeight: weightRegular,
        height: lineHeightRelaxed,
        letterSpacing: -0.1,
        color: primaryText,
      );

  static TextStyle get bodyS => TextStyle(
        fontFamily: fontInter,
        fontSize: 14,
        fontWeight: weightRegular,
        height: lineHeightRelaxed,
        letterSpacing: 0,
        color: primaryText,
      );

  static TextStyle get bodyXS => TextStyle(
        fontFamily: fontInter,
        fontSize: 12,
        fontWeight: weightRegular,
        height: lineHeightNormal,
        letterSpacing: 0,
        color: primaryText,
      );

  static TextStyle get buttonL => TextStyle(
        fontFamily: fontInter,
        fontSize: 16,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: 0,
        color: snowWhite,
      );

  static TextStyle get buttonM => TextStyle(
        fontFamily: fontInter,
        fontSize: 14,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: 0,
        color: snowWhite,
      );

  static TextStyle get buttonS => TextStyle(
        fontFamily: fontInter,
        fontSize: 12,
        fontWeight: weightSemiBold,
        height: lineHeightNormal,
        letterSpacing: 0.25,
        color: snowWhite,
      );

  static TextStyle get labelL => TextStyle(
        fontFamily: fontInter,
        fontSize: 14,
        fontWeight: weightMedium,
        height: lineHeightNormal,
        letterSpacing: 0.25,
        color: primaryText,
      );

  static TextStyle get labelM => TextStyle(
        fontFamily: fontInter,
        fontSize: 12,
        fontWeight: weightMedium,
        height: lineHeightNormal,
        letterSpacing: 0.5,
        color: primaryText,
      );

  static TextStyle get labelS => TextStyle(
        fontFamily: fontInter,
        fontSize: 10,
        fontWeight: weightMedium,
        height: lineHeightNormal,
        letterSpacing: 0.5,
        color: primaryText,
      );

  // =========================================================================
  // SHAPE & DIMENSIONS
  // =========================================================================

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 1000.0; // For circular elements

  // Spacing
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing3XL = 32.0;
  static const double spacing4XL = 40.0;
  static const double spacing5XL = 48.0;
  static const double spacing6XL = 64.0;

  // Elevation (for shadow levels)
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  static const double elevationXXL = 16.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 40.0;

  // =========================================================================
  // COMPONENT STYLING
  // =========================================================================

  // Shadow Styles
  static List<BoxShadow> getShadow({
    required double elevation,
    Color? shadowColor,
  }) {
    final Color color = shadowColor ?? Colors.black;

    switch (elevation) {
      case elevationXS:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ];
      case elevationS:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ];
      case elevationM:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.09),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ];
      case elevationL:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.11),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ];
      case elevationXL:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.13),
            blurRadius: 24,
            spreadRadius: 3,
            offset: const Offset(0, 12),
          ),
        ];
      case elevationXXL:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
        ];
      default:
        return [];
    }
  }

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
      border: borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      boxShadow: getShadow(elevation: elevation, shadowColor: shadowColor),
    );
  }

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({
    Color? baseColor,
    double opacity = 0.2,
    double borderRadius = radiusL,
    double borderOpacity = 0.2,
  }) {
    final color = baseColor ?? snowWhite;
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withValues(alpha: borderOpacity),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.05),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Gradient Decoration
  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    double borderRadius = radiusL,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
        stops: stops,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // =========================================================================
  // BUTTON STYLES
  // =========================================================================

  // Primary Button Style
  static ButtonStyle primaryButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double elevation = elevationXS,
    double borderRadius = radiusL,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          final baseColor = backgroundColor ?? electricViolet;

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
          return foregroundColor ?? snowWhite;
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
      shadowColor:
          WidgetStateProperty.all(electricViolet.withValues(alpha: 0.3)),
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
            return baseColor.withValues(alpha: 0.05);
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withValues(alpha: 0.03);
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
            return baseColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withValues(alpha: 0.05);
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
            return baseColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return baseColor.withValues(alpha: 0.05);
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
        shadowColor: electricViolet.withValues(alpha: 0.08),
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
        selectedColor: electricViolet.withValues(alpha: 0.2),
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
                  return snowWhite.withValues(alpha: 0.15);
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
