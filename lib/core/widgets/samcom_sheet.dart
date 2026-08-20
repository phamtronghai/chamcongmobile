import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/samcom_header.dart';
import 'package:flutter/material.dart';

/// Bottom sheet chuẩn SAMCOM: handle, [SamcomHeader], pad bàn phím.
class SamcomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final IconData? icon;
  final Color? primaryColor;
  final Widget child;
  final bool expandChild;
  final double maxHeightFactor;

  const SamcomSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.primaryColor,
    this.expandChild = false,
    this.maxHeightFactor = 0.92,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;

    final body = expandChild
        ? Expanded(child: child)
        : Flexible(
            child: SingleChildScrollView(
              child: child,
            ),
          );

    final column = Column(
      mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SamcomHeader(
          icon: icon,
          title: title,
          subtitle: subtitle,
          subtitleWidget: subtitleWidget,
          primaryColor: primaryColor,
        ),
        body,
      ],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ColorConstants.defaultBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: expandChild
              ? SizedBox(height: maxHeight, child: column)
              : column,
        ),
      ),
    );
  }
}
