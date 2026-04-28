import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'storage_keys.dart';

/// Lớp wrapper cho FlutterSecureStorage để lưu trữ dữ liệu nhạy cảm
class SecureStorage {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  /// Lưu giá trị String
  static Future<void> setString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Lấy giá trị String
  static Future<String?> getString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Kiểm tra xem key có tồn tại không
  static Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  /// Xóa giá trị theo key
  static Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Xóa tất cả dữ liệu
  static Future<void> clear() async {
    await _secureStorage.deleteAll();
  }

  /// Lấy tất cả các key-value
  static Future<Map<String, String>> getAll() async {
    return await _secureStorage.readAll();
  }

  /// Lưu token đăng nhập
  static Future<void> saveAuthToken(String token) async {
    await setString(StorageKeys.authToken, token);
  }

  /// Lấy token đăng nhập
  static Future<String?> getAuthToken() async {
    return await getString(StorageKeys.authToken);
  }

  /// Xóa token đăng nhập
  static Future<void> removeAuthToken() async {
    await remove(StorageKeys.authToken);
  }

  // ========== Biometric Accounts Management ==========

  /// Lấy danh sách tài khoản sinh trắc học
  static Future<List<BiometricAccount>> getBiometricAccounts() async {
    try {
      final accountsJson = await getString(StorageKeys.biometricAccounts);
      if (accountsJson == null || accountsJson.isEmpty) {
        return [];
      }

      final List<dynamic> accountsList =
          json.decode(accountsJson) as List<dynamic>;
      return accountsList
          .map(
            (json) => BiometricAccount.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Lưu danh sách tài khoản sinh trắc học
  static Future<void> saveBiometricAccounts(
    List<BiometricAccount> accounts,
  ) async {
    final accountsJson = json.encode(
      accounts.map((account) => account.toJson()).toList(),
    );
    await setString(StorageKeys.biometricAccounts, accountsJson);
  }

  /// Thêm tài khoản mới hoặc cập nhật nếu trùng
  static Future<void> addBiometricAccount(BiometricAccount account) async {
    final accounts = await getBiometricAccounts();

    // Kiểm tra trùng lặp (username + baseUrl)
    final existingIndex = accounts.indexWhere((a) => a.isDuplicateOf(account));

    if (existingIndex != -1) {
      // Cập nhật tài khoản trùng
      accounts[existingIndex] = account;
    } else {
      // Thêm tài khoản mới
      accounts.add(account);
    }

    await saveBiometricAccounts(accounts);
  }

  /// Xóa tài khoản theo ID
  static Future<void> removeBiometricAccount(String accountId) async {
    final accounts = await getBiometricAccounts();
    accounts.removeWhere((account) => account.id == accountId);
    await saveBiometricAccounts(accounts);
  }

  /// Lấy tài khoản được chọn gần nhất
  static Future<BiometricAccount?> getLastSelectedAccount() async {
    try {
      final lastSelectedId = await getString(
        StorageKeys.biometricLastSelectedAccountId,
      );
      if (lastSelectedId == null || lastSelectedId.isEmpty) {
        return null;
      }

      final accounts = await getBiometricAccounts();
      return accounts.firstWhere(
        (account) => account.id == lastSelectedId,
        orElse: () => accounts.isNotEmpty
            ? accounts.first
            : throw StateError('No accounts'),
      );
    } catch (e) {
      final accounts = await getBiometricAccounts();
      return accounts.isNotEmpty ? accounts.first : null;
    }
  }

  /// Lưu ID tài khoản được chọn gần nhất
  static Future<void> setLastSelectedAccountId(String accountId) async {
    await setString(StorageKeys.biometricLastSelectedAccountId, accountId);
  }

  /// Migration: Chuyển đổi dữ liệu cũ sang format mới
  static Future<void> migrateOldBiometricData() async {
    try {
      // Kiểm tra xem đã migration chưa
      final accounts = await getBiometricAccounts();
      if (accounts.isNotEmpty) {
        // Đã có dữ liệu mới, không cần migration
        return;
      }

      // Kiểm tra xem có dữ liệu cũ không
      final oldUsername = await getString(StorageKeys.biometricUsername);
      final oldPassword = await getString(StorageKeys.biometricPassword);
      final oldBaseUrl = await getString(StorageKeys.biometricBaseUrl);
      final oldOrganizationName = await getString(
        StorageKeys.biometricOrganizationName,
      );
      final oldUserName = await getString(StorageKeys.biometricUserName);
      final oldAvatar = await getString(StorageKeys.biometricUserAvatar);

      // Nếu có dữ liệu cũ, chuyển đổi sang format mới
      if (oldUsername != null &&
          oldPassword != null &&
          oldUsername.isNotEmpty &&
          oldPassword.isNotEmpty) {
        final migratedAccount = BiometricAccount(
          id: BiometricAccount.generateId(),
          username: oldUsername,
          password: oldPassword,
          name: oldUserName ?? 'Người dùng',
          avatar: oldAvatar ?? '',
          baseUrl: oldBaseUrl ?? '',
          organizationName: oldOrganizationName ?? 'Đơn vị mặc định',
          createdAt: DateTime.now(),
        );

        await addBiometricAccount(migratedAccount);
        await setLastSelectedAccountId(migratedAccount.id);

        // Xóa dữ liệu cũ sau khi migration
        await remove(StorageKeys.biometricUsername);
        await remove(StorageKeys.biometricPassword);
        await remove(StorageKeys.biometricBaseUrl);
        await remove(StorageKeys.biometricOrganizationName);
        await remove(StorageKeys.biometricUserName);
        await remove(StorageKeys.biometricUserAvatar);
      }
    } catch (e) {
      // Ignore migration errors
    }
  }
}
