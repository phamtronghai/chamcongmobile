import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Khung card list item dùng chung (Trực ban, Nghỉ phép, …).
class BaseInfoCard extends StatelessWidget {
  final String title;
  /// Hiển thị cùng hàng với [title] (bên phải, trước badge highlight).
  final Widget? titleTrailing;
  /// Dòng trên [title] (ví dụ: thời gian + chip trạng thái).
  final Widget? headerWidget;
  final Widget badge;
  final String? highlightText;
  final Color? highlightBackgroundColor;
  final Color? highlightTextColor;
  final Widget? subInfoWidget;
  final String? detailText;
  final int? detailMaxLines;
  final int? titleMaxLines;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsetsGeometry? margin;

  const BaseInfoCard({
    super.key,
    required this.title,
    this.titleTrailing,
    this.headerWidget,
    required this.badge,
    this.highlightText,
    this.highlightBackgroundColor,
    this.highlightTextColor,
    this.subInfoWidget,
    this.detailText,
    this.detailMaxLines,
    this.titleMaxLines,
    this.onTap,
    this.isActive = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: isActive ? 4 : 2,
      shadowColor: isActive ? primary.withAlpha(80) : null,
      color: isActive ? primary.withAlpha(15) : null,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        side: isActive
            ? BorderSide(color: primary, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withAlpha(isActive ? 80 : 25),
                  borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                ),
                child: Center(child: badge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerWidget != null) ...[
                      headerWidget!,
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextConstants.appTextRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: titleMaxLines ?? 2,
                          ),
                        ),
                        if (titleTrailing != null) ...[
                          const SizedBox(width: 8),
                          titleTrailing!,
                        ],
                        if (highlightText != null && highlightText!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  highlightBackgroundColor ??
                                  ColorConstants.warningColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                            ),
                            child: Text(
                              highlightText!,
                              style: TextConstants.appTextRegular.copyWith(
                                    color:
                                        highlightTextColor ??
                                        ColorConstants.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (subInfoWidget != null) ...[
                          subInfoWidget!,
                          const SizedBox(width: 8),
                        ],
                        if (detailText != null)
                          Expanded(
                            child: Text(
                              detailText!,
                              style: TextStyle(
                                fontSize: TextConstants.fontSizeApp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: detailMaxLines ?? 1,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
