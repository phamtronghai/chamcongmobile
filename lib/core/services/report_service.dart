import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Gọi API để lấy báo cáo quân số theo ngày
  /// Trả về đường dẫn file PDF tạm thời
  Future<String?> getQuanSoReport(String dateStr) async {
    try {
      final response = await _apiClient.post(
        '/quanso/request',
        data: {'dateStr': dateStr},
        options: Options(
          responseType: ResponseType.bytes, // Quan trọng: nhận binary data
        ),
      );

      if (response.statusCode == 200) {
        // Lưu file PDF vào thư mục tạm thời
        final tempDir = await getTemporaryDirectory();
        final fileName = 'quanso_report_$dateStr.pdf';
        final file = File('${tempDir.path}/$fileName');

        // Lưu binary data từ response
        await file.writeAsBytes(response.data);

        return file.path;
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền truy cập báo cáo này');
      } else {
        throw Exception('Lỗi khi tải báo cáo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền truy cập báo cáo này');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Lỗi kết nối mạng. Vui lòng thử lại.');
      } else {
        throw Exception('Lỗi khi gọi API báo cáo: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API báo cáo: ${e.toString()}');
    }
  }

  /// Kiểm tra quyền xem báo cáo chấm công dựa trên user ID
  bool hasPermissionViewAttendanceReport(String userId) {
    return AppConfig.hasPermissionViewAttendanceReportIds.contains(userId);
  }
}
