import 'package:flutter/material.dart';
import 'package:attendancebyface/core/utils/snackbar_helper.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';

/// Mixin để giảm code trùng lặp cho error handling
mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  /// Handle error với snackbar
  void handleError(
    dynamic error, {
    String? customMessage,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và custom action
  void handleErrorWithAction(
    dynamic error, {
    String? customMessage,
    VoidCallback? onError,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    if (onError != null && mounted) {
      onError();
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và retry action
  void handleErrorWithRetry(
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    if (onRetry != null && mounted) {
      onRetry();
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và loading state
  void handleErrorWithLoading(
    dynamic error, {
    String? customMessage,
    ValueNotifier<bool>? loadingNotifier,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    if (loadingNotifier != null && mounted) {
      loadingNotifier.value = false;
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và state update
  void handleErrorWithState(
    dynamic error, {
    String? customMessage,
    VoidCallback? onStateUpdate,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    if (onStateUpdate != null && mounted) {
      onStateUpdate();
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và custom type
  void handleErrorWithType(
    dynamic error, {
    String? customMessage,
    CustomSnackbarType type = CustomSnackbarType.error,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.show(context, message, type, mounted: mounted);
    }

    debugPrint('Error in ${T.toString()}: $error');
  }

  /// Handle error với snackbar và custom action button
  void handleErrorWithActionButton(
    dynamic error, {
    String? customMessage,
    String? actionText,
    VoidCallback? onAction,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? 'Lỗi: ${error.toString()}';

    if (showSnackbar && mounted) {
      SnackbarHelper.showError(context, message, mounted: mounted);
    }

    if (onAction != null && mounted) {
      onAction();
    }

    debugPrint('Error in ${T.toString()}: $error');
  }
}
