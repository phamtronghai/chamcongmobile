import 'package:intl/intl.dart';

/// Constants cho format patterns
class DateTimeFormats {
  // Date formats
  static const String dateOnly = 'dd/MM/yyyy';
  static const String dateWithDay = 'EEEE, dd/MM/yyyy';
  static const String dateCompact = 'dd/MM/yy';

  // Time formats
  static const String timeOnly = 'HH:mm';
  static const String timeWithSeconds = 'HH:mm:ss';
  static const String time12Hour = 'hh:mm a';

  // DateTime formats
  static const String dateTimeFull = 'dd/MM/yyyy HH:mm';
  static const String dateTimeWithSeconds = 'dd/MM/yyyy HH:mm:ss';
  static const String dateTimeISO = 'yyyy-MM-dd HH:mm:ss';

  // Vietnam specific formats
  static const String vietnamDateTime = 'HH:mm:ss dd/M/yyyy';
  static const String vietnamDate = 'dd/M/yyyy';
}

/// Helper class để xử lý datetime utilities
/// Loại bỏ code lặp lại trong datetime formatting
class DateTimeHelper {
  /// Định dạng thời gian thành chuỗi theo kiểu "HH:MM:SS"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Định dạng thời gian với format tùy chỉnh
  static String formatTimeCustom(DateTime dateTime, {String format = 'HH:mm'}) {
    return DateFormat(format).format(dateTime);
  }

  /// Định dạng ngày thành chuỗi theo kiểu "DD/MM/YYYY"
  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }

  /// Định dạng ngày với format tùy chỉnh
  static String formatDateCustom(
    DateTime dateTime, {
    String format = DateTimeFormats.dateOnly,
  }) {
    return DateFormat(format).format(dateTime);
  }

  /// Định dạng ngày với locale
  static String formatDateWithLocale(
    DateTime dateTime,
    String locale, {
    String format = DateTimeFormats.dateWithDay,
  }) {
    return DateFormat(format, locale).format(dateTime);
  }

  /// Định dạng datetime đầy đủ theo kiểu "HH:MM:SS DD/MM/YYYY"
  static String formatDateTime(DateTime dateTime) {
    return '${formatTime(dateTime)} ${formatDate(dateTime)}';
  }

  /// Định dạng datetime theo kiểu Vietnam server "08:45:43 10/7/2025"
  static String formatVietnamDateTime(DateTime dateTime) {
    final time = formatTime(dateTime);
    final day = dateTime.day;
    final month = dateTime.month;
    final year = dateTime.year;
    return '$time $day/$month/$year';
  }

  /// Kiểm tra xem có phải cùng ngày không
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Lấy ngày hiện tại với thời gian 00:00:00
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Lấy ngày hôm qua với thời gian 00:00:00
  static DateTime getYesterday() {
    return getToday().subtract(const Duration(days: 1));
  }

  /// Lấy ngày mai với thời gian 00:00:00
  static DateTime getTomorrow() {
    return getToday().add(const Duration(days: 1));
  }

  /// Lấy start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Lấy end of day (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Định dạng datetime với format tùy chỉnh
  static String formatDateTimeCustom(
    DateTime dateTime, {
    String format = DateTimeFormats.dateTimeFull,
  }) {
    return DateFormat(format).format(dateTime);
  }

  static DateTime convertToTimezone(DateTime dateTime, String timezone) {
    return dateTime;
  }
}
