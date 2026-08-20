import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendancebyface/core/cubits/login_state.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/storage/storage_keys.dart';
import 'package:attendancebyface/core/storage/login_account_storage.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/utils/biometric_helper.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/service_locator.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService = locator<AuthService>();

  LoginCubit() : super(const LoginState());

  void toggleRememberAccount(bool remember) {
    emit(state.copyWith(rememberAccount: remember));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> selectUnit(OrganizationUnit unit) async {
    emit(state.copyWith(selectedUnit: unit));
    await OrganizationService.selectUnit(unit);
  }

  Future<void> selectSavedAccount(BiometricAccount account) async {
    emit(state.copyWith(selectedBiometricAccount: account));
    await LoginAccountStorage.setLastSelectedAccountId(account.id);

    if (account.baseUrl.isNotEmpty) {
      AppConfig.setBaseUrl(account.baseUrl);
      await ApiClient().setBaseUrl(account.baseUrl);
    }

    OrganizationUnit? unit;
    if (state.units.isNotEmpty) {
      unit = OrganizationService.findUnitByBaseUrl(state.units, account.baseUrl);
    }
    if (unit != null) {
      emit(state.copyWith(selectedUnit: unit, selectedBiometricAccount: account));
    }

    // Không emit prefillPassword — password sẽ được lấy khi authenticateWithBiometric
    emit(state.copyWith(
      selectedBiometricAccount: account,
      selectedUnit: unit ?? state.selectedUnit,
      prefillUsername: account.username,
    ));
  }

  Future<void> init(BuildContext context) async {
    await OrganizationService.applySavedBaseUrlIfAny();
    await SecureStorage.migrateOldBiometricData();
    await LoginAccountStorage.migrateLegacyBiometricAccounts();
    await _loadSavedAccounts();
    await _restoreLastSession();
    await loadUnits();
    if (!context.mounted) return;
    await _checkAutoLogin();
  }

  Future<void> loadUnits() async {
    try {
      final units = await OrganizationService.fetchUnits(appSlug: 'cham-cong');
      OrganizationUnit? selected;
      if (state.prefillUnitSlug.isNotEmpty) {
        selected = OrganizationService.findUnitBySlug(
          units,
          state.prefillUnitSlug,
        );
      }
      selected ??= state.prefillBaseUrl.isNotEmpty
          ? OrganizationService.findUnitByBaseUrl(units, state.prefillBaseUrl)
          : null;
      selected ??= state.selectedBiometricAccount != null
          ? OrganizationService.findUnitByBaseUrl(
              units,
              state.selectedBiometricAccount!.baseUrl,
            )
          : null;
      if (selected != null) {
        await OrganizationService.selectUnit(selected);
      }
      emit(state.copyWith(units: units, selectedUnit: selected));
    } catch (e) {
      debugPrint('Không thể tải danh sách đơn vị: $e');
    }
  }

  Future<void> _loadSavedAccounts() async {
    try {
      final accounts = await LoginAccountStorage.getSavedAccounts();
      final lastSelected = await LoginAccountStorage.getLastSelectedAccount();
      emit(state.copyWith(
        biometricAccounts: accounts,
        selectedBiometricAccount: lastSelected,
      ));
    } catch (e) {
      debugPrint('Lỗi khi load danh sách tài khoản: $e');
    }
  }

  Future<void> _restoreLastSession() async {
    final session = await LoginAccountStorage.loadLastSession();
    if (session == null) return;

    if (session.baseUrl.isNotEmpty) {
      AppConfig.setBaseUrl(session.baseUrl);
      await ApiClient().setBaseUrl(session.baseUrl);
    }

    emit(state.copyWith(
      prefillUsername: session.username,
      // Không điền mật khẩu vào form — user phải tự nhập
      prefillBaseUrl: session.baseUrl,
      prefillUnitSlug: session.unitSlug,
    ));
  }

  Future<void> _checkAutoLogin() async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
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
      final biometricEnabled =
          prefs.getBool(StorageKeys.biometricEnabled) ?? false;

      emit(state.copyWith(
        biometricEnabled:
            biometricEnabled && supportsBiometric && state.biometricAccounts.isNotEmpty,
      ));
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra hỗ trợ sinh trắc học: $e');
    }
  }

  Future<void> deleteSavedAccount(BiometricAccount account) async {
    try {
      await LoginAccountStorage.removeAccount(account.id);
      await _loadSavedAccounts();
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

    if (state.selectedUnit == null && state.units.isNotEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Vui lòng chọn đơn vị',
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
        errorMessage: null,
      ));
    }
  }

  Future<void> authenticateWithBiometric([BiometricAccount? account]) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final selectedAccount = account ?? state.selectedBiometricAccount;
      if (selectedAccount == null) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Không tìm thấy tài khoản',
        ));
        return;
      }

      if (selectedAccount.baseUrl.isNotEmpty) {
        AppConfig.setBaseUrl(selectedAccount.baseUrl);
        await ApiClient().setBaseUrl(selectedAccount.baseUrl);
      }

      final password =
          await LoginAccountStorage.getPasswordForAccount(selectedAccount.id);
      if (password == null || password.isEmpty) {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Không tìm thấy mật khẩu đã lưu',
        ));
        return;
      }

      final user = await _authService.login(
        selectedAccount.username,
        password,
      );

      await _persistSession(
        username: selectedAccount.username,
        password: password,
        user: user,
        rememberInList: true,
        existingAccount: selectedAccount.markAsUsed(),
      );

      emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
        showSuccessMessage: false,
      ));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: null));
    }
  }

  Future<void> _handleLoginSuccess(
    UserModel user,
    String username,
    String password,
  ) async {
    try {
      await NotificationService.instance.requestPermissionAndSyncToken(
        userId: user.id,
      );
    } catch (e) {
      debugPrint('Không thể đồng bộ FCM token sau đăng nhập: $e');
    }

    await _persistSession(
      username: username,
      password: password,
      user: user,
      rememberInList: true,
    );

    emit(state.copyWith(
      status: LoginStatus.success,
      user: user,
      showSuccessMessage: true,
    ));
  }

  Future<void> _persistSession({
    required String username,
    required String password,
    required UserModel user,
    required bool rememberInList,
    BiometricAccount? existingAccount,
  }) async {
    final baseUrl = state.selectedUnit?.url ?? AppConfig.apiBaseUrl;
    final unitSlug = state.selectedUnit?.slug ?? '';
    final unitName = state.selectedUnit?.name ?? '';

    await LoginAccountStorage.saveLastSession(
      username: username,
      baseUrl: baseUrl,
      unitSlug: unitSlug,
      unitName: unitName,
      password: password,
    );

    try {
      final biometricType = await BiometricHelper.getPrimaryBiometricType();
      final supportsBiometric = biometricType != null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.biometricEnabled, supportsBiometric);

      // Luôn lưu, chỉ giữ đúng 1 tài khoản — xóa hết tài khoản cũ trước
      final newAccount = existingAccount?.copyWith(
            name: user.name,
            avatar: user.image,
            organizationName: unitName,
            baseUrl: baseUrl,
            lastUsedAt: DateTime.now(),
          ) ??
          BiometricAccount(
            id: BiometricAccount.generateId(),
            username: username,
            password: '',
            name: user.name,
            avatar: user.image,
            baseUrl: baseUrl,
            organizationName: unitName,
            createdAt: DateTime.now(),
            lastUsedAt: DateTime.now(),
          );

      // Xóa tất cả tài khoản cũ rồi lưu lại đúng 1 tài khoản mới nhất
      await LoginAccountStorage.clearAllAndSave(newAccount, password);
      await _loadSavedAccounts();
    } catch (e) {
      debugPrint('Không thể lưu tài khoản: $e');
    }
  }

  void clearPrefillNotifiers() {
    emit(state.copyWith(clearPrefill: true));
  }
}
