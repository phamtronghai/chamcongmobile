import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ButtonType { normal, circular }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final IconData? icon;
  final String? svgPath;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonType buttonType;
  final double? width;
  final double? height;
  final String? tooltip;
  final bool isLoading;
  final double? fontSize;
  final EdgeInsetsGeometry? contentPadding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.svgPath,
    this.backgroundColor,
    this.textColor,
    this.buttonType = ButtonType.normal,
    this.width,
    this.height,
    this.tooltip,
    this.isLoading = false,
    this.fontSize,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (buttonType == ButtonType.circular) {
      return SizedBox(
        width: width ?? 48,
        height: height ?? 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: _buildCircularIcon(context),
            tooltip: tooltip ?? text,
            onPressed: onPressed,
            onLongPress: onLongPress,
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        onLongPress: isLoading ? null : onLongPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorConstants.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: Size(0, height ?? 56),
          alignment: Alignment.center,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
            ] else if (icon != null || svgPath != null) ...[
              _buildIcon(context),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: fontSize ?? TextConstants.body,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng icon với hỗ trợ cả SVG và IconData
  Widget _buildIcon(BuildContext context) {
    final iconColor =
        textColor ?? (backgroundColor ?? ColorConstants.primaryColor);

    if (svgPath != null) {
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

  /// Xây dựng icon cho circular button (luôn màu đen)
  Widget _buildCircularIcon(BuildContext context) {
    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath!,
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(icon, size: 20, color: Colors.black);
    } else {
      return const Icon(Icons.close, size: 20, color: Colors.black);
    }
  }
}
