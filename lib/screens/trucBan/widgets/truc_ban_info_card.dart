import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

class TrucBanInfoCard extends StatelessWidget {
  final String title;
  final Widget badge;
  final String? highlightText; // Amber chip
  final Widget? subInfoWidget; // Green chip area
  final String? detailText; // Text next to subInfo
  final int? detailMaxLines;
  final VoidCallback? onTap;
  final bool isActive;
  final EdgeInsetsGeometry? margin;

  const TrucBanInfoCard({
    super.key,
    required this.title,
    required this.badge,
    this.highlightText,
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
              // Badge
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
              // Info
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
                        if (highlightText != null && highlightText!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              highlightText!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.amber.shade900,
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
