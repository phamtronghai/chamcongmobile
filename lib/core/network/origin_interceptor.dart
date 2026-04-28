import 'package:dio/dio.dart';
import 'package:attendancebyface/core/app_config.dart';

/// Interceptor để tự động thêm Origin header
class OriginInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Thêm Origin header nếu chưa có
    if (!options.headers.containsKey('Origin')) {
      options.headers['Origin'] = AppConfig.apiBaseUrl;
    }

    // Thêm User-Agent header để tránh một số vấn đề CORS
    if (!options.headers.containsKey('User-Agent')) {
      options.headers['User-Agent'] = 'SamcomAttendanceApp/1.0.0';
    }

    super.onRequest(options, handler);
  }
}
