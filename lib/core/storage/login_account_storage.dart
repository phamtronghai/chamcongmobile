import 'dart:convert';

import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/storage/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Metadata tài khoản trong SharedPreferences; mật khẩu chỉ ở [SecureStorage].
class LoginAccountStorage {
  static Map<String, dynamic> _toPrefsJson(BiometricAccount account) {
    return {
      'id': account.id,
      'username': account.username,
      'name': account.name,
      'avatar': account.avatar,
      'baseUrl': account.baseUrl,
      'organizationName': account.organizationName,
      'createdAt': account.createdAt.toIso8601String(),
      'lastUsedAt': account.lastUsedAt?.toIso8601String(),
    };
  }

  static BiometricAccount _fromPrefsJson(Map<String, dynamic> json) {
    return BiometricAccount(
      id: json['id'] as String,
      username: json['username'] as String,
      password: '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  static Future<List<BiometricAccount>> getSavedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.savedLoginAccounts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => _fromPrefsJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSavedAccounts(List<BiometricAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(accounts.map(_toPrefsJson).toList());
    await prefs.setString(StorageKeys.savedLoginAccounts, encoded);
  }

  static Future<void> upsertAccount(
    BiometricAccount account,
    String password,
  ) async {
    final accounts = await getSavedAccounts();
    final index = accounts.indexWhere((a) => a.isDuplicateOf(account));
    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }
    await saveSavedAccounts(accounts);
    await SecureStorage.setString(
      StorageKeys.loginPasswordKey(account.id),
      password,
    );
    await setLastSelectedAccountId(account.id);
  }

  static Future<void> removeAccount(String accountId) async {
    final accounts = await getSavedAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await saveSavedAccounts(accounts);
    await SecureStorage.remove(StorageKeys.loginPasswordKey(accountId));
  }

  /// Xóa tất cả tài khoản cũ, lưu duy nhất [account].
  static Future<void> clearAllAndSave(
    BiometricAccount account,
    String password,
  ) async {
    final existing = await getSavedAccounts();
    for (final old in existing) {
      if (old.id != account.id) {
        await SecureStorage.remove(StorageKeys.loginPasswordKey(old.id));
      }
    }
    await saveSavedAccounts([account]);
    await SecureStorage.setString(
      StorageKeys.loginPasswordKey(account.id),
      password,
    );
    await setLastSelectedAccountId(account.id);
  }

  static Future<String?> getPasswordForAccount(String accountId) =>
      SecureStorage.getString(StorageKeys.loginPasswordKey(accountId));

  static Future<void> setLastSelectedAccountId(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.savedLoginLastAccountId, accountId);
  }

  static Future<BiometricAccount?> getLastSelectedAccount() async {
    final accounts = await getSavedAccounts();
    if (accounts.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString(StorageKeys.savedLoginLastAccountId);
    if (lastId != null) {
      for (final a in accounts) {
        if (a.id == lastId) return a;
      }
    }
    return accounts.first;
  }

  static Future<void> saveLastSession({
    required String username,
    required String baseUrl,
    required String unitSlug,
    required String unitName,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.lastLoginUsername, username);
    await prefs.setString(StorageKeys.lastLoginBaseUrl, baseUrl);
    await prefs.setString(StorageKeys.lastLoginUnitSlug, unitSlug);
    await prefs.setString(StorageKeys.lastLoginUnitName, unitName);
    await SecureStorage.setString(StorageKeys.lastLoginPassword, password);
  }

  static Future<({
    String username,
    String baseUrl,
    String unitSlug,
    String unitName,
    String password,
  })?> loadLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(StorageKeys.lastLoginUsername);
    final baseUrl = prefs.getString(StorageKeys.lastLoginBaseUrl);
    if (username == null || username.isEmpty) return null;
    final password =
        await SecureStorage.getString(StorageKeys.lastLoginPassword) ?? '';
    return (
      username: username,
      baseUrl: baseUrl ?? '',
      unitSlug: prefs.getString(StorageKeys.lastLoginUnitSlug) ?? '',
      unitName: prefs.getString(StorageKeys.lastLoginUnitName) ?? '',
      password: password,
    );
  }

  /// Migration từ biometric_accounts cũ (password trong JSON).
  static Future<void> migrateLegacyBiometricAccounts() async {
    final legacy = await SecureStorage.getBiometricAccounts();
    if (legacy.isEmpty) return;
    final existing = await getSavedAccounts();
    if (existing.isNotEmpty) return;

    for (final account in legacy) {
      await upsertAccount(account, account.password);
    }
    await SecureStorage.saveBiometricAccounts([]);
  }
}
