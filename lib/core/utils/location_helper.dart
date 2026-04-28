/// Helper class để xử lý location utilities
/// Loại bỏ code lặp lại trong location processing
class LocationHelper {
  /// Tạo fallback address từ tọa độ
  static String createFallbackAddress(double lat, double lng) {
    return '$lat, $lng';
  }

  /// Xử lý response từ API get_address
  static String processAddressResponse(
    dynamic responseData,
    double lat,
    double lng,
  ) {
    if (responseData is String) {
      final address = responseData.trim();
      if (address.isNotEmpty) {
        return address;
      }
    }
    return createFallbackAddress(lat, lng);
  }
}
