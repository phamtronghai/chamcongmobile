import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';
import 'package:attendancebyface/core/utils/datetime_helper.dart';

/// Mô hình dữ liệu thời gian từ API
class ServerDateTime {
  final String vietnam; // Định dạng "08:45:43 10/7/2025"
  final DateTime? parsedDateTime; // Thời gian đã được parse

  ServerDateTime({required this.vietnam, this.parsedDateTime});

  factory ServerDateTime.fromJson(Map<String, dynamic> json) {
    return ServerDateTime(
      vietnam: json['vietnam'] ?? '',
      parsedDateTime: json['parsedDateTime'],
    );
  }

  @override
  String toString() => 'ServerDateTime(vietnam: $vietnam)';
}

/// Repository để xử lý API calls liên quan đến thời gian server
class DateTimeRepository {
  final ApiClient _apiClient = ApiClient();
  static const String _dateEndpoint = '/api/date';

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Lấy thông tin thời gian hiện tại từ server
  Future<ServerDateTime> getCurrentDateTime() async {
    try {
      final response = await _apiClient.get(_dateEndpoint);

      // Parse response sử dụng helper
      final parsedData = ResponseParser.parseServerDateTimeResponse(response);
      return ServerDateTime.fromJson(parsedData);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thời gian server hiện tại
  /// Luôn gọi API để lấy thời gian mới nhất
  Future<DateTime?> getServerTime() async {
    try {
      final serverDateTime = await getCurrentDateTime();
      return serverDateTime.parsedDateTime;
    } catch (e) {
      return null;
    }
  }

  /// Định dạng thời gian thành chuỗi theo kiểu "HH:MM:SS"
  static String formatTime(DateTime dateTime) {
    return DateTimeHelper.formatTime(dateTime);
  }

  /// Định dạng ngày thành chuỗi theo kiểu "DD/MM/YYYY"
  static String formatDate(DateTime dateTime) {
    return DateTimeHelper.formatDate(dateTime);
  }

  /// Định dạng datetime đầy đủ theo kiểu "HH:MM:SS DD/MM/YYYY"
  static String formatDateTime(DateTime dateTime) {
    return DateTimeHelper.formatDateTime(dateTime);
  }

  /// Định dạng datetime theo kiểu Vietnam server
  static String formatVietnamDateTime(DateTime dateTime) {
    return DateTimeHelper.formatVietnamDateTime(dateTime);
  }
}
