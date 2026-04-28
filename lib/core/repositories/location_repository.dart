import 'package:dio/dio.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/location_helper.dart';

/// Repository để xử lý API calls liên quan đến vị trí và địa chỉ
class LocationRepository {
  final ApiClient _apiClient = ApiClient();

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Lấy địa chỉ chi tiết từ lat/lng sử dụng API nội bộ Samcom
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    try {
      final response = await _apiClient.get(
        '/api/get_address',
        queryParameters: {'lat': lat, 'long': lng},
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/plain'},
        ),
      );

      if (response.statusCode == 200) {
        final address = LocationHelper.processAddressResponse(
          response.data,
          lat,
          lng,
        );
        return address;
      }

      return 'ngoài khu vực chấm công';
    } catch (e) {
      return 'Lỗi khi lấy địa chỉ';
    }
  }
}
