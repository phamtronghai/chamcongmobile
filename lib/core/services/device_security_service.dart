import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendancebyface/core/utils/device_security_helper.dart';
import 'package:attendancebyface/widgets/security_alert_dialog.dart';

/// Class để lưu kết quả kiểm tra bảo mật
class SecurityCheckResult {
  final bool isSafe;
  final String message;
  final Map<String, dynamic> details;

  SecurityCheckResult(this.isSafe, this.message, {this.details = const {}});
}

/// Service để xử lý business logic cho device security checks
class DeviceSecurityService {
  /// Kiểm tra tất cả các điều kiện bảo mật của thiết bị
  /// Thứ tự: realDevice → jailbreak → quyền location → mock location → development mode
  /// Tất cả kiểm tra được thực hiện song song
  Future<SecurityCheckResult> checkDeviceSecurity() async {
    // Nếu ở chế độ dev, bỏ qua hoàn toàn kiểm tra bảo mật
    if (DeviceSecurityHelper.devMode) {
      return SecurityCheckResult(
        true,
        'Dev mode - Thiết bị an toàn',
        details: {
          'isRealDevice': true,
          'isJailBroken': false,
          'hasLocationPermission': true,
          'isMockLocation': false,
          'isDevelopmentModeEnable': false,
          'devMode': true,
        },
      );
    }

    try {
      Map<String, dynamic> securityDetails = {};
      List<String> securityIssues = [];

      // Kiểm tra song song tất cả các điều kiện
      final results = await Future.wait([
        // 1. Kiểm tra thiết bị thật (iOS/Android)
        DeviceSecurityHelper.checkRealDevice(),
        // 2. Kiểm tra jailbreak/root (iOS/Android)
        DeviceSecurityHelper.checkJailbreakStatus(),
        // 3. Kiểm tra development mode (chỉ Android)
        DeviceSecurityHelper.checkDevelopmentMode(),
      ]);

      // Tổng hợp kết quả từ các check song song
      for (final result in results) {
        final resultMap = Map<String, dynamic>.from(result);
        securityDetails.addAll(resultMap);
        final issues = resultMap['issues'];
        if (issues is List) {
          securityIssues.addAll(issues.map((e) => e.toString()).toList());
        }
      }

      // Log kết quả
      DeviceSecurityHelper.logSecurityResults(securityDetails);

      if (securityIssues.isNotEmpty) {
        // Gộp tất cả các lỗi vào một message
        String errorMessage = securityIssues.join(', ');
        String message = 'Thiết bị không an toàn: $errorMessage';
        return SecurityCheckResult(false, message, details: securityDetails);
      }

      return SecurityCheckResult(
        true,
        'Thiết bị an toàn',
        details: securityDetails,
      );
    } on PlatformException catch (e) {
      final errorMessage = DeviceSecurityHelper.handlePlatformException(e);
      return SecurityCheckResult(false, errorMessage);
    } catch (e) {
      final errorMessage = DeviceSecurityHelper.handleGenericException(e);
      return SecurityCheckResult(false, errorMessage);
    }
  }

  /// Hiển thị dialog cảnh báo bảo mật (wrapper cho SecurityAlertDialog)
  Future<void> showSecurityAlert(
    BuildContext context,
    String message, [
    Map<String, dynamic>? details,
  ]) async {
    return SecurityAlertDialog.show(context: context, message: message);
  }

  /// Kiểm tra và hiển thị cảnh báo nếu thiết bị không an toàn
  Future<bool> validateDeviceSecurity(BuildContext context) async {
    try {
      SecurityCheckResult result = await checkDeviceSecurity();

      if (!result.isSafe) {
        if (context.mounted) {
          await showSecurityAlert(context, result.message, result.details);
        }
        return false;
      }
      return true;
    } catch (e) {
      // Nếu có lỗi trong validate, mặc định chặn để bảo mật
      if (context.mounted) {
        await showSecurityAlert(context, 'Lỗi kiểm tra bảo mật thiết bị', {});
      }
      return false;
    }
  }

  /// Kiểm tra nhanh thiết bị có an toàn không (không hiển thị dialog)
  Future<bool> isDeviceSafe() async {
    try {
      final result = await checkDeviceSecurity();
      return result.isSafe;
    } catch (e) {
      // Mặc định trả về false để bảo mật
      return false;
    }
  }

  /// Lấy thông tin chi tiết về bảo mật thiết bị
  Future<Map<String, dynamic>> getDeviceSecurityDetails() async {
    try {
      final result = await checkDeviceSecurity();
      return result.details;
    } catch (e) {
      return {};
    }
  }
}
