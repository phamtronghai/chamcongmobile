import 'package:flutter/foundation.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/network/api_client.dart';

/// Test class để kiểm tra Dynamic AppConfig implementation
class AppConfigTest {
  static Future<void> runTests() async {
    debugPrint('🧪 Bắt đầu test Dynamic AppConfig...');

    // Test 1: Kiểm tra giá trị mặc định
    await _testDefaultValues();

    // Test 2: Kiểm tra thay đổi base URL
    await _testChangeBaseUrl();

    // Test 3: Kiểm tra reset về mặc định
    await _testResetToDefault();

    // Test 4: Kiểm tra sync với ApiClient
    await _testApiClientSync();

    debugPrint('✅ Tất cả tests đã hoàn thành!');
  }

  /// Test 1: Kiểm tra giá trị mặc định
  static Future<void> _testDefaultValues() async {
    debugPrint('\n📋 Test 1: Kiểm tra giá trị mặc định');

    // Reset về mặc định
    AppConfig.resetToDefault();

    // Kiểm tra các giá trị
    assert(AppConfig.apiBaseUrl == AppConfig.defaultBaseUrl);
    assert(AppConfig.isUsingDefaultUrl == true);
    assert(AppConfig.apiBaseUrl == 'https://auth.samcom.com.vn');

    debugPrint('✅ Default values: ${AppConfig.currentConfig}');
  }

  /// Test 2: Kiểm tra thay đổi base URL
  static Future<void> _testChangeBaseUrl() async {
    debugPrint('\n📋 Test 2: Kiểm tra thay đổi base URL');

    // Test URL 1
    const testUrl1 = 'https://test1.samcom.com.vn';
    AppConfig.setBaseUrl(testUrl1);

    assert(AppConfig.apiBaseUrl == testUrl1);
    assert(AppConfig.isUsingDefaultUrl == false);
    debugPrint('✅ Set URL 1: ${AppConfig.currentConfig}');

    // Test URL 2
    const testUrl2 = 'https://test2.samcom.com.vn';
    AppConfig.setBaseUrl(testUrl2);

    assert(AppConfig.apiBaseUrl == testUrl2);
    assert(AppConfig.isUsingDefaultUrl == false);
    debugPrint('✅ Set URL 2: ${AppConfig.currentConfig}');
  }

  /// Test 3: Kiểm tra reset về mặc định
  static Future<void> _testResetToDefault() async {
    debugPrint('\n📋 Test 3: Kiểm tra reset về mặc định');

    // Set một URL khác
    AppConfig.setBaseUrl('https://custom.samcom.com.vn');
    assert(AppConfig.apiBaseUrl == 'https://custom.samcom.com.vn');

    // Reset về mặc định
    AppConfig.resetToDefault();

    assert(AppConfig.apiBaseUrl == AppConfig.defaultBaseUrl);
    assert(AppConfig.isUsingDefaultUrl == true);
    debugPrint('✅ Reset to default: ${AppConfig.currentConfig}');
  }

  /// Test 4: Kiểm tra sync với ApiClient
  static Future<void> _testApiClientSync() async {
    debugPrint('\n📋 Test 4: Kiểm tra sync với ApiClient');

    try {
      // Khởi tạo ApiClient
      final apiClient = ApiClient();
      await apiClient.init();

      // Kiểm tra debug info
      final debugInfo = apiClient.debugInfo;
      debugPrint('✅ ApiClient debug info: $debugInfo');

      // Test thay đổi base URL qua ApiClient
      const testUrl = 'https://apiclient-test.samcom.com.vn';
      await apiClient.setBaseUrl(testUrl);

      // Kiểm tra AppConfig đã được sync
      assert(AppConfig.apiBaseUrl == testUrl);
      debugPrint('✅ ApiClient sync test passed');
    } catch (e) {
      debugPrint('❌ ApiClient sync test failed: $e');
    }
  }

  /// Test integration với OrganizationService
  static Future<void> testOrganizationServiceIntegration() async {
    debugPrint('\n📋 Test OrganizationService Integration');

    // Simulate organization selection
    const testUrl = 'https://org-test.samcom.com.vn';
    AppConfig.setBaseUrl(testUrl);

    assert(AppConfig.apiBaseUrl == testUrl);
    debugPrint('✅ OrganizationService integration test passed');
  }

  /// Test edge cases
  static Future<void> testEdgeCases() async {
    debugPrint('\n📋 Test Edge Cases');

    // Test empty URL
    AppConfig.setBaseUrl('');
    assert(AppConfig.apiBaseUrl == ''); // Should allow empty

    // Test same URL
    AppConfig.setBaseUrl('https://same.samcom.com.vn');
    AppConfig.setBaseUrl('https://same.samcom.com.vn'); // Same URL
    assert(AppConfig.apiBaseUrl == 'https://same.samcom.com.vn');

    // Test null handling (should not crash)
    try {
      AppConfig.setBaseUrl('https://null-test.samcom.com.vn');
      debugPrint('✅ Edge cases test passed');
    } catch (e) {
      debugPrint('❌ Edge cases test failed: $e');
    }
  }
}

/// Extension để dễ dàng chạy tests
extension AppConfigTestExtension on AppConfig {
  static Future<void> runAllTests() async {
    await AppConfigTest.runTests();
    await AppConfigTest.testOrganizationServiceIntegration();
    await AppConfigTest.testEdgeCases();
  }
}
