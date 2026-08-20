import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';

/// Helper class để lấy device identifier (UUID)
/// Lưu device ID vào secure storage để đảm bảo persistent
class DeviceIdHelper {
  static const String _deviceIdKey = 'device_id';

  /// Lấy device identifier (UUID)
  /// Nếu chưa có, tạo mới và lưu vào secure storage
  static Future<String> getDeviceId() async {
    // Kiểm tra xem đã có device ID trong storage chưa
    final storedDeviceId = await SecureStorage.getString(_deviceIdKey);
    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      return storedDeviceId;
    }

    // Nếu chưa có, lấy device identifier từ thiết bị
    String deviceId;
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Sử dụng androidId (unique cho mỗi thiết bị, persistent)
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Sử dụng identifierForVendor (unique cho mỗi app trên thiết bị)
        deviceId = iosInfo.identifierForVendor ?? _generateFallbackId();
      } else {
        // Fallback cho các platform khác
        deviceId = _generateFallbackId();
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy device ID: $e');
      // Fallback: tạo UUID ngẫu nhiên
      deviceId = _generateFallbackId();
    }

    // Lưu device ID vào secure storage
    await SecureStorage.setString(_deviceIdKey, deviceId);

    return deviceId;
  }

  /// Tạo fallback ID nếu không lấy được device identifier
  static String _generateFallbackId() {
    // Tạo UUID đơn giản dựa trên timestamp và random
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'fallback_$random';
  }
}

