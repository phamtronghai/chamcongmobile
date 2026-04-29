import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendancebyface/gen/assets.gen.dart';

/// Utility class để xử lý logic sinh trắc học chung
class BiometricHelper {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Xác định loại sinh trắc học chính của thiết bị
  /// Trả về null nếu không hỗ trợ sinh trắc học
  static Future<BiometricType?> getPrimaryBiometricType() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return null;

      // Ưu tiên Face ID nếu có
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      }
      // Sau đó là vân tay
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      // Các loại khác
      return availableBiometrics.first;
    } catch (e) {
      return null;
    }
  }

  /// Lấy thông tin hiển thị cho loại sinh trắc học (tên và icon)
  static Map<String, dynamic> getBiometricInfo(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return {
          'name': 'Face ID',
          'icon': null,
          'svgPath': Assets.icon.faceID.path,
        };
      case BiometricType.fingerprint:
        return {'name': 'Vân tay', 'icon': Icons.fingerprint, 'svgPath': null};
      case BiometricType.iris:
        return {'name': 'Mống mắt', 'icon': Icons.visibility, 'svgPath': null};
      default:
        return {
          'name': 'Sinh trắc học',
          'icon': Icons.fingerprint,
          'svgPath': null,
        };
    }
  }
}
