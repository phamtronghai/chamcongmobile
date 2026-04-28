import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';

/// Utility class để giảm code trùng lặp cho CustomSnackbar calls
class SnackbarHelper {
  /// Hiển thị success message
  static void showSuccess(
    BuildContext context,
    String message, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.success,
      );
    }
  }

  /// Hiển thị error message
  static void showError(
    BuildContext context,
    String message, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.error,
      );
    }
  }

  /// Hiển thị warning message
  static void showWarning(
    BuildContext context,
    String message, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.warning,
      );
    }
  }

  /// Hiển thị info message
  static void showInfo(
    BuildContext context,
    String message, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.info,
      );
    }
  }

  /// Hiển thị custom message với type
  static void show(
    BuildContext context,
    String message,
    CustomSnackbarType type, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(context: context, message: message, type: type);
    }
  }

  /// Hiển thị error message với exception
  static void showErrorFromException(
    BuildContext context,
    dynamic exception, {
    String? customMessage,
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      final message = customMessage ?? 'Lỗi: ${exception.toString()}';
      showError(context, message, mounted: mounted);
    }
  }

  /// Hiển thị success message với action
  static void showSuccessWithAction(
    BuildContext context,
    String message,
    VoidCallback onAction, {
    bool mounted = true,
  }) {
    if (mounted && context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.success,
      );
      onAction();
    }
  }
}
