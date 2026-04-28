import 'dart:convert';

import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/models/worklog_model.dart';
import 'package:dio/dio.dart';

/// Repository để xử lý API worklog (nhập & xem công việc)
class WorklogRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Tạo một worklog cho user theo ngày
  ///
  /// Trả về map gồm:
  /// - success: bool
  /// - message: String
  Future<Map<String, dynamic>> createWorklog({
    required String userId,
    required String workName,
    required String date,
    required int sessionId,
    String workDescription = '',
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/worklogs',
        data: <String, dynamic>{
          'userId': userId,
          'workDescription': workDescription,
          'workName': workName,
          'sessionId': sessionId,
          'date': date,
        },
        options: Options(
          // API hiện trả về text/plain nhưng nội dung là JSON
          responseType: ResponseType.plain,
        ),
      );

      final rawData = response.data;
      Map<String, dynamic> data;

      if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else {
        data = <String, dynamic>{};
      }

      final success = data['success'] == true;
      final message = data['message']?.toString() ?? '';

      return <String, dynamic>{'success': success, 'message': message};
    } on DioException catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': e.message ?? 'Lỗi kết nối hoặc server',
      };
    } catch (e) {
      return <String, dynamic>{'success': false, 'message': e.toString()};
    }
  }

  /// Lấy danh sách worklog theo khoảng ngày (from-to) cho 1 user
  Future<List<WorklogModel>> getWorklogsFromTo({
    required String userId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/count/fromTo',
        queryParameters: <String, dynamic>{
          'from': fromDate,
          'to': toDate,
          'userId': userId,
        },
      );

      final data = response.data;
      if (data == null || data['result'] is! List) {
        return <WorklogModel>[];
      }

      final List<dynamic> rawList = data['result'] as List<dynamic>;
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(WorklogModel.fromJson)
          .toList();
    } on DioException {
      return <WorklogModel>[];
    } catch (_) {
      return <WorklogModel>[];
    }
  }

  /// Lấy worklog theo 1 ngày (from = to = dateStr)
  Future<List<WorklogModel>> getWorklogsByDate({
    required String userId,
    required String dateStr,
  }) async {
    return getWorklogsFromTo(
      userId: userId,
      fromDate: dateStr,
      toDate: dateStr,
    );
  }
}
