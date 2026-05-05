import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';

class OrganizationUnit {
  final String name; // don_vi
  final String slug; // don_vi_slug
  final String url; // url

  OrganizationUnit({required this.name, required this.slug, required this.url});

  factory OrganizationUnit.fromJson(Map<String, dynamic> json) {
    return OrganizationUnit(
      name: json['don_vi'] as String? ?? '',
      slug: json['don_vi_slug'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class OrganizationService {
  static String _normalizeBaseUrl(String url) {
    if (url.isEmpty) return url;
    var normalized = url.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Chuẩn hóa URL để so sánh (chọn đơn vị = chọn base URL).
  static String normalizeBaseUrl(String url) => _normalizeBaseUrl(url);

  /// Áp dụng base URL giống [selectUnit] nhưng không cần [OrganizationUnit]
  /// (khi discovery không có đơn vị trùng URL mong muốn).
  static Future<void> applyBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeBaseUrl(url);

    AppConfig.setBaseUrl(normalized);

    await prefs.setString(AppConfig.selectedBaseUrlKey, normalized);

    final client = ApiClient();
    await client.setBaseUrl(normalized);
  }

  /// Lấy danh sách đơn vị từ discovery API
  static Future<List<OrganizationUnit>> fetchUnits({
    required String appSlug,
  }) async {
    try {
      // Tạo một request tạm thời tới discovery URL (không ảnh hưởng client hiện tại)
      final tempDio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: AppConfig.requestTimeout),
          receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
          headers: AppConfig.defaultHeaders,
        ),
      );

      final res = await tempDio.get(
        AppConfig.discoveryUnitsUrl,
        queryParameters: {'app_slug': appSlug},
      );

      final data = (res.data as List<dynamic>?) ?? <dynamic>[];
      return data.map((e) {
        final unit = OrganizationUnit.fromJson(e as Map<String, dynamic>);
        return OrganizationUnit(
          name: unit.name,
          slug: unit.slug,
          url: _normalizeBaseUrl(unit.url),
        );
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đơn vị: $e');
    }
  }

  /// Lưu base url được chọn và cập nhật ApiClient
  static Future<void> selectUnit(OrganizationUnit unit) async {
    await applyBaseUrl(unit.url);
  }

  /// Đọc base url đã chọn và áp dụng cho ApiClient (gọi sớm khi app khởi động)
  static Future<void> applySavedBaseUrlIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConfig.selectedBaseUrlKey);
    if (saved != null && saved.isNotEmpty) {
      final normalized = _normalizeBaseUrl(saved);

      // Cập nhật AppConfig trước
      AppConfig.setBaseUrl(normalized);

      // Cập nhật ApiClient
      final client = ApiClient();
      await client.setBaseUrl(normalized);
    }
  }
}
