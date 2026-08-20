import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fw_tab_bar/fw_tab_bar.dart';

/// Tab bar chuẩn SAMCOM: sliding pill qua [FwTabBar], style từ theme.
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
    return FwTabBar(
      controller: controller,
      tabs: tabs,
      center: center,
      physics: physics,
      width: width,
      tabWidth: tabWidth,
      radius: ColorConstants.defaultBorderRadius,
      contentPadding: contentPadding,
      buttonMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      backgroundColor: colorScheme.primary,
      unselectedBackgroundColor:
          unselectedBackgroundColor ??
          colorScheme.onSurface.withValues(alpha: 0.12),
      labelStyle:
          labelStyle ??
          TextConstants.appTextBold.copyWith(color: colorScheme.onPrimary),
      unselectedLabelStyle:
          unselectedLabelStyle ??
          TextConstants.appTextBold.copyWith(color: colorScheme.onSurface),
    );
  }
}
