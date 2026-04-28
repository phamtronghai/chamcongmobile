import 'dart:convert';
import 'package:attendancebyface/core/network/api_client.dart';

/// Repository để xử lý API calls liên quan đến căn cước công dân
class CitizenRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Kiểm tra xem user đã đăng ký thông tin căn cước chưa
  /// Mặc định trả về false
  /// Chỉ trả về true nếu status code = 200
  /// Không quan tâm API có tồn tại hay không, hoặc trả về status khác
  Future<bool> checkCitizenRegistration() async {
    try {
      final response = await _apiClient.post('/check_dk_cancuoc');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Mặc định trả về false, không throw exception
      return false;
    }
  }

  /// Lấy thông tin căn cước chi tiết từ API check_dk_cancuoc
  /// Trả về Map chuẩn hóa từ field 'add' trong response
  Future<Map<String, dynamic>?> fetchCitizenInfo() async {
    try {
      final response = await _apiClient.post('/check_dk_cancuoc');

      if (response.statusCode != 200) return null;

      final data = response.data;
      Map<String, dynamic>? json;
      if (data is Map<String, dynamic>) {
        json = data;
      } else if (data is String) {
        try {
          json = jsonDecode(data) as Map<String, dynamic>;
        } catch (_) {
          return null;
        }
      }
      if (json == null) return null;
      final add = json['add'];
      if (add is Map<String, dynamic>) return add;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Thêm thông tin căn cước công dân
  Future<Map<String, dynamic>> addCitizenInfo({
    required String citizenNumber,
    required String oldIdNumber,
    required String fullName,
    required String dateOfBirth,
    required String gender,
    required String address,
    required String issuedDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/add_cancuoc',
        data: {
          'citizenNumber': citizenNumber,
          'oldIdNumber': oldIdNumber,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'address': address,
          'issuedDate': issuedDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('API trả về status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật thông tin căn cước công dân
  Future<Map<String, dynamic>> updateCitizenInfo({
    required String citizenNumber,
    required String oldIdNumber,
    required String fullName,
    required String dateOfBirth,
    required String gender,
    required String address,
    required String issuedDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/update_cancuoc',
        data: {
          'citizenNumber': citizenNumber,
          'oldIdNumber': oldIdNumber,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'gender': gender,
          'address': address,
          'issuedDate': issuedDate,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('API trả về status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
