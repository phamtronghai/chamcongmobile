// ignore_for_file: invalid_use_of_protected_member
import 'package:flutter/material.dart';

/// Utility class để giảm code trùng lặp cho state management
class StateHelper {
  /// Safe setState với mounted check
  static void safeSetState(State state, VoidCallback fn) {
    if (state.mounted) {
      state.setState(fn);
    }
  }

  /// Safe setState với mounted check và return value
  static T? safeSetStateWithReturn<T>(State state, T Function() fn) {
    if (state.mounted) {
      state.setState(() {});
      return fn();
    }
    return null;
  }

  /// Safe setState với mounted check và async operation
  static Future<void> safeSetStateAsync(
    State state,
    Future<void> Function() fn,
  ) async {
    if (state.mounted) {
      await fn();
      if (state.mounted) {
        state.setState(() {});
      }
    }
  }

  /// Safe setState với mounted check và async operation với return value
  static Future<T?> safeSetStateAsyncWithReturn<T>(
    State state,
    Future<T> Function() fn,
  ) async {
    if (state.mounted) {
      final result = await fn();
      if (state.mounted) {
        state.setState(() {});
      }
      return result;
    }
    return null;
  }

  /// Safe setState với mounted check và error handling
  static Future<void> safeSetStateWithError(
    State state,
    Future<void> Function() fn, {
    VoidCallback? onError,
  }) async {
    if (state.mounted) {
      try {
        await fn();
        if (state.mounted) {
          state.setState(() {});
        }
      } catch (e) {
        if (state.mounted && onError != null) {
          onError();
        }
      }
    }
  }

  /// Safe setState với mounted check và loading state
  static Future<void> safeSetStateWithLoading(
    State state,
    Future<void> Function() fn, {
    required ValueNotifier<bool> loadingNotifier,
  }) async {
    if (state.mounted) {
      loadingNotifier.value = true;
      state.setState(() {});

      try {
        await fn();
      } finally {
        if (state.mounted) {
          loadingNotifier.value = false;
          state.setState(() {});
        }
      }
    }
  }
}
