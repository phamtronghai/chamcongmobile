import 'package:flutter/material.dart';

class ColorConstants {
  /// Brand (sáng). Dark theme map sang trắng qua [ColorScheme.primary].
  static const Color primaryColor = Color(0xFF627F48);

  static const Color successColor = Color(0xFF1DB923);
  static const Color errorColor = Color(0xFFFF1100);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF3D5A80);

  static const double defaultBorderRadius = 36.0;

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

class AppTheme {
  static const _radius = ColorConstants.defaultBorderRadius;

  static ShapeBorder get _dialogShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_radius),
  );

  static ShapeBorder get _sheetShape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
  );

  static ThemeData get lightTheme {
    const primary = ColorConstants.primaryColor;
    const onPrimary = ColorConstants.backgroundLight;
    const background = ColorConstants.backgroundLight;

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: TextConstants.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
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

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: TextConstants.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
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
