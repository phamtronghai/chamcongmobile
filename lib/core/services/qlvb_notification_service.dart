import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:attendancebyface/models/qlvb_notification.dart';

/// API thông báo công việc QLVB (`/api/qlvb/notifications`).
class QlvbNotificationService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/qlvb/notifications
  Future<List<QlvbNotification>> fetchNotifications() async {
    try {
      final response = await _apiClient.get('/api/qlvb/notifications');
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
          .whereType<Map>()
          .map((e) => QlvbNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      debugLog('📬 QLVB notifications: ${list.length}');
      return list;
    } catch (e) {
      debugLog('❌ Lỗi GET /api/qlvb/notifications: $e');
      rethrow;
    }
  }

  /// GET /api/qlvb/notifications/unread-count
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get(
        '/api/qlvb/notifications/unread-count',
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final count = data['unread_count'];
          if (count is int) return count;
          if (count is num) return count.toInt();
          return int.tryParse('$count') ?? 0;
        }
      }
      return 0;
    } catch (e) {
      debugLog('❌ Lỗi GET unread-count: $e');
      rethrow;
    }
  }

  /// POST /api/qlvb/notifications/{notificationUid}/read
  Future<void> markAsRead(String notificationUid) async {
    try {
      await _apiClient.post(
        '/api/qlvb/notifications/$notificationUid/read',
      );
      debugLog('✅ QLVB read: $notificationUid');
    } catch (e) {
      debugLog('❌ Lỗi mark read: $e');
      rethrow;
    }
  }

  /// POST /api/qlvb/notifications/read-all
  Future<int> markAllAsRead() async {
    try {
      final response = await _apiClient.post(
        '/api/qlvb/notifications/read-all',
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          final affected = data['affected'];
          if (affected is int) return affected;
          if (affected is num) return affected.toInt();
          return int.tryParse('$affected') ?? 0;
        }
      }
      return 0;
    } catch (e) {
      debugLog('❌ Lỗi read-all: $e');
      rethrow;
    }
  }

  /// DELETE /api/qlvb/notifications/{notificationUid}
  Future<void> deleteNotification(String notificationUid) async {
    try {
      await _apiClient.delete('/api/qlvb/notifications/$notificationUid');
      debugLog('🗑️ QLVB delete: $notificationUid');
    } catch (e) {
      debugLog('❌ Lỗi delete notification: $e');
      rethrow;
    }
  }
}
