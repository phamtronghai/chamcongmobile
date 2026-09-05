import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:attendancebyface/models/admin_org_models.dart';

/// UserId được phép chấm công thủ công từ sheet Quản trị.
const String kAdminManualAttendanceUserId = 'RJhupIEbULQXEzx51jIS423MkwyRwai1';

/// Slug được phép chấm công thủ công trên tab Chấm công (AttendanceScreen).
const String kManualAttendanceDepartmentSlug = 'to-ncpt-khoa-hoc-cong-nghe';

/// API quản trị: danh sách phòng ban + nhân viên theo slug + hành động admin.
class AdminService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/slug → [{ slug, department }, ...]
  Future<List<AdminDepartment>> fetchDepartments() async {
    try {
      final response = await _apiClient.get('/api/slug');
      final data = response.data;
      if (data is! List) {
        throw Exception('API /api/slug không trả về danh sách');
      }
      final list = data
          .map((e) => AdminDepartment.fromJson(e as Map<String, dynamic>))
          .toList();
      debugLog('🏢 Phòng ban: ${list.length}');
      return list;
    } catch (e) {
      debugLog('❌ Lỗi GET /api/slug: $e');
      rethrow;
    }
  }

  /// GET /employees?slug= → { data: [...] }
  Future<List<AdminEmployee>> fetchEmployees(String slug) async {
    try {
      final response = await _apiClient.get(
        '/employees',
        queryParameters: {'slug': slug},
      );
      final body = response.data;
      final List<dynamic> raw;
      if (body is Map<String, dynamic>) {
        raw = body['data'] as List<dynamic>? ?? const [];
      } else if (body is List) {
        raw = body;
      } else {
        raw = const [];
      }
      final list = raw
          .map(
            (e) => AdminEmployee.fromJson(
              e as Map<String, dynamic>,
              departmentSlug: slug,
            ),
          )
          .toList();
      debugLog('👥 NV ($slug): ${list.length}');
      return list;
    } catch (e) {
      debugLog('❌ Lỗi GET /employees?slug=$slug: $e');
      rethrow;
    }
  }

  /// POST /api/auth/admin/set-user-password
  Future<void> setUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/api/auth/admin/set-user-password',
        data: {'userId': userId, 'newPassword': newPassword},
      );
      debugLog('🔑 Đặt lại mật khẩu: $userId');
    } catch (e) {
      debugLog('❌ Lỗi set-user-password: $e');
      rethrow;
    }
  }

  /// DELETE /face/delete-faceid với body { userId }
  Future<void> deleteFaceId(String userId) async {
    try {
      await _apiClient.delete('/face/delete-faceid', data: {'userId': userId});
      debugLog('🗑️ Xoá khuôn mặt: $userId');
    } catch (e) {
      debugLog('❌ Lỗi delete-faceid: $e');
      rethrow;
    }
  }

  /// Ghép baseUrl Dio với path ảnh tương đối.
  String toAbsoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    final base = _apiClient.dio.options.baseUrl;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$normalizedBase$normalizedPath';
  }
}
