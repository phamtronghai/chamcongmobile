import 'package:attendancebyface/models/user_model.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendancebyface/core/repositories/auth_repository.dart';
import 'package:attendancebyface/core/repositories/face_repository.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/storage/storage_keys.dart';
import 'package:attendancebyface/core/network/api_exception.dart';
import 'package:attendancebyface/core/services/notification_service.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();
  final FaceRepository _faceRepository = FaceRepository();

  AuthService() {
    _authRepository.init();
    _faceRepository.init();
  }

  /// Đăng nhập bằng username và password, sau đó lấy user info qua get-session
  Future<UserModel> signIn(String username, String password) async {
    // Cắt khoảng trắng ở đầu và cuối username và password
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    // 1. Đăng nhập
    await _authRepository.signIn(trimmedUsername, trimmedPassword);

    // 2. Lấy session user info
    final sessionResponse = await _authRepository.getSession();

    if (sessionResponse['user'] != null) {
      final user = UserModel.fromJson(sessionResponse['user']);
      return user;
    } else {
      throw Exception('Không lấy được thông tin người dùng từ session');
    }
  }

  /// Đăng nhập bằng sinh trắc học
  Future<UserModel> signInWithBiometrics(LocalAuthentication localAuth) async {
    // Kiểm tra lại hỗ trợ sinh trắc học
    final biometricSupported = await localAuth.isDeviceSupported();
    if (!biometricSupported) {
      throw Exception('Thiết bị không hỗ trợ sinh trắc học');
    }

    // Thực hiện xác thực sinh trắc học
    final didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Sử dụng sinh trắc học để đăng nhập',
    );

    if (!didAuthenticate) {
      throw Exception('Xác thực sinh trắc học thất bại');
    }

    // Lấy thông tin đăng nhập sinh trắc học đã lưu từ SecureStorage
    final username = await SecureStorage.getString(
      StorageKeys.biometricUsername,
    );
    final password = await SecureStorage.getString(
      StorageKeys.biometricPassword,
    );

    if (username == null ||
        password == null ||
        username.isEmpty ||
        password.isEmpty) {
      throw Exception('Không tìm thấy thông tin đăng nhập sinh trắc học');
    }

    // Đăng nhập bình thường thông qua API
    return await login(username, password);
  }

  /// Đăng xuất
  Future<bool> signOut() async {
    try {
      final success = await _authRepository.signOut();
      return success;
    } catch (e) {
      // Ignore error
    }
    return true;
  }

  // Đăng nhập
  Future<UserModel> login(String username, String password) async {
    try {
      // Cắt khoảng trắng ở đầu và cuối username và password
      final trimmedUsername = username.trim();
      final trimmedPassword = password.trim();

      // 1. Gọi API đăng nhập
      await _authRepository.signIn(trimmedUsername, trimmedPassword);

      // 2. Gọi API get-session để lấy thông tin user
      final sessionResponse = await _authRepository.getSession();

      if (sessionResponse['user'] == null) {
        throw const ApiException(
          message: 'Không lấy được thông tin người dùng từ session',
          kind: ApiErrorKind.auth,
        );
      }

      // Lấy thông tin user từ session
      final userData = sessionResponse['user'];
      final user = UserModel.fromJson(userData);

      // Lấy token từ session nếu có
      String? token;
      if (sessionResponse['session'] != null &&
          sessionResponse['session']['token'] != null) {
        token = sessionResponse['session']['token'];
      }

      // Chỉ lưu token vào secure storage
      if (token != null) {
        await SecureStorage.saveAuthToken(token);
      }

      // Lưu ý: Đồng bộ FCM token với Firestore được thực hiện trong NotificationService.

      return user;
    } catch (e) {
      throw ApiException(message: '$e', kind: ApiErrorKind.auth);
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      // 1. Gọi API đăng xuất
      await _authRepository.signOut();
    } catch (e) {
      // Ignore error
    } finally {
      // 2. Hủy đăng ký FCM token
      await NotificationService.instance.unregisterFcmToken();

      // 3. Xóa token khỏi secure storage
      await SecureStorage.removeAuthToken();
      // KHÔNG xóa thông tin sinh trắc học để giữ lại khả năng đăng nhập bằng sinh trắc học
    }
  }

  // Kiểm tra trạng thái đăng nhập (chỉ dựa vào token)
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Kiểm tra token có hợp lệ không (không hết hạn)
  Future<bool> isTokenValid() async {
    try {
      final user = await loginWithToken();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Tự động đăng nhập chỉ bằng token (không dùng credentials)
  Future<UserModel?> autoLogin() async {
    try {
      // Chỉ thử đăng nhập bằng token
      final userFromToken = await loginWithToken();
      if (userFromToken != null) {
        return userFromToken;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    try {
      final sessionResponse = await _authRepository.getSession();

      if (sessionResponse['user'] != null) {
        return UserModel.fromJson(sessionResponse['user']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Đăng nhập chỉ bằng Auth Token
  /// Trả về UserModel nếu token hợp lệ, null nếu token hết hạn
  Future<UserModel?> loginWithToken() async {
    try {
      // Kiểm tra xem có token không
      final token = await SecureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      // Gọi API get-session để validate token
      final sessionResponse = await _authRepository.getSession();

      if (sessionResponse['user'] != null) {
        final user = UserModel.fromJson(sessionResponse['user']);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required bool revokeOtherSessions,
  }) async {
    try {
      final response = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        revokeOtherSessions: revokeOtherSessions,
      );
      return response;
    } catch (e) {
      throw ApiException(message: '$e', kind: ApiErrorKind.auth);
    }
  }
}
