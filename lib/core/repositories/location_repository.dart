import 'package:dio/dio.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/location_helper.dart';

/// Repository để xử lý API calls liên quan đến vị trí và địa chỉ
class LocationRepository {
  final ApiClient _apiClient = ApiClient();
  static final Map<String, String> _addressCache = {};

  static String _cacheKey(double lat, double lng) =>
      '${lat.toStringAsFixed(5)},${lng.toStringAsFixed(5)}';

  /// Khởi tạo repository
  Future<void> init() async {
    await _apiClient.init();
  }

  /// Lấy địa chỉ chi tiết từ lat/lng sử dụng API nội bộ Samcom
  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final key = _cacheKey(lat, lng);
    final cached = _addressCache[key];
    if (cached != null) return cached;

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
        if (address.trim().isNotEmpty) {
          _addressCache[key] = address;
        }
        return address;
      }

      return 'ngoài khu vực chấm công';
    } catch (e) {
      return 'Lỗi khi lấy địa chỉ';
    }
  }
}
