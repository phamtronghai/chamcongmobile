import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/network/api_exception.dart';

/// Repository để xử lý tất cả API calls liên quan đến authentication
class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Đăng nhập bằng username và password
  Future<Map<String, dynamic>> signIn(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/sign-in/username',
        data: {
          'username': username.trim(),
          'password': password.trim(),
          'rememberMe': true,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thông tin session user
  Future<Map<String, dynamic>> getSession() async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.authEndpoint}/get-session',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  Future<bool> signOut() async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/sign-out',
        data: {},
      );

      if (response.statusCode == 200) {
        await _apiClient.clearCookies();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required bool revokeOtherSessions,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'revokeOtherSessions': revokeOtherSessions,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Đổi mật khẩu thất bại: ${response.data}',
          statusCode: response.statusCode,
        );
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
