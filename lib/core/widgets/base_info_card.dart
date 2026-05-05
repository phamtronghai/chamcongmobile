import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Khung card list item dùng chung (Trực ban, Nghỉ phép, …).
class BaseInfoCard extends StatelessWidget {
  final String title;
  /// Hiển thị cùng hàng với [title] (bên phải, trước badge highlight).
  final Widget? titleTrailing;
  final Widget badge;
  final String? highlightText;
  final Color? highlightBackgroundColor;
  final Color? highlightTextColor;
  final Widget? subInfoWidget;
  final String? detailText;
  final int? detailMaxLines;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsetsGeometry? margin;

  const BaseInfoCard({
    super.key,
    required this.title,
    this.titleTrailing,
    required this.badge,
    this.highlightText,
    this.highlightBackgroundColor,
    this.highlightTextColor,
    this.subInfoWidget,
    this.detailText,
    this.detailMaxLines,
    this.onTap,
    this.isActive = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 2,
      shadowColor: isActive ? ColorConstants.primaryColor.withAlpha(80) : null,
      color: isActive ? ColorConstants.primaryColor.withAlpha(15) : null,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
        side: isActive
            ? BorderSide(color: ColorConstants.primaryColor, width: 1.5)
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
                  color: ColorConstants.primaryColor.withAlpha(isActive ? 80 : 25),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(child: badge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
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
                                  Colors.amber.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              highlightText!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        highlightTextColor ??
                                        Colors.amber.shade900,
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
                                fontSize: TextConstants.caption,
                                color: Colors.grey.shade500,
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
