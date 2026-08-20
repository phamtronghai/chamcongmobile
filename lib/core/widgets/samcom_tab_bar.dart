import 'package:attendancebyface/core/app_theme.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

/// [ButtonsTabBar] dùng chung: radius, margin, style từ theme.
class SamcomTabBar extends StatelessWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final bool center;
  final ScrollPhysics? physics;
  final double? width;
  final double? tabWidth;
  final EdgeInsets contentPadding;
  final Color? unselectedBackgroundColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  const SamcomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.center = false,
    this.physics,
    this.width,
    this.tabWidth,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.unselectedBackgroundColor,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bar = ButtonsTabBar(
      controller: controller,
      radius: ColorConstants.defaultBorderRadius,
      backgroundColor: colorScheme.primary,
      center: center,
      contentCenter: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      width: tabWidth,
      buttonMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      contentPadding: contentPadding,
      unselectedBackgroundColor:
          unselectedBackgroundColor ??
          colorScheme.onSurface.withValues(alpha: 0.12),
      labelStyle:
          labelStyle ??
          TextConstants.appTextBold.copyWith(color: colorScheme.onPrimary),
      unselectedLabelStyle:
          unselectedLabelStyle ??
          TextConstants.appTextBold.copyWith(color: colorScheme.onSurface),
      tabs: tabs,
    );

    if (width == null) return bar;
    return SizedBox(width: width, child: bar);
  }
}
