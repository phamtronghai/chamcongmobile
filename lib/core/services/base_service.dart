import 'package:flutter/foundation.dart';

/// Base class cho tất cả services để giảm code trùng lặp
abstract class BaseService {
  /// Khởi tạo service - override trong subclass nếu cần
  Future<void> init() async {
    // Default implementation - có thể override
  }

  /// Dispose service - override trong subclass nếu cần
  void dispose() {
    // Default implementation - có thể override
  }

  /// Error handling pattern chung cho services
  Future<T> handleServiceCall<T>(
    Future<T> Function() serviceCall, {
    String? errorMessage,
  }) async {
    try {
      return await serviceCall();
    } catch (e) {
      // Log error nếu cần
      debugPrint('Service error: $e');
      rethrow;
    }
  }

  /// Error handling pattern với custom error message
  Future<T> handleServiceCallWithMessage<T>(
    Future<T> Function() serviceCall,
    String errorMessage,
  ) async {
    try {
      return await serviceCall();
    } catch (e) {
      debugPrint('$errorMessage: $e');
      rethrow;
    }
  }
}
