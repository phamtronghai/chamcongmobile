import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

/// Helper class để tạo FormData
/// Loại bỏ code lặp lại khi upload files
class FormDataHelper {
  /// Tạo FormData cho face check (API mới: /face/check-face_1)
  static Future<FormData> createFaceCheckFormData({
    required File imageFile,
    required String lat,
    required String long,
    required String deviceID,
    String filename = 'face_image.jpg',
  }) async {
    return FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: filename),
      'lat': lat,
      'long': long,
      'deviceID': deviceID,
    });
  }

  /// Tạo FormData cho liveness check
  static Future<FormData> createLivenessCheckFormData({
    required File imageFile,
    String filename = 'face_image.png',
  }) async {
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
        contentType: MediaType('image', 'png'),
      ),
    });
  }

  /// Tạo FormData cho face registration
  static Future<FormData> createFaceRegistrationFormData({
    required List<File> images,
  }) async {
    final formData = FormData();

    // Thêm các file ảnh với cùng field name 'images' (như API mong đợi)
    for (int i = 0; i < images.length; i++) {
      formData.files.add(
        MapEntry(
          'images', // Field name phải là 'images' (số ít)
          await MultipartFile.fromFile(
            images[i].path,
            filename: 'face_image_${i + 1}.png',
            contentType: MediaType('image', 'png'),
          ),
        ),
      );
    }

    return formData;
  }

  // Đã loại bỏ các hàm generic single/multiple file upload không còn sử dụng

  /// Tạo FormData cho face register với multiple files cùng field name
  static Future<FormData> createFaceRegisterFormData({
    required List<File> images,
  }) async {
    if (images.length != 3) {
      throw Exception('Bạn phải chụp đủ 3 ảnh khuôn mặt để đăng ký.');
    }

    final formData = FormData();

    // Thêm các file ảnh với cùng field name 'images'
    for (int i = 0; i < images.length; i++) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            images[i].path,
            filename: 'face_image_${i + 1}.png',
            contentType: MediaType('image', 'png'),
          ),
        ),
      );
    }

    return formData;
  }
}
