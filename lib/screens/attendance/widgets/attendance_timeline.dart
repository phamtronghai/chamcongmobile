import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// 1: trước 12h · 2: 12h–12h30 · 3: 12h30–17h · 4: từ 17h.
int? attendanceSlotNumber(DateTime t) {
  final m = t.hour * 60 + t.minute;
  if (m < 12 * 60) return 1;
  if (m < 12 * 60 + 30) return 2;
  if (m < 17 * 60) return 3;
  return 4;
}

TextStyle? timelineContentStyle(
  ThemeData theme, {
  bool muted = false,
  bool italic = false,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return TextConstants.appTextBold.copyWith(
    fontWeight: FontWeight.normal,
    fontSize: TextConstants.fontSizeApp,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: theme.colorScheme.onSurface.withValues(
      alpha: muted ? (isDark ? 0.55 : 0.5) : (isDark ? 0.88 : 0.8),
    ),
  );
}

class AttendanceTimelineTile extends StatelessWidget {
  final bool isLast;
  final Widget? leading;
  final int? slotNumber;
  final bool reserveLeading;
  final bool isDuplicateHighlight;
  final String title;
  final Widget? child;
  final VoidCallback? onTap;

  const AttendanceTimelineTile({
    super.key,
    required this.isLast,
    this.leading,
    this.slotNumber,
    this.reserveLeading = false,
    this.isDuplicateHighlight = false,
    required this.title,
    this.child,
    this.onTap,
  });

  static const double _railWidth = 48;
  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final borderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.28 : 0.12,
    );

    final showLeadingRail =
        leading != null || reserveLeading || slotNumber != null;
    final Widget? leadingChild;
    if (slotNumber != null) {
      leadingChild = Text(
        '$slotNumber',
        style: TextConstants.appTextBold.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: TextConstants.fontSizeApp,
          color: colorScheme.primary,
        ),
      );
    } else if (leading != null) {
      leadingChild = leading;
    } else {
      leadingChild = null;
    }

    // Chỉ chip thời gian nền đỏ khi trùng mốc / muộn mốc 3.
    final titleBg = isDuplicateHighlight
        ? (isDark
              ? ColorConstants.errorColor.withValues(alpha: 0.9)
              : ColorConstants.errorColor)
        : colorScheme.primary;
    final titleFg = isDuplicateHighlight
        ? ColorConstants.backgroundLight
        : colorScheme.onPrimary;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showLeadingRail) ...[
            SizedBox(
              width: _railWidth,
              child: Center(
                child: leadingChild == null
                    ? const SizedBox(width: _iconSize, height: _iconSize)
                    : Container(
                        width: _iconSize,
                        height: _iconSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.22 : 0.12,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withValues(
                              alpha: isDark ? 0.55 : 0.35,
                            ),
                          ),
                        ),
                        child: leadingChild,
                      ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Material(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
                side: BorderSide(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: titleBg,
                          borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                        ),
                        child: Text(
                          title,
                          style: TextConstants.appTextBold.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: TextConstants.fontSizeApp,
                            color: titleFg,
                          ),
                        ),
                      ),
                      if (child != null) ...[
                        const SizedBox(width: 10),
                        Expanded(child: child!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}