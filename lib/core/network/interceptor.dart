import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor để log các request và response
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final fullUrl = '${options.baseUrl}${options.path}';
      debugPrint('🚀 REQUEST[${options.method}] => URL: $fullUrl');

      if (options.queryParameters.isNotEmpty) {
        debugPrint('📋 Query Parameters: ${options.queryParameters}');
      }

      if (options.data != null) {
        if (options.data is FormData) {
          final formData = options.data as FormData;
          debugPrint('📤 Request Data (FormData):');
          debugPrint('  Fields: ${formData.fields}');
          if (formData.files.isNotEmpty) {
            debugPrint(
              '  Files: ${formData.files.map((f) => '${f.key}: ${f.value.filename}').toList()}',
            );
          }
        } else if (options.data is Map) {
          debugPrint('📤 Request Data (Map): ${options.data}');
        } else if (options.data is String) {
          debugPrint('📤 Request Data (String): ${options.data}');
        } else {
          debugPrint('📤 Request Data: ${options.data}');
        }
      }

      if (options.headers.containsKey('Authorization')) {
        debugPrint('🔐 Authorization: Bearer ***');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ RESPONSE STATUS CODE: ${response.statusCode}');
      if (response.requestOptions.queryParameters.isNotEmpty) {
        debugPrint(
          '📋 Query Parameters: ${response.requestOptions.queryParameters}',
        );
      }
      if (response.data != null) {
        debugPrint('📥 Response Data: ${response.data}');
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final fullUrl = '${err.requestOptions.baseUrl}${err.requestOptions.path}';
      debugPrint('❌ ERROR[${err.response?.statusCode}] => URL: $fullUrl');
      if (err.requestOptions.queryParameters.isNotEmpty) {
        debugPrint(
          '📋 Query Parameters: ${err.requestOptions.queryParameters}',
        );
      }
      if (err.message != null) {
        debugPrint('💥 Error Message: ${err.message}');
      }
      if (err.response != null && err.response!.data != null) {
        debugPrint('📥 Error Response: ${err.response!.data}');
      }
    }
    super.onError(err, handler);
  }
}
