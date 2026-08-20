import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/models/user_model.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool showSuccessMessage;

  final List<OrganizationUnit> units;
  final OrganizationUnit? selectedUnit;
  final List<BiometricAccount> biometricAccounts;
  final BiometricAccount? selectedBiometricAccount;
  final bool biometricEnabled;
  final bool rememberAccount;

  /// Điền form sau khi khôi phục phiên / chọn tài khoản SpeedDial
  final String prefillUsername;
  final String prefillPassword;
  final String prefillBaseUrl;
  final String prefillUnitSlug;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage,
    this.showSuccessMessage = true,
    this.units = const [],
    this.selectedUnit,
    this.biometricAccounts = const [],
    this.selectedBiometricAccount,
    this.biometricEnabled = false,
    this.rememberAccount = false,
    this.prefillUsername = '',
    this.prefillPassword = '',
    this.prefillBaseUrl = '',
    this.prefillUnitSlug = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? showSuccessMessage,
    List<OrganizationUnit>? units,
    OrganizationUnit? selectedUnit,
    List<BiometricAccount>? biometricAccounts,
    BiometricAccount? selectedBiometricAccount,
    bool? biometricEnabled,
    bool? rememberAccount,
    String? prefillUsername,
    String? prefillPassword,
    String? prefillBaseUrl,
    String? prefillUnitSlug,
    bool clearPrefill = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      showSuccessMessage: showSuccessMessage ?? this.showSuccessMessage,
      units: units ?? this.units,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      biometricAccounts: biometricAccounts ?? this.biometricAccounts,
      selectedBiometricAccount:
          selectedBiometricAccount ?? this.selectedBiometricAccount,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      rememberAccount: rememberAccount ?? this.rememberAccount,
      prefillUsername:
          clearPrefill ? '' : (prefillUsername ?? this.prefillUsername),
      prefillPassword:
          clearPrefill ? '' : (prefillPassword ?? this.prefillPassword),
      prefillBaseUrl:
          clearPrefill ? '' : (prefillBaseUrl ?? this.prefillBaseUrl),
      prefillUnitSlug:
          clearPrefill ? '' : (prefillUnitSlug ?? this.prefillUnitSlug),
    );
  }
}
