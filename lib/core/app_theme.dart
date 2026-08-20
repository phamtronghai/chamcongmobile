import 'package:flutter/material.dart';

class ColorConstants {
  /// Brand (sáng). Dark theme map sang trắng qua [ColorScheme.primary].
  static const Color primaryColor = Color(0xFF627F48);

  static const Color successColor = Color(0xFF1DB923);
  static const Color errorColor = Color(0xFFFF1100);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF3D5A80);

  static const double defaultBorderRadius = 48.0;

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF000000);
}

class TextConstants {
  static const double fontSizeApp = 16.0;
  static const String fontFamily = 'BeVietnamPro';

  static const TextStyle appTextRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeApp,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle appTextMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeApp,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle appTextSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeApp,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle appTextBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeApp,
    fontWeight: FontWeight.w700,
  );
}

class ButtonConstants {
  static const double heightButton = 56.0;
  static const double iconSize = 20.0;
  static const double iconButtonSize = 48.0;

  static Color ctaForegroundOn(Color primary) =>
      primary.computeLuminance() > 0.5
      ? ColorConstants.backgroundDark
      : ColorConstants.backgroundLight;
}

class SegmentedButtonConstants {
  static const double height = 44.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 10.0;
}

class AppTheme {
  static const _radius = ColorConstants.defaultBorderRadius;

  static ShapeBorder get _dialogShape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius));

  static ShapeBorder get _sheetShape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
  );

  static SegmentedButtonThemeData _segmentedButtonTheme({
    required Color primary,
    required Color onSurface,
  }) {
    final radius = BorderRadius.circular(_radius);
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(TextConstants.appTextBold),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(
            horizontal: SegmentedButtonConstants.horizontalPadding,
            vertical: SegmentedButtonConstants.verticalPadding,
          ),
        ),
        minimumSize: WidgetStatePropertyAll(
          const Size(0, SegmentedButtonConstants.height),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ButtonConstants.ctaForegroundOn(primary);
          }
          return onSurface;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return onSurface.withValues(alpha: 0.12);
        }),
        side: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? primary
              : primary.withValues(alpha: 0.35);
          return BorderSide(color: color, width: 1.5);
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    const primary = ColorConstants.primaryColor;
    const onPrimary = ColorConstants.backgroundLight;
    const background = ColorConstants.backgroundLight;

    const onSurface = Color(0xFF1C1B1F);

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: TextConstants.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        onSurface: onSurface,
      ),
      segmentedButtonTheme: _segmentedButtonTheme(
        primary: primary,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: background,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: primary,
      ),
      dialogTheme: DialogThemeData(shape: _dialogShape),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        shape: _sheetShape,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const primary = ColorConstants.backgroundLight;
    const onPrimary = ColorConstants.backgroundDark;
    const background = ColorConstants.backgroundDark;

    const onSurface = ColorConstants.backgroundLight;

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: TextConstants.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        onSurface: onSurface,
      ),
      segmentedButtonTheme: _segmentedButtonTheme(
        primary: primary,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: background,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: primary,
      ),
      dialogTheme: DialogThemeData(shape: _dialogShape),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        shape: _sheetShape,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    bodyLarge: TextConstants.appTextRegular,
    bodyMedium: TextConstants.appTextRegular,
    titleMedium: TextConstants.appTextBold,
    titleSmall: TextConstants.appTextSemiBold,
    labelLarge: TextConstants.appTextBold,
    labelMedium: TextConstants.appTextMedium,
  );
}
