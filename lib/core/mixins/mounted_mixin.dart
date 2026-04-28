import 'package:flutter/material.dart';
import 'package:attendancebyface/core/utils/state_helper.dart';

/// Mixin để giảm code trùng lặp cho mounted checks và setState
mixin MountedMixin<T extends StatefulWidget> on State<T> {
  /// Safe setState với mounted check
  void safeSetState(VoidCallback fn) {
    StateHelper.safeSetState(this, fn);
  }

  /// Safe setState với mounted check và return value
  R? safeSetStateWithReturn<R>(R Function() fn) {
    return StateHelper.safeSetStateWithReturn(this, fn);
  }

  /// Safe setState với mounted check và async operation
  Future<void> safeSetStateAsync(Future<void> Function() fn) async {
    await StateHelper.safeSetStateAsync(this, fn);
  }

  /// Safe setState với mounted check và async operation với return value
  Future<R?> safeSetStateAsyncWithReturn<R>(Future<R> Function() fn) async {
    return await StateHelper.safeSetStateAsyncWithReturn(this, fn);
  }

  /// Safe setState với mounted check và error handling
  Future<void> safeSetStateWithError(
    Future<void> Function() fn, {
    VoidCallback? onError,
  }) async {
    await StateHelper.safeSetStateWithError(this, fn, onError: onError);
  }

  /// Safe setState với mounted check và loading state
  Future<void> safeSetStateWithLoading(
    Future<void> Function() fn, {
    required ValueNotifier<bool> loadingNotifier,
  }) async {
    await StateHelper.safeSetStateWithLoading(
      this,
      fn,
      loadingNotifier: loadingNotifier,
    );
  }

  /// Check if widget is mounted
  bool get isMounted => mounted;

  /// Safe execution với mounted check
  void safeExecute(VoidCallback fn) {
    if (mounted) {
      fn();
    }
  }

  /// Safe execution với mounted check và return value
  R? safeExecuteWithReturn<R>(R Function() fn) {
    if (mounted) {
      return fn();
    }
    return null;
  }

  /// Safe execution với mounted check và async operation
  Future<void> safeExecuteAsync(Future<void> Function() fn) async {
    if (mounted) {
      await fn();
    }
  }

  /// Safe execution với mounted check và async operation với return value
  Future<R?> safeExecuteAsyncWithReturn<R>(Future<R> Function() fn) async {
    if (mounted) {
      return await fn();
    }
    return null;
  }
}
