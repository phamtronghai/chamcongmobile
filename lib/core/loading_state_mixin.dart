import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';

/// Mixin để quản lý loading state và error handling
/// Loại bỏ code lặp lại trong các screens
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Set loading state và rebuild UI
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// Execute async operation với loading state
  Future<void> executeWithLoading(Future<void> Function() operation) async {
    setLoading(true);
    try {
      await operation();
    } finally {
      setLoading(false);
    }
  }

  /// Execute async operation với loading và error handling
  Future<R?> executeWithLoadingAndError<R>(
    Future<R> Function() operation, {
    String? errorMessage,
    bool showSuccessMessage = false,
    String? successMessage,
  }) async {
    setLoading(true);
    try {
      final result = await operation();

      if (showSuccessMessage && successMessage != null) {
        showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      showError(errorMessage ?? e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Hiển thị error message
  void showError(String message) {
    if (mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.error,
      );
    }
  }

  /// Hiển thị success message
  void showSuccess(String message) {
    if (mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.success,
      );
    }
  }

  /// Hiển thị info message
  void showInfo(String message) {
    if (mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.info,
      );
    }
  }

  /// Safe context operation - chỉ thực hiện nếu context.mounted
  void safeContextOperation(void Function() operation) {
    if (context.mounted) {
      operation();
    }
  }

  /// Safe async context operation
  Future<void> safeAsyncContextOperation(
    Future<void> Function() operation,
  ) async {
    if (context.mounted) {
      await operation();
    }
  }
}
