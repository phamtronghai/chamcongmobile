import 'dart:io';
import 'package:dio/dio.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';
import 'package:attendancebyface/core/utils/form_data_helper.dart';

/// Repository để xử lý tất cả API calls liên quan đến face recognition
class FaceRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Kiểm tra khuôn mặt với API (API mới: /face/check-face_1)
  Future<Map<String, dynamic>> checkFace({
    required File imageFile,
    required String lat,
    required String longValue,
    required String deviceID,
  }) async {
    try {
      // Tạo FormData sử dụng helper
      final formData = await FormDataHelper.createFaceCheckFormData(
        imageFile: imageFile,
        lat: lat,
        long: longValue,
        deviceID: deviceID,
        filename: 'face_image.png',
      );

      // Gửi request đến API mới
      final response = await _apiClient.uploadFile(
        '${AppConfig.faceEndpoint}/check-face_1',
        formData: formData,
      );

      // Parse response sử dụng helper
      return ResponseParser.parseFaceCheckResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng ký khuôn mặt
  Future<Map<String, dynamic>> registerFace({
    required List<File> images,
  }) async {
    try {
      // Tạo FormData sử dụng helper
      final formData = await FormDataHelper.createFaceRegisterFormData(
        images: images,
      );

      // Gửi request
      final response = await _apiClient.uploadFile(
        '${AppConfig.faceEndpoint}/register-faceid',
        formData: formData,
      );

      // Parse response sử dụng helper
      return ResponseParser.parseFaceRegistrationResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Kiểm tra liveness từ ảnh
  Future<Map<String, dynamic>> checkLiveness(File imageFile) async {
    try {
      // Tạo FormData sử dụng helper
      final formData = await FormDataHelper.createLivenessCheckFormData(
        imageFile: imageFile,
        filename: 'face_image.png',
      );

      // Gửi request
      final response = await _apiClient.uploadFile(
        '${AppConfig.faceEndpoint}/liveness-check',
        formData: formData,
      );

      // Parse response sử dụng helper
      return ResponseParser.parseLivenessResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Kiểm tra xem người dùng đã đăng ký khuôn mặt chưa
  Future<bool> checkRegistered(String userId) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.faceEndpoint}/check-registered',
        queryParameters: {'user_id': userId},
      );

      return ResponseParser.parseCheckRegisteredResponse(response);
    } catch (e) {
      // Xử lý trường hợp API trả về status code khác 200 nhưng vẫn có dữ liệu hợp lệ
      if (e is DioException) {
        // Sử dụng helper để parse error response
        final result = ResponseParser.parseCheckRegisteredFromError(e);
        if (result) {
          return true;
        }
      }

      return false;
    }
  }

  /// Xóa khuôn mặt đã đăng ký
  Future<bool> deleteFace(String userId) async {
    try {
      final response = await _apiClient.delete(
        '${AppConfig.faceEndpoint}/delete-faceid',
        queryParameters: {'user_id': userId},
      );

      return ResponseParser.parseDeleteFaceResponse(response);
    } catch (e) {
      // Xử lý trường hợp API trả về status code khác 200 nhưng vẫn có dữ liệu hợp lệ
      if (e is DioException) {
        // Sử dụng helper để parse error response
        final result = ResponseParser.parseDeleteFaceFromError(e);
        if (result) {
          return true;
        }
      }

      return false;
    }
  }
}
