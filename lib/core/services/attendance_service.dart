import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:attendancebyface/core/utils/file_utils.dart';
import 'face_service.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';
import 'package:attendancebyface/core/utils/device_id_helper.dart';
import 'package:attendancebyface/core/utils/device_security_helper.dart';
import 'base_service.dart';

class AttendanceService extends BaseService {
  final FaceService _faceService = FaceService();
  final LocationRepository _locationRepository = LocationRepository();

  // Không sử dụng cache GPS để đảm bảo bảo mật chấm công

  /// Khởi tạo service
  @override
  Future<void> init() async {
    await _faceService.init();
    await _locationRepository.init();
  }

  /// Kiểm tra và lấy vị trí hiện tại với xử lý lỗi và retry logic
  /// Luôn lấy vị trí mới để đảm bảo bảo mật chấm công
  Future<Position?> getCurrentLocation(BuildContext context) async {
    // Kiểm tra dịch vụ vị trí
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (context.mounted) {
        _showError(context, 'Vui lòng bật dịch vụ vị trí');
      }
      return null;
    }

    // Kiểm tra và yêu cầu quyền
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!context.mounted) return null;
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showError(context, 'Quyền truy cập vị trí bị từ chối');
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showError(context, 'Vui lòng cấp quyền vị trí trong cài đặt app');
      }
      return null;
    }

    // Retry logic
    for (int attempt = 1; attempt <= 3; attempt++) {
    try {
        final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
            distanceFilter: 1, // Chỉ cập nhật khi di chuyển 1m
        ),
      );
        return position;
    } catch (e) {
        if (attempt == 3) {
      if (context.mounted) {
        _showError(context, 'Lỗi lấy vị trí: ${e.toString()}');
      }
      return null;
    }
        // Đợi trước khi thử lại
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    return null;
  }

  /// Hiển thị thông báo lỗi
  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.error,
      );
    }
  }

  /// Lưu ảnh vào thư mục ứng dụng
  Future<File> _saveImagePermanently(Uint8List imageBytes) async {
    return await FileUtils.saveImageToAppDirectory(
      imageBytes,
      customFileName:
          'face_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  /// Kiểm tra liveness và khuôn mặt - phương thức chính (Tối ưu: lấy GPS sau khi kiểm tra liveness)
  /// overrideLat/overrideLng: nếu có, bỏ qua bước lấy vị trí và dùng tọa độ này
  Future<Map<String, dynamic>> checkFaceLiveness(
    BuildContext context,
    String userId, {
    double? overrideLat,
    double? overrideLng,
  }) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'message': '',
      'capturedImage': null,
      'locationMessage': null,
    };

    try {
      // 1. Chụp ảnh, lưu tạm thời và kiểm tra liveness (CHỈ CHỤP 1 LẦN)
      final livenessResult = await _faceService.detectLivenessWithCamera(
        context,
      );
      if (!context.mounted) return result;

      if (!livenessResult.isReal || livenessResult.imageBytes == null) {
        result['message'] = 'Lỗi sinh trắc học';
        return result;
      }

      // 2. Lấy vị trí sau khi kiểm tra liveness thành công (hoặc dùng tọa độ override nếu cung cấp)
      double? currentLat = overrideLat;
      double? currentLng = overrideLng;

      // 2.a. Kiểm tra Mock Location trước khi lấy tọa độ thật
      // Giới hạn Android đã được xử lý bên trong Helper
      final mockCheckDetails = await DeviceSecurityHelper.checkMockLocation();
      if (!context.mounted) return result;

      final isFakeGps = mockCheckDetails['isMockLocation'] == true;
      if (isFakeGps) {
        result['message'] = 'Phát hiện ứng dụng giả vị trí. Vui lòng tắt và thử lại.';
        _faceService.clearCapturedImage();
        return result;
      }

      if (currentLat == null || currentLng == null) {
        final position = await getCurrentLocation(context);
        if (!context.mounted) return result;
        if (position == null) {
          result['message'] = 'Không thể lấy thông tin vị trí';
          return result;
        }
        currentLat = position.latitude;
        currentLng = position.longitude;
      }

      // 3. Lưu ảnh đã chụp (tái sử dụng ảnh đã lưu tạm từ liveness check)
      final permanentImage = await _saveImagePermanently(
        livenessResult.imageBytes!,
      );
      result['capturedImage'] = permanentImage;

      // 4. Lấy device identifier (UUID) - bắt buộc cho API mới
      final deviceID = await DeviceIdHelper.getDeviceId();

      // 5. Kiểm tra khuôn mặt với API mới (sử dụng ảnh đã lưu)
      final checkResult = await _faceService.checkFace(
        imageFile: permanentImage,
        lat: currentLat.toString(),
        longValue: currentLng.toString(),
        deviceID: deviceID,
      );
      if (!context.mounted) return result;

      // 6. Xử lý kết quả
      final isSuccess = checkResult['success'] == true;
      final message = checkResult['message'] as String? ?? 'Không có thông báo';

      result['isSuccess'] = isSuccess;
      result['message'] = message;

      if (isSuccess && context.mounted) {
        // Lấy địa chỉ chi tiết
        result['locationMessage'] = await _locationRepository
            .getAddressFromLatLng(currentLat, currentLng);
      } else if (!isSuccess && context.mounted) {
        _showError(context, message);
      }

      // 7. Cleanup: giải phóng memory
      _faceService.clearCapturedImage();
    } catch (e) {
      if (e is DioException) {
        final errorResponse = ResponseParser.parseDioException(e);
        result['message'] =
            errorResponse['message'] ?? 'Lỗi kết nối hoặc server';
      } else {
      result['message'] = 'Lỗi chấm công: ${e.toString()}';
      }
    }

    return result;
  }
}
