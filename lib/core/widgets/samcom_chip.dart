import 'package:flutter/material.dart';

enum SamcomChipVariant { filled, outlined }

/// Chip dùng chung cho toàn bộ ứng dụng SAMCOM
///
/// Quy ước:
/// - Bo góc cố định: 20
/// - Padding mặc định: horizontal 12, vertical 6
/// - Font: bodyMedium, size 16, bold
/// - Luôn 1 dòng, tràn thì ellipsis
class SamcomChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final SamcomChipVariant variant;
  final bool selected;
  final Color? color;
  final bool dense;
  final EdgeInsetsGeometry? padding;

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
        textColor = Colors.white;
        borderColor = Colors.transparent;
      } else {
        backgroundColor = baseColor.withValues(alpha: 0.15);
        textColor = baseColor;
        borderColor = Colors.transparent;
      }
    } else {
      // outlined
      backgroundColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
      borderColor = baseColor;
    }

    final EdgeInsetsGeometry effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final Widget labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          if (label.isNotEmpty) const SizedBox(width: 6),
        ],
        if (label.isNotEmpty)
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
    );

    return ActionChip(
      onPressed: onPressed,
      label: labelWidget,
      backgroundColor: backgroundColor,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.2,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      padding: effectivePadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor,
          width: variant == SamcomChipVariant.outlined ? 1.5 : 0,
        ),
      ),
    );
  }
}
