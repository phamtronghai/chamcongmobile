import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';

class SamcomHeader extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;

  /// Null hoặc rỗng: không hiển thị dòng phụ.
  final String? subtitle;
  final Widget? subtitleWidget;
  final Color? primaryColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SamcomHeader({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.primaryColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final headerBg = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    final Widget leadingChild =
        leading ??
        Image.asset(AppConfig.logoOrg, width: 48, height: 48, fit: BoxFit.contain);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ColorConstants.defaultBorderRadius),
          topRight: Radius.circular(ColorConstants.defaultBorderRadius),
        ),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.28 : 0.18),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 52, height: 52, child: Center(child: leadingChild)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style:
                      titleStyle ??
                      TextConstants.appTextBold.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: TextConstants.fontSizeApp,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitleWidget != null) ...[
                  const SizedBox(height: 8),
                  subtitleWidget!,
                ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style:
                        subtitleStyle ??
                        TextConstants.appTextRegular.copyWith(
                          height: 1.3,
                          color: colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.75 : 0.68,
                          ),
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
