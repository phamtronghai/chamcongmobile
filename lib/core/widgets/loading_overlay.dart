import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_theme.dart';

class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Container(
            color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatingRing(controller: _controller),
                  if (widget.message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.message!,
                      style: TextConstants.appTextRegular.copyWith(
                        color: ColorConstants.backgroundLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// vienLogoTo.png xoay bên trên, logo cố định ở dưới — cùng kích thước.
class _AnimatingRing extends StatelessWidget {
  final AnimationController controller;
  static const double _size = AppConfig.sizeLogoApp;
  static const String _ring = 'assets/images/vienLogoTo.png';

  const _AnimatingRing({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo cố định ở dưới
          Image.asset(
            AppConfig.logoOrg,
            width: _size,
            height: _size,
            fit: BoxFit.contain,
          ),
          // Viền xoay ở trên
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Transform.rotate(
              angle: controller.value * 2 * 3.14159,
              child: Image.asset(
                _ring,
                width: _size,
                height: _size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
