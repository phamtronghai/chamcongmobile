/// Lớp chứa các key dùng cho local storage
class StorageKeys {
  // Các key cho thông tin người dùng
  static const String authToken = 'auth_token';

  // Các key cho sinh trắc học
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
