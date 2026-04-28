import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'interceptor.dart';
import 'origin_interceptor.dart';
import 'error_interceptor.dart';

/// ApiClient là class singleton để quản lý tất cả các request API
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  late PersistCookieJar _cookieJar;
  bool _isInitialized = false;
  String _currentBaseUrl = AppConfig.defaultBaseUrl;

  /// Singleton factory constructor
  factory ApiClient() => _instance;

  /// Private constructor
  ApiClient._internal();

  /// Khởi tạo ApiClient với các cấu hình cần thiết
  Future<void> init() async {
    if (_isInitialized) return;

    // Sync với AppConfig trước khi khởi tạo
    _currentBaseUrl = AppConfig.apiBaseUrl;

    // Khởi tạo Dio với các cấu hình cơ bản
    _dio = Dio(
      BaseOptions(
        baseUrl: _currentBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        headers: AppConfig.defaultHeaders,
      ),
    );

    // Khởi tạo và thêm cookie jar để lưu trữ cookie giữa các session
    final appDocDir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/${AppConfig.cookiePath}'),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Thêm các interceptor khác
    _dio.interceptors.add(OriginInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());

    _isInitialized = true;
  }

  /// Getter cho Dio instance
  Dio get dio {
    if (!_isInitialized) {
      throw Exception(
        'ApiClient chưa được khởi tạo. Hãy gọi init() trước khi sử dụng.',
      );
    }
    return _dio;
  }

  /// Đặt lại base URL động cho toàn bộ client
  Future<void> setBaseUrl(String baseUrl) async {
    if (!_isInitialized) {
      await init();
    }
    if (baseUrl.isEmpty || baseUrl == _currentBaseUrl) return;

    // Cập nhật internal state
    _currentBaseUrl = baseUrl;
    _dio.options.baseUrl = baseUrl;

    // Sync với AppConfig để đảm bảo consistency
    AppConfig.setBaseUrl(baseUrl);
  }

  /// Getter cho CookieJar
  PersistCookieJar get cookieJar {
    if (!_isInitialized) {
      throw Exception(
        'ApiClient chưa được khởi tạo. Hãy gọi init() trước khi sử dụng.',
      );
    }
    return _cookieJar;
  }

  /// Xóa tất cả cookie (dùng khi đăng xuất)
  Future<void> clearCookies() async {
    if (!_isInitialized) {
      throw Exception(
        'ApiClient chưa được khởi tạo. Hãy gọi init() trước khi sử dụng.',
      );
    }
    await _cookieJar.deleteAll();
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return request<T>(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Tải file lên với FormData
  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return request<T>(
      method: 'POST',
      path: path,
      data: formData,
      options: (options ?? Options(contentType: 'multipart/form-data')),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Generic request helper to deduplicate HTTP calls
  Future<Response<T>> request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final effectiveOptions = (options ?? Options()).copyWith(method: method);
    return _dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: effectiveOptions,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Lấy thông tin debug về base URL hiện tại
  Map<String, String> get debugInfo => {
    'currentBaseUrl': _currentBaseUrl,
    'appConfigBaseUrl': AppConfig.apiBaseUrl,
    'isInitialized': _isInitialized.toString(),
    'isUsingDefault': AppConfig.isUsingDefaultUrl.toString(),
  };
}
