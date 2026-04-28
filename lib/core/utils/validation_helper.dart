/// Enum cho các loại validation
enum ValidationType { required, email, password, phone, username, custom }

/// Helper class để validate dữ liệu
/// Loại bỏ code lặp lại trong validation logic
class ValidationHelper {
  /// Cache cho validation results để tăng performance
  static final Map<String, String?> _validationCache = {};
  static const int _maxCacheSize = 50; // Giảm cache size để tiết kiệm memory

  /// Cache key generator
  static String _generateCacheKey(
    String value,
    ValidationType type, [
    String? fieldName,
  ]) {
    return '${value}_${type.name}_${fieldName ?? ''}';
  }

  /// Get cached validation result
  static String? _getCachedResult(String cacheKey) {
    return _validationCache[cacheKey];
  }

  /// Cache validation result
  static void _cacheResult(String cacheKey, String? result) {
    if (_validationCache.length >= _maxCacheSize) {
      // Remove oldest entry (simple LRU)
      _validationCache.remove(_validationCache.keys.first);
    }
    _validationCache[cacheKey] = result;
  }

  /// Clear validation cache
  static void clearCache() {
    _validationCache.clear();
  }

  /// Get cache size
  static int getCacheSize() {
    return _validationCache.length;
  }

  /// Validate required field
  static String? validateRequired(String? value, [String? fieldName]) {
    final cacheKey = _generateCacheKey(
      value ?? '',
      ValidationType.required,
      fieldName,
    );
    final cachedResult = _getCachedResult(cacheKey);
    if (cachedResult != null) return cachedResult;

    String? result;
    if (value == null || value.trim().isEmpty) {
      result = fieldName != null
          ? 'Vui lòng nhập $fieldName'
          : 'Trường này là bắt buộc';
    } else {
      result = null;
    }

    _cacheResult(cacheKey, result);
    return result;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    final cacheKey = _generateCacheKey(value ?? '', ValidationType.email);
    final cachedResult = _getCachedResult(cacheKey);
    if (cachedResult != null) return cachedResult;

    String? result;
    if (value == null || value.trim().isEmpty) {
      result = 'Vui lòng nhập email';
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        result = 'Email không hợp lệ';
      } else {
        result = null;
      }
    }

    _cacheResult(cacheKey, result);
    return result;
  }

  /// Validate username (login)
  static String? validateUsername(String? value) {
    return validateRequired(value, 'tên đăng nhập');
  }

  /// Validate password
  static String? validatePassword(String? value) {
    final requiredError = validateRequired(value, 'mật khẩu');
    if (requiredError != null) return requiredError;

    if (value!.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (10-11 số)';
    }

    return null;
  }

  /// Validate multiple fields at once
  static Map<String, String?> validateFields(
    Map<String, dynamic> fieldValidators,
  ) {
    final Map<String, String?> errors = {};

    fieldValidators.forEach((fieldName, validator) {
      if (validator is String? Function(String?)) {
        errors[fieldName] = validator(null);
      } else if (validator is Map) {
        final value = validator['value'] as String?;
        final validatorFn = validator['validator'] as String? Function(String?);
        errors[fieldName] = validatorFn(value);
      }
    });

    return errors;
  }

  /// Check if form is valid (no errors)
  static bool isFormValid(Map<String, String?> errors) {
    return errors.values.every((error) => error == null);
  }

  /// Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Login form validation
  static Map<String, String?> validateLoginForm(
    String? username,
    String? password,
  ) {
    return {
      'username': validateUsername(username),
      'password': validateRequired(password, 'mật khẩu'),
    };
  }

  /// Registration form validation
  static Map<String, String?> validateRegistrationForm({
    String? username,
    String? password,
    String? email,
    String? phone,
  }) {
    return {
      'username': validateUsername(username),
      'password': validatePassword(password),
      'email': validateEmail(email),
      'phone': validatePhone(phone),
    };
  }

  /// Factory method để tạo validator theo type
  static String? Function(String?) createValidator(
    ValidationType type, [
    String? fieldName,
  ]) {
    switch (type) {
      case ValidationType.required:
        return (value) => validateRequired(value, fieldName);
      case ValidationType.email:
        return validateEmail;
      case ValidationType.password:
        return validatePassword;
      case ValidationType.phone:
        return validatePhone;
      case ValidationType.username:
        return validateUsername;
      case ValidationType.custom:
        return (value) => null; // Custom validator sẽ được implement riêng
    }
  }

  /// Validate form với factory pattern
  static Map<String, String?> validateForm(
    Map<String, Map<String, dynamic>> formFields,
  ) {
    final Map<String, String?> errors = {};

    formFields.forEach((fieldName, fieldConfig) {
      final value = fieldConfig['value'] as String?;
      final type = fieldConfig['type'] as ValidationType;
      final customFieldName = fieldConfig['fieldName'] as String?;

      final validator = createValidator(type, customFieldName);
      errors[fieldName] = validator(value);
    });

    return errors;
  }
}
