import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:attendancebyface/core/repositories/face_repository.dart';
import 'package:attendancebyface/screens/camera_screen.dart';
import 'base_service.dart';

/// Service để xử lý tất cả business logic liên quan đến face recognition
class FaceService extends BaseService {
  final FaceRepository _faceRepository = FaceRepository();
  Uint8List? _lastCapturedImage;

  /// Khởi tạo service
  @override
  Future<void> init() async {
    await _faceRepository.init();
  }

  /// Chụp ảnh bằng camera
  Future<File?> captureFaceWithCamera(BuildContext context) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );

      return result is File ? result : null;
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra liveness từ ảnh đã chụp
  Future<LivenessResult> detectLiveness(Uint8List faceImageBytes) async {
    try {
      // Tạo file tạm và thực hiện liveness check
      final tempFile = File(
        '${Directory.systemTemp.path}/face_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(faceImageBytes);

      try {
        final livenessResult = await _faceRepository.checkLiveness(tempFile);
        return LivenessResult(isReal: livenessResult['isReal'] ?? false);
      } finally {
        // Cleanup temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    } catch (e) {
      return LivenessResult(isReal: false);
    }
  }

  /// Dự đoán liveness từ camera và API
  Future<LivenessResultWithImage> detectLivenessWithCamera(
    BuildContext context,
  ) async {
    try {
      // 1. Chụp ảnh
      final imageFile = await captureFaceWithCamera(context);
      if (imageFile == null) {
        return LivenessResultWithImage(isReal: false, imageBytes: null);
      }

      // 2. Đọc ảnh thành bytes
      final imageBytes = await imageFile.readAsBytes();

      // 3. Lưu ảnh vào memory
      _lastCapturedImage = imageBytes;

      // 4. Kiểm tra liveness với ảnh đã chụp
      final liveness = await detectLiveness(_lastCapturedImage!);

      return LivenessResultWithImage(
        isReal: liveness.isReal,
        imageBytes: _lastCapturedImage, // Trả về ảnh gốc
      );
    } catch (e) {
      return LivenessResultWithImage(isReal: false, imageBytes: null);
    }
  }

  /// Kiểm tra khuôn mặt với API (API mới: /face/check-face_1)
  Future<Map<String, dynamic>> checkFace({
    required File imageFile,
    required String lat,
    required String longValue,
    required String deviceID,
  }) async {
    return await handleServiceCall(
      () => _faceRepository.checkFace(
        imageFile: imageFile,
        lat: lat,
        longValue: longValue,
        deviceID: deviceID,
      ),
    );
  }

  /// Đăng ký khuôn mặt
  Future<Map<String, dynamic>> registerFace({
    required List<File> images,
  }) async {
    return await handleServiceCall(
      () => _faceRepository.registerFace(images: images),
    );
  }

  /// Kiểm tra xem người dùng đã đăng ký khuôn mặt chưa
  Future<bool> checkRegistered(String userId) async {
    try {
      return await _faceRepository.checkRegistered(userId);
    } catch (e) {
      return false;
    }
  }

  /// Xóa khuôn mặt đã đăng ký
  Future<bool> deleteFace(String userId) async {
    try {
      return await _faceRepository.deleteFace(userId);
    } catch (e) {
      return false;
    }
  }

  /// Lấy ảnh đã chụp gần nhất
  Uint8List? getLastCapturedImage() {
    return _lastCapturedImage;
  }

  /// Clear captured image để giải phóng memory
  void clearCapturedImage() {
    _lastCapturedImage = null;
  }

  /// Dispose service
  @override
  void dispose() {
    clearCapturedImage();
  }
}

/// Kết quả phân tích liveness
class LivenessResult {
  final bool isReal; // True nếu là khuôn mặt thật, false nếu là giả mạo

  const LivenessResult({required this.isReal});

  @override
  String toString() => 'LivenessResult(isReal: $isReal)';
}

/// Kết quả liveness với ảnh
class LivenessResultWithImage {
  final bool isReal;
  final Uint8List? imageBytes;

  const LivenessResultWithImage({
    required this.isReal,
    required this.imageBytes,
  });
}
