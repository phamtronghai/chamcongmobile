import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CustomButtonVariant { filled, tonal, outlined, text, iconCircle }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final IconData? icon;
  final String? svgPath;
  final Color? backgroundColor;
  final Color? textColor;
  final CustomButtonVariant variant;
  final double? width;
  final double? height;
  final String? tooltip;
  final bool isLoading;
  final double? fontSize;
  final EdgeInsetsGeometry? contentPadding;
  final bool iconCircleShowShadow;

  /// [true]: chiều ngang vừa icon + chữ (FAB pill); [false]: giữ hành vi cũ ([width] hoặc full ngang).
  final bool shrinkWrapWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.svgPath,
    this.backgroundColor,
    this.textColor,
    this.variant = CustomButtonVariant.filled,
    this.width,
    this.height,
    this.tooltip,
    this.isLoading = false,
    this.fontSize,
    this.contentPadding,
    this.iconCircleShowShadow = true,
    this.shrinkWrapWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == CustomButtonVariant.iconCircle) {
      return SizedBox(
        width: width ?? 48,
        height: height ?? 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: iconCircleShowShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            icon: _buildIcon(
              iconColor: textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: tooltip ?? text,
            onPressed: isLoading ? null : onPressed,
            onLongPress: isLoading ? null : onLongPress,
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final ButtonStyle style;
    switch (variant) {
      case CustomButtonVariant.filled:
        style = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.primary,
          foregroundColor: textColor ?? colorScheme.onPrimary,
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: Size(0, height ?? 56),
          alignment: Alignment.center,
        );
        break;
      case CustomButtonVariant.tonal:
        style = FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
          foregroundColor: textColor ?? colorScheme.onSecondaryContainer,
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: Size(0, height ?? 56),
          alignment: Alignment.center,
        );
        break;
      case CustomButtonVariant.outlined:
        style = OutlinedButton.styleFrom(
          foregroundColor: textColor ?? colorScheme.primary,
          side: BorderSide(
            color:
                backgroundColor ?? colorScheme.outline.withValues(alpha: 0.6),
          ),
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: Size(0, height ?? 56),
          alignment: Alignment.center,
        );
        break;
      case CustomButtonVariant.text:
        style = TextButton.styleFrom(
          foregroundColor: textColor ?? colorScheme.primary,
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: Size(0, height ?? 40),
          alignment: Alignment.center,
        );
        break;
      case CustomButtonVariant.iconCircle:
        // handled early return
        style = const ButtonStyle();
        break;
    }

    final resolvedTextColor = switch (variant) {
      CustomButtonVariant.filled => textColor ?? colorScheme.onPrimary,
      CustomButtonVariant.tonal =>
        textColor ?? colorScheme.onSecondaryContainer,
      CustomButtonVariant.outlined => textColor ?? colorScheme.primary,
      CustomButtonVariant.text => textColor ?? colorScheme.primary,
      CustomButtonVariant.iconCircle => textColor ?? colorScheme.onSurface,
    };

    final label = _buildLabelContent(
      resolvedTextColor,
      intrinsicWidth: shrinkWrapWidth,
    );

    final material = switch (variant) {
      CustomButtonVariant.filled => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          onLongPress: isLoading ? null : onLongPress,
          style: style,
          child: label,
        ),
      CustomButtonVariant.tonal => FilledButton(
          onPressed: isLoading ? null : onPressed,
          onLongPress: isLoading ? null : onLongPress,
          style: style,
          child: label,
        ),
      CustomButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          onLongPress: isLoading ? null : onLongPress,
          style: style,
          child: label,
        ),
      CustomButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          onLongPress: isLoading ? null : onLongPress,
          style: style,
          child: label,
        ),
      CustomButtonVariant.iconCircle => const SizedBox.shrink(),
    };

    if (shrinkWrapWidth) {
      return IntrinsicWidth(child: material);
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: material,
    );
  }

  Widget _buildLabelContent(
    Color resolvedTextColor, {
    required bool intrinsicWidth,
  }) {
    final textStyle = TextStyle(
      color: resolvedTextColor,
      fontSize: fontSize ?? TextConstants.body,
      fontWeight: FontWeight.bold,
      height: 1.0,
    );
    final textWidget = Text(
      text,
      style: textStyle,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedTextColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null || svgPath != null) ...[
          _buildIcon(iconColor: resolvedTextColor),
          const SizedBox(width: 8),
        ],
        if (intrinsicWidth)
          textWidget
        else
          Flexible(child: textWidget),
      ],
    );
  }

  /// Xây dựng icon với hỗ trợ cả SVG và IconData
  Widget _buildIcon({required Color iconColor}) {
    if (svgPath != null) {
      final pathLower = svgPath!.toLowerCase();
      if (pathLower.endsWith('.png') ||
          pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.webp')) {
        return Image.asset(
          svgPath!,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        );
      }
      return SvgPicture.asset(
        svgPath!,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(icon, size: 20, color: iconColor);
    } else {
      return Icon(Icons.close, size: 20, color: iconColor);
    }
  }
}
