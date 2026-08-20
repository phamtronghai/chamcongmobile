/// Lớp chứa các key dùng cho local storage
class StorageKeys {
  // Các key cho thông tin người dùng
  static const String authToken = 'auth_token';

  // Phiên đăng nhập gần nhất (SharedPreferences — không lưu mật khẩu)
  static const String lastLoginUsername = 'last_login_username';
  static const String lastLoginBaseUrl = 'last_login_base_url';
  static const String lastLoginUnitSlug = 'last_login_unit_slug';
  static const String lastLoginUnitName = 'last_login_unit_name';

  // Danh sách tài khoản đã lưu (metadata, không có password)
  static const String savedLoginAccounts = 'saved_login_accounts';
  static const String savedLoginLastAccountId = 'saved_login_last_account_id';

  /// Mật khẩu theo account id — chỉ trong secure storage
  static String loginPasswordKey(String accountId) =>
      'login_password_$accountId';

  /// Mật khẩu phiên gần nhất
  static const String lastLoginPassword = 'last_login_password';

  // Các key cho sinh trắc học (legacy migration)
  static const String biometricUsername = 'biometric_username';
  static const String biometricPassword = 'biometric_password';
  static const String biometricBaseUrl = 'biometric_base_url';
  static const String biometricOrganizationName = 'biometric_organization_name';
  static const String biometricUserName = 'biometric_user_name';
  static const String biometricUserAvatar = 'biometric_user_avatar';
  
  // Key cho danh sách tài khoản sinh trắc học (format mới)
  static const String biometricAccounts = 'biometric_accounts';
  static const String biometricLastSelectedAccountId = 'biometric_last_selected_account_id';

  // Các key cho cài đặt ứng dụng
  static const String darkMode = 'dark_mode';
  static const String language = 'language';
  static const String biometricEnabled = 'biometric_enabled';
  static const String notificationsEnabled = 'notifications_enabled';

  // // Các key cho đăng ký khuôn mặt
  static const String faceRegistered = 'face_registered';
}
