import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

class GradientAvatarRing extends StatelessWidget {
  final double size;
  final List<Color>? colors;
  final double outerPadding;
  final double innerPadding;
  final Widget child;
  final List<BoxShadow>? boxShadow;
  final Color? innerBackgroundColor;

  const GradientAvatarRing({
    super.key,
    required this.size,
    required this.child,
    this.colors,
    this.outerPadding = 3.0,
    this.innerPadding = 2.0,
    this.boxShadow,
    this.innerBackgroundColor,
  });

  static const List<Color> _brandColors = [
    Color(0xFFC62828),
    ColorConstants.warningColor,
    Color(0xFFFBC02D),
    ColorConstants.primaryColor,
  ];

  @override
  Widget build(BuildContext context) {
    final Color effectiveInnerBackground =
        innerBackgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors ?? _brandColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: Padding(
        padding: EdgeInsets.all(outerPadding),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveInnerBackground,
          ),
          child: Padding(padding: EdgeInsets.all(innerPadding), child: child),
        ),
      ),
    );
  }
}
