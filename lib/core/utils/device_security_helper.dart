// ignore_for_file: unintended_html_in_doc_comment

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Helper class để xử lý device security utilities
/// Loại bỏ code lặp lại trong device security processing
class DeviceSecurityHelper {
  /// Cờ để bật/tắt chế độ development (bỏ qua kiểm tra bảo mật)
  static const bool devMode = true;

  /// Kiểm tra thiết bị thật (chặn emulator/simulator)
  /// Trả về Map với 'isRealDevice' (bool) và 'issues' (List<String>)
  static Future<Map<String, dynamic>> checkRealDevice() async {
    // Nếu ở chế độ dev, bỏ qua kiểm tra
    if (devMode) {
      return {'isRealDevice': true, 'issues': []};
    }

    bool isRealDevice = await SafeDevice.isRealDevice;
    List<String> issues = [];

    if (!isRealDevice) {
      issues.add('Ứng dụng không thể chạy trên emulator/simulator');
    }

    return {'isRealDevice': isRealDevice, 'issues': issues};
  }

  /// Kiểm tra jailbreak/root
  /// Trả về Map với 'isJailBroken'
  static Future<Map<String, dynamic>> checkJailbreakStatus() async {
    Map<String, dynamic> result = {};
    List<String> issues = [];

    // Nếu ở chế độ dev, bỏ qua kiểm tra
    if (devMode) {
      result['isJailBroken'] = false;
      result['issues'] = issues;
      return result;
    }

    bool isJailBroken = await SafeDevice.isJailBroken;
    result['isJailBroken'] = isJailBroken;

    if (isJailBroken) {
      issues.add('Thiết bị đã bị jailbreak/root');
    }

    result['issues'] = issues;
    return result;
  }

  /// Kiểm tra quyền truy cập vị trí
  /// Trả về Map với 'hasLocationPermission' (bool) và 'issues' (List<String>)
  static Future<Map<String, dynamic>> checkLocationPermission() async {
    // Nếu ở chế độ dev, bỏ qua kiểm tra
    if (devMode) {
      return {'hasLocationPermission': true, 'issues': []};
    }

    List<String> issues = [];

    // Kiểm tra quyền location
    LocationPermission permission = await Geolocator.checkPermission();

    // Nếu quyền bị từ chối, yêu cầu quyền
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Kiểm tra quyền đã được cấp chưa
    bool hasPermission =
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    // Nếu không có quyền (bao gồm cả deniedForever), thêm vào issues
    if (!hasPermission) {
      if (permission == LocationPermission.deniedForever) {
        issues.add('Không có quyền truy cập vị trí (đã bị từ chối vĩnh viễn)');
      } else {
        issues.add('Không có quyền truy cập vị trí');
      }
    }

    return {'hasLocationPermission': hasPermission, 'issues': issues};
  }

  /// Kiểm tra mock location (yêu cầu quyền location trước)
  /// Trả về Map với 'isMockLocation' (bool), 'hasLocationPermission' (bool) và 'issues' (List<String>)
  static Future<Map<String, dynamic>> checkMockLocation() async {
    // Chỉ kiểm tra Fake GPS / Mock Location trên Android, bỏ qua trên iOS
    if (!Platform.isAndroid) {
      return {
        'isMockLocation': false,
        'hasLocationPermission': true,
        'issues': [],
      };
    }

    // Nếu ở chế độ dev, bỏ qua kiểm tra
    if (devMode) {
      return {
        'isMockLocation': false,
        'hasLocationPermission': true,
        'issues': [],
      };
    }

    // Kiểm tra quyền location trước
    final permissionResult = await checkLocationPermission();
    final hasPermission =
        permissionResult['hasLocationPermission'] as bool? ?? false;
    final permissionIssues =
        (permissionResult['issues'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Merge kết quả quyền location vào kết quả trả về
    Map<String, dynamic> result = {'hasLocationPermission': hasPermission};

    if (!hasPermission) {
      // Nếu không có quyền, trả về lỗi và không kiểm tra mock location
      result['isMockLocation'] = false;
      result['issues'] = permissionIssues;
      return result;
    }

    // Nếu có quyền, kiểm tra mock location
    bool isMockLocation = await SafeDevice.isMockLocation;
    List<String> issues = List.from(permissionIssues);

    if (isMockLocation) {
      issues.add('Phát hiện giả mạo vị trí');
    }

    result['isMockLocation'] = isMockLocation;
    result['issues'] = issues;
    return result;
  }

  /// Kiểm tra development mode (chỉ Android)
  /// Trả về Map với 'isDevelopmentModeEnable' (bool) và 'issues' (List<String>)
  static Future<Map<String, dynamic>> checkDevelopmentMode() async {
    // Nếu ở chế độ dev, bỏ qua kiểm tra
    if (devMode) {
      return {'isDevelopmentModeEnable': false, 'issues': []};
    }

    // Chỉ kiểm tra trên Android
    if (!Platform.isAndroid) {
      return {'isDevelopmentModeEnable': false, 'issues': []};
    }

    bool isDevelopmentModeEnable = await SafeDevice.isDevelopmentModeEnable;
    List<String> issues = [];

    if (isDevelopmentModeEnable) {
      issues.add('Chế độ nhà phát triển đang được bật');
    }

    return {
      'isDevelopmentModeEnable': isDevelopmentModeEnable,
      'issues': issues,
    };
  }

  /// Xử lý PlatformException
  static String handlePlatformException(PlatformException e) {
    debugPrint("💥 PlatformException khi kiểm tra bảo mật: ${e.message}");
    debugPrint("Error code: ${e.code}");
    debugPrint("Error details: ${e.details}");

    return 'Lỗi kiểm tra bảo mật: ${e.message}';
  }

  /// Xử lý Exception chung
  static String handleGenericException(dynamic e) {
    debugPrint("💥 Exception không xác định khi kiểm tra bảo mật: $e");
    debugPrint("Exception type: ${e.runtimeType}");

    return 'Lỗi không xác định khi kiểm tra bảo mật';
  }

  /// Log kết quả kiểm tra bảo mật
  static void logSecurityResults(Map<String, dynamic> details) {
    if (devMode) {
      debugPrint("🔧 DEV MODE: Bỏ qua kiểm tra bảo mật");
      return;
    }

    debugPrint("📊 Tóm tắt kiểm tra bảo mật:");
    debugPrint("   - Real Device: ${details['isRealDevice']}");
    debugPrint("   - Jailbreak: ${details['isJailBroken']}");
    debugPrint("   - Location Permission: ${details['hasLocationPermission']}");
    debugPrint("   - Mock Location: ${details['isMockLocation']}");
    if (Platform.isAndroid) {
      debugPrint(
        "   - Development Mode: ${details['isDevelopmentModeEnable']}",
      );
    }
  }
}
