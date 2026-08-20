import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/storage/storage_keys.dart';

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

  static String normalizeBaseUrl(String url) => _normalizeBaseUrl(url);

  static Future<void> applyBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeBaseUrl(url);

    AppConfig.setBaseUrl(normalized);
    await prefs.setString(StorageKeys.lastLoginBaseUrl, normalized);

    final client = ApiClient();
    await client.setBaseUrl(normalized);
  }

  static Future<List<OrganizationUnit>> fetchUnits({
    required String appSlug,
  }) async {
    try {
      final tempDio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: AppConfig.requestTimeout),
          receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
          headers: AppConfig.apiDefaultHeaders,
        ),
      );

      final res = await tempDio.get(
        '${AppConfig.discoveryUnitsBaseUrl}/api/don_vi',
        queryParameters: {'app_slug': appSlug},
      );

      final data = (res.data as List<dynamic>?) ?? <dynamic>[];
      return data.map((e) {
        final unit = OrganizationUnit.fromJson(e as Map<String, dynamic>);
        return OrganizationUnit(
          name: unit.name.trim(),
          slug: unit.slug,
          url: _normalizeBaseUrl(unit.url),
        );
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách đơn vị: $e');
    }
  }

  static Future<void> selectUnit(OrganizationUnit unit) async {
    await applyBaseUrl(unit.url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.lastLoginUnitSlug, unit.slug);
    await prefs.setString(StorageKeys.lastLoginUnitName, unit.name);
  }

  static Future<void> applySavedBaseUrlIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.lastLoginBaseUrl);
    if (saved != null && saved.isNotEmpty) {
      final normalized = _normalizeBaseUrl(saved);
      AppConfig.setBaseUrl(normalized);
      final client = ApiClient();
      await client.setBaseUrl(normalized);
    }
  }

  static OrganizationUnit? findUnitByBaseUrl(
    List<OrganizationUnit> units,
    String baseUrl,
  ) {
    final target = normalizeBaseUrl(baseUrl);
    for (final unit in units) {
      if (normalizeBaseUrl(unit.url) == target) return unit;
    }
    return null;
  }

  static OrganizationUnit? findUnitBySlug(
    List<OrganizationUnit> units,
    String slug,
  ) {
    if (slug.isEmpty) return null;
    for (final unit in units) {
      if (unit.slug == slug) return unit;
    }
    return null;
  }
}
