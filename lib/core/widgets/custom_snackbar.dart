import 'package:flutter/material.dart';
import 'package:attendancebyface/gen/assets.gen.dart';
// import 'package:attendancebyface/core/constants/color_constants.dart';
// Removed TextConstants; use textTheme instead

enum CustomSnackbarType { success, error, info, warning }

class CustomSnackbar {
  /// Gọi an toàn trong State sau các thao tác async:
  /// if (!mounted) return; CustomSnackbar.showIfMounted(state: this, message: '...');
  static void showIfMounted({
    required State state,
    required String message,
    CustomSnackbarType type = CustomSnackbarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!state.mounted) return;
    show(
      context: state.context,
      message: message,
      type: type,
      duration: duration,
    );
  }

  static void show({
    required BuildContext context,
    required String message,
    CustomSnackbarType type = CustomSnackbarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Lấy Overlay từ rootNavigator để luôn có overlay ngay cả khi đang ở Dialog/Route đặc biệt
    final overlayState = Navigator.of(context, rootNavigator: true).overlay;
    if (overlayState == null) {
      // Fallback an toàn: dùng SnackBar mặc định nếu không có Overlay
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: _getColorForType(type), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icon.logoAppChamCongBoTron.image(
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Tránh chèn overlay trong lúc đang build khung hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlayState.insert(overlayEntry);
    });
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  static Color _getColorForType(CustomSnackbarType type) {
    switch (type) {
      case CustomSnackbarType.success:
        return const Color(
          0xFF4CAF50,
        ); // Optionally map to theme.secondary if needed
      case CustomSnackbarType.error:
        return Colors.red;
      case CustomSnackbarType.warning:
        return const Color(0xFFFF9800);
      case CustomSnackbarType.info:
        return Colors.blue;
    }
  }
}
