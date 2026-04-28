import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/models/approver.dart';

/// Service để lấy danh sách người duyệt từ API
class ApproverService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách người quản lý phòng ban
  Future<List<Approver>> getDepartmentManagers() async {
    try {
      final response = await _apiClient.get('/api/my_manager');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => Approver.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load department managers: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách ban giám đốc
  Future<List<Approver>> getBoardOfDirectors() async {
    try {
      final response = await _apiClient.get('/api/ceo');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => Approver.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load board of directors: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy tất cả người duyệt (cả phòng ban và ban giám đốc)
  Future<ApproverGroups> getAllApprovers() async {
    try {
      final results = await Future.wait([
        getDepartmentManagers(),
        getBoardOfDirectors(),
      ]);

      return ApproverGroups.fromLists(
        managers: results[0],
        directors: results[1],
      );
    } catch (e) {
      rethrow;
    }
  }
}
