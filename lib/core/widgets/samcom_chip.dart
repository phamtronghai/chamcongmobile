import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';

enum SamcomChipVariant { filled, outlined }

/// Chip dùng chung cho toàn bộ ứng dụng SAMCOM
///
/// Quy ước: [TextConstants.appTextBold], bo góc 20, 1 dòng.
class SamcomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final SamcomChipVariant variant;
  final bool selected;
  final Color? color;
  final bool dense;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final bool fitContentWidth;

  const SamcomChip({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.variant = SamcomChipVariant.outlined,
    this.selected = false,
    this.color,
    this.dense = false,
    this.padding,
    this.fontSize,
    this.fitContentWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color baseColor = color ?? theme.colorScheme.primary;

    // Nền & viền theo variant
    late final Color backgroundColor;
    late final Color borderColor;
    late final Color textColor;

    if (variant == SamcomChipVariant.filled) {
      if (selected) {
        backgroundColor = baseColor;
        textColor = ButtonConstants.ctaForegroundOn(baseColor);
        borderColor = Colors.transparent;
      } else {
        backgroundColor = baseColor.withValues(alpha: 0.15);
        textColor = baseColor;
        borderColor = Colors.transparent;
      }
    } else {
      backgroundColor = baseColor.withValues(alpha: 0.08);
      textColor = theme.colorScheme.onSurface;
      borderColor = baseColor;
    }

    final EdgeInsetsGeometry effectivePadding =
        padding ??
        EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 4 : 6);

    final TextStyle chipTextStyle = TextConstants.appTextBold.copyWith(
      color: textColor,
      fontSize: fontSize ?? TextConstants.fontSizeApp,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final Widget labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          if (label.isNotEmpty) const SizedBox(width: 6),
        ],
        if (label.isNotEmpty)
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: chipTextStyle,
          ),
      ],
    );

    final chip = Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        side: BorderSide(
          color: borderColor,
          width: variant == SamcomChipVariant.outlined ? 1.5 : 0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: onPressed == null
          ? Padding(padding: effectivePadding, child: labelRow)
          : InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(
                ColorConstants.defaultBorderRadius,
              ),
              child: Padding(padding: effectivePadding, child: labelRow),
            ),
    );
    if (fitContentWidth) {
      return IntrinsicWidth(child: chip);
    }
    return chip;
  }
}
