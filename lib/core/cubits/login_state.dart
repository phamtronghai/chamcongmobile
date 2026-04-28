import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/models/user_model.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool showSuccessMessage;

  // Form State
  final List<OrganizationUnit> units;
  final OrganizationUnit? selectedUnit;
  final List<BiometricAccount> biometricAccounts;
  final BiometricAccount? selectedBiometricAccount;
  final bool biometricEnabled;
  final bool showAlternativeLogin;
  final bool rememberAccount;

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
    this.showAlternativeLogin = false,
    this.rememberAccount = false,
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
    bool? showAlternativeLogin,
    bool? rememberAccount,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage, // null is allowed to clear error
      showSuccessMessage: showSuccessMessage ?? this.showSuccessMessage,
      units: units ?? this.units,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      biometricAccounts: biometricAccounts ?? this.biometricAccounts,
      selectedBiometricAccount: selectedBiometricAccount ?? this.selectedBiometricAccount,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      showAlternativeLogin: showAlternativeLogin ?? this.showAlternativeLogin,
      rememberAccount: rememberAccount ?? this.rememberAccount,
    );
  }


}
