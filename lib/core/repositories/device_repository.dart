import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:attendancebyface/core/network/api_client.dart';

/// Repository quản lý device info (FCM token)
class DeviceRepository {
  final ApiClient _apiClient = ApiClient();

  String _getPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      default:
        return 'unknown';
    }
  }

  /// Đăng ký FCM token lên server
  Future<void> registerFcmToken({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/register-device',
        data: {'token': token, 'platform': _getPlatform(), 'userId': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Hủy đăng ký FCM token khỏi server
  Future<void> unregisterFcmToken({required String token}) async {
    try {
      await _apiClient.delete(
        '/delete-device',
        data: {'token': token},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      rethrow;
    }
  }
}
