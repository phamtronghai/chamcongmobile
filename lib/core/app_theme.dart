import 'package:flutter/material.dart';
// Consolidated constants live here to avoid scattering theme primitives

class ColorConstants {
  // Brand colors
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color accentColor = Color(0xFF06B6D4);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // Sizing
  static const double defaultBorderRadius = 24.0;

  // Shadow
  static const Color shadowColor = Color(0x40000000);
}

class TextConstants {
  // Font sizes
  static const double heading = 16.0;
  static const double body = 14.0;
  static const double caption = 12.0;
  static const double small = 10.0;

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTheme {
  // Các thuộc tính dùng chung cho cả hai theme
  static TextTheme _buildTextTheme() {
    const fontFamily = 'Overpass';
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.semiBold,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.medium,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.semiBold,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.medium,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.heading,
        fontWeight: TextConstants.semiBold,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.body,
        fontWeight: TextConstants.medium,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.body,
        fontWeight: TextConstants.regular,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.body,
        fontWeight: TextConstants.regular,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.caption,
        fontWeight: TextConstants.regular,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.small,
        fontWeight: TextConstants.regular,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.body,
        fontWeight: TextConstants.medium,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.caption,
        fontWeight: TextConstants.medium,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: TextConstants.small,
        fontWeight: TextConstants.medium,
      ),
    );
  }

  static final _commonTextTheme = _buildTextTheme();

  static const _commonButtonTheme = ButtonStyle(
    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(ColorConstants.defaultBorderRadius),
        ),
      ),
    ),
    padding: WidgetStatePropertyAll<EdgeInsets>(
      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static const _commonAppBarTheme = AppBarTheme(
    centerTitle: true,
    elevation: 0,
  );

  // Theme sáng
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ColorConstants.primaryColor,
      colorScheme: ColorScheme.light(
        primary: ColorConstants.primaryColor,
        secondary: ColorConstants.accentColor,
        surface: Colors.white,
        onSurface: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: _commonTextTheme.copyWith(
        bodyLarge: _commonTextTheme.bodyLarge?.copyWith(color: Colors.black),
        bodyMedium: _commonTextTheme.bodyMedium?.copyWith(
          color: const Color(0xFF757575),
        ),
      ),
      appBarTheme: _commonAppBarTheme.copyWith(
        backgroundColor: ColorConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _commonButtonTheme.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(
            ColorConstants.primaryColor,
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
        ),
      ),
      dividerColor: const Color(0xFFE0E0E0),
      iconTheme: const IconThemeData(color: ColorConstants.primaryColor),
    );
  }

  // Theme tối
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: ColorConstants.primaryColor,
      colorScheme: ColorScheme.dark(
        primary: ColorConstants.primaryColor,
        secondary: ColorConstants.accentColor,
        surface: const Color(0xFF333333),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      textTheme: _commonTextTheme.copyWith(
        bodyLarge: _commonTextTheme.bodyLarge?.copyWith(color: Colors.white),
        bodyMedium: _commonTextTheme.bodyMedium?.copyWith(
          color: const Color(0xFFBDBDBD),
        ),
      ),
      appBarTheme: _commonAppBarTheme.copyWith(
        backgroundColor: const Color(0xFF333333),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: const Color(0xFF424242),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _commonButtonTheme.copyWith(
          backgroundColor: WidgetStatePropertyAll<Color>(
            ColorConstants.primaryColor,
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
        ),
      ),
      dividerColor: const Color(0xFF616161),
      iconTheme: IconThemeData(color: ColorConstants.primaryColor),
    );
  }

  // Phương thức để lấy màu dựa trên độ sáng
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
}

// ThemeNotifier để quản lý chế độ tối
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }
}
