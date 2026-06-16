import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendancebyface/core/cubits/login_state.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/storage/storage_keys.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/biometric_helper.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/service_locator.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = locator<AuthService>();
  final LocalAuthentication _localAuth = LocalAuthentication();

  LoginCubit() : super(const LoginState());

  void toggleAlternativeLogin(bool show) {
    emit(state.copyWith(showAlternativeLogin: show));
  }

  void toggleRememberAccount(bool remember) {
    emit(state.copyWith(rememberAccount: remember));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void selectUnit(OrganizationUnit unit) {
    emit(state.copyWith(selectedUnit: unit));
    OrganizationService.selectUnit(unit);
  }

  /// Khi chỉ đổi base URL (không có đơn vị khớp trong discovery), bỏ chọn dropdown.
  void clearSelectedUnit() {
    emit(state.copyWith(selectedUnit: null));
  }

  void selectBiometricAccount(BiometricAccount account) {
    emit(state.copyWith(selectedBiometricAccount: account));
    SecureStorage.setLastSelectedAccountId(account.id);
  }

  Future<void> init(BuildContext context) async {
    // Áp dụng base URL đã chọn trước đó
    OrganizationService.applySavedBaseUrlIfAny();
    
    // Khởi tạo các tác vụ song song (hoặc tuần tự nếu cần an toàn)
    await SecureStorage.migrateOldBiometricData();
    await _loadBiometricAccounts();
    await loadUnits();
    if (!context.mounted) return;
    await _checkAutoLogin();
  }

  Future<void> loadUnits() async {
    try {
      final units = await OrganizationService.fetchUnits(appSlug: 'cham-cong');
      emit(state.copyWith(units: units, selectedUnit: null));
    } catch (e) {
      debugPrint('Không thể tải danh sách đơn vị: $e');
    }
  }

  Future<void> _loadBiometricAccounts() async {
    try {
      final accounts = await SecureStorage.getBiometricAccounts();
      final lastSelected = await SecureStorage.getLastSelectedAccount();

      emit(state.copyWith(
        biometricAccounts: accounts,
        selectedBiometricAccount: lastSelected,
      ));
    } catch (e) {
      debugPrint('Lỗi khi load danh sách tài khoản sinh trắc học: $e');
    }
  }

  Future<void> _checkAutoLogin() async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      // Lấy tài khoản được chọn gần nhất
      final lastSelectedAccount = await SecureStorage.getLastSelectedAccount();

      // Nếu có tài khoản được chọn, áp dụng base URL trước khi auto login
      if (lastSelectedAccount != null && lastSelectedAccount.baseUrl.isNotEmpty) {
        AppConfig.setBaseUrl(lastSelectedAccount.baseUrl);
        final apiClient = ApiClient();
        await apiClient.setBaseUrl(lastSelectedAccount.baseUrl);
      }

      final user = await _authService.autoLogin();

      if (user != null) {
        emit(state.copyWith(
          status: LoginStatus.success,
          user: user,
          showSuccessMessage: false,
        ));
        return;
      }
    } catch (e) {
      debugPrint('Lỗi khi tự động đăng nhập: $e');
    }

    emit(state.copyWith(status: LoginStatus.initial));
    await _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final biometricType = await BiometricHelper.getPrimaryBiometricType();
      final supportsBiometric = biometricType != null;

      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool(StorageKeys.biometricEnabled) ?? false;

      emit(state.copyWith(
        biometricEnabled: biometricEnabled && supportsBiometric && state.biometricAccounts.isNotEmpty,
      ));
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra hỗ trợ sinh trắc học: $e');
    }
  }

  Future<void> deleteBiometricAccount(BiometricAccount account) async {
    try {
      await SecureStorage.removeBiometricAccount(account.id);
      await _loadBiometricAccounts();

      if (state.biometricAccounts.isEmpty) {
        emit(state.copyWith(biometricEnabled: false));
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa tài khoản: $e');
    }
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Vui lòng nhập tên đăng nhập và mật khẩu',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final user = await _authService.login(username, password);
      await _handleLoginSuccess(user, username, password);
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: null, // ErrorInterceptor sẽ show lỗi từ server
      ));
    }
  }

  Future<void> authenticateWithBiometric([BiometricAccount? account]) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final selectedAccount = account ?? state.selectedBiometricAccount;

      if (selectedAccount == null) {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Không tìm thấy tài khoản'));
        return;
      }

      final biometricType = await BiometricHelper.getPrimaryBiometricType();
      final displayName = biometricType != null
          ? BiometricHelper.getBiometricInfo(biometricType)['name'] as String
          : 'sinh trắc học';

      final String authReason = 'Sử dụng $displayName để đăng nhập';
      final bool didAuthenticate = await _localAuth.authenticate(localizedReason: authReason);

      if (!didAuthenticate) {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Lỗi sinh trắc học'));
        return;
      }

      if (selectedAccount.baseUrl.isNotEmpty) {
        AppConfig.setBaseUrl(selectedAccount.baseUrl);
        final apiClient = ApiClient();
        await apiClient.setBaseUrl(selectedAccount.baseUrl);
      }

      final user = await _authService.login(selectedAccount.username, selectedAccount.password);

      final updatedAccount = selectedAccount.markAsUsed();
      await SecureStorage.addBiometricAccount(updatedAccount);
      await SecureStorage.setLastSelectedAccountId(updatedAccount.id);
      await _loadBiometricAccounts();

      emit(state.copyWith(status: LoginStatus.success, user: user, showSuccessMessage: false));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: null, // Đã được xử lý bởi ErrorInterceptor
      ));
    }
  }

  Future<void> _handleLoginSuccess(UserModel user, String username, String password) async {
    try {
      await NotificationService.instance.requestPermissionAndSyncToken(userId: user.id);
    } catch (e) {
      debugPrint('Không thể đồng bộ FCM token sau đăng nhập: $e');
    }

    try {
      final biometricType = await BiometricHelper.getPrimaryBiometricType();
      final supportsBiometric = biometricType != null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.biometricEnabled, supportsBiometric);

      if (state.rememberAccount) {
        final baseUrl = state.selectedUnit?.url ?? AppConfig.defaultBaseUrl;
        final organizationName = state.selectedUnit?.name ?? 'Đơn vị mặc định';

        final newAccount = BiometricAccount(
          id: BiometricAccount.generateId(),
          username: username,
          password: password,
          name: user.name,
          avatar: user.image,
          baseUrl: baseUrl,
          organizationName: organizationName,
          createdAt: DateTime.now(),
          lastUsedAt: DateTime.now(),
        );

        await SecureStorage.addBiometricAccount(newAccount);
        await SecureStorage.setLastSelectedAccountId(newAccount.id);
        await _loadBiometricAccounts();
      }
    } catch (e) {
      debugPrint('Không thể bật sinh trắc học tự động: $e');
    }

    emit(state.copyWith(status: LoginStatus.success, user: user, showSuccessMessage: true));
  }
}
