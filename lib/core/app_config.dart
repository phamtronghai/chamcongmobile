/// Cấu hình chung cho ứng dụng
class AppConfig {
  /// Mật khẩu admin
  static const String adminPassword = String.fromEnvironment(
    'ADMIN_PWD',
    defaultValue: '',
  );

  /// Danh sách camera RTSP giám sát
  static const List<({String label, String url})> camerasRTSP = [
    (label: 'Camera 1', url: 'rtsp://samcom.com.vn:554/cam04'),
    (label: 'Camera 2', url: 'rtsp://samcom.com.vn:554/cam05'),
    (label: 'Camera 3', url: 'rtsp://samcom.com.vn:554/cam06'),
  ];

  /// Base URL mặc định cho API
  static const String defaultBaseUrl = 'https://auth.samcom.com.vn';

  /// Tài khoản dùng thử (đăng nhập nhanh); server gắn với [defaultBaseUrl].
  static const String trialLoginUsername = 'test';
  static const String trialLoginPassword = 'test12345';

  /// Base URL hiện tại đang sử dụng (có thể thay đổi động)
  static String _currentBaseUrl = defaultBaseUrl;

  /// Getter cho base URL hiện tại
  static String get apiBaseUrl => _currentBaseUrl;

  /// Thời gian timeout cho request (giây)
  static const int requestTimeout = 30;

  /// Đường dẫn lưu trữ cookie
  static const String cookiePath = '.cookies';

  /// Đường dẫn lưu trữ ảnh chấm công
  static const String attendanceImagesPath = 'attendance_images';

  /// Số ngày được phép chọn trước/sau ngày hiện tại cho nhập công việc
  static const int worklogDateRangeDays = 7;

  /// Cấu hình cho API
  static const Map<String, String> defaultHeaders = {
    'Accept': '*/*',
    'Content-Type': 'application/json',
    'Origin': 'https://auth.samcom.com.vn',
  };

  /// Key lưu base URL được chọn (SharedPreferences)
  static const String selectedBaseUrlKey = 'selected_api_base_url';

  /// Endpoint cho API auth
  static const String authEndpoint = '/api/auth';

  /// Endpoint cho API face
  static const String faceEndpoint = '/face';

  /// Full URL cho discovery danh sách đơn vị (cố định)
  static const String discoveryUnitsUrl =
      'https://baseurl.samcom.com.vn/api/don_vi';

  /// URL cho MapLibre style SAMCOM
  static const String mapLibreStyleUrl =
      'https://basemap.samcom.com.vn/static/samcomstyle.json';
  // MapTiler
  static const String apiKeyMapTiler = String.fromEnvironment(
    'MAPTILER_KEY',
    defaultValue: '',
  );
  static const String mapTilerOSM =
      'https://api.maptiler.com/maps/streets-v2/style.json?key=$apiKeyMapTiler';
  static const String mapTilerSatellite =
      'https://api.maptiler.com/maps/satellite/style.json?key=$apiKeyMapTiler';

  /// Cập nhật base URL hiện tại
  static void setBaseUrl(String newUrl) {
    _currentBaseUrl = newUrl;
  }

  /// Reset về base URL mặc định
  static void resetToDefault() {
    _currentBaseUrl = defaultBaseUrl;
  }

  /// Kiểm tra xem base URL có phải là mặc định không
  static bool get isUsingDefaultUrl => _currentBaseUrl == defaultBaseUrl;

  /// Lấy thông tin base URL hiện tại (để debug)
  static Map<String, String> get currentConfig => {
    'currentBaseUrl': _currentBaseUrl,
    'defaultBaseUrl': defaultBaseUrl,
    'isUsingDefault': isUsingDefaultUrl.toString(),
  };
}
