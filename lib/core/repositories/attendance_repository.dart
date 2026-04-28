import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Repository để xử lý tất cả API calls liên quan đến attendance
class AttendanceRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Lấy lịch sử chấm công theo ngày
  Future<List<AttendanceModel>> getAttendancesByDate(String date) async {
    try {
      // Format ngày theo định dạng yyyy-MM-dd
      final dateFormatted = date.isNotEmpty
          ? date
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await _apiClient.get(
        '/api/attendances_date_face',
        queryParameters: {'date': dateFormatted},
      );

      // Parse response sử dụng helper
      final responseData = ResponseParser.parseAttendanceHistoryResponse(
        response,
      );

      // Convert raw data thành AttendanceModel list
      debugPrint('Đã nhận ${responseData.length} bản ghi chấm công');
      final List<AttendanceModel> attendances = [];

      for (var item in responseData) {
        try {
          if (item is Map) {
            attendances.add(
              AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        } catch (e) {
          debugPrint('Lỗi khi chuyển đổi bản ghi: $e');
        }
      }

      return attendances;
    } catch (e) {
      return [];
    }
  }

  /// Chấm công thủ công (manual attendance)
  /// Gọi API POST /api/add_attendance_tracking với recordTime và userId
  Future<Map<String, dynamic>> addAttendanceManual({
    required String recordTime, // Format: "YYYY-MM-DDTHH:mm:00" (UTC)
    required String userId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/add_attendance_tracking',
        data: {'recordTime': recordTime, 'userId': userId},
      );

      // Kiểm tra status code
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Chấm công thành công'};
      } else {
        return {
          'success': false,
          'message': 'Chấm công thất bại: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error adding manual attendance: $e');
      return {
        'success': false,
        'message': 'Lỗi khi chấm công: ${e.toString()}',
      };
    }
  }
}
