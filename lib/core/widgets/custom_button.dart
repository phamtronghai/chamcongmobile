import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CustomButtonVariant {
  iconButton,
  normalButton,
  ctaButton,
  textButton,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final IconData? icon;
  final String? svgPath;
  final CustomButtonVariant variant;
  final double? width;
  final String? tooltip;
  final bool isLoading;

  const CustomButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.svgPath,
    this.variant = CustomButtonVariant.ctaButton,
    this.width,
    this.tooltip,
    this.isLoading = false,
  });

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    assert(
      _isValidConfig(),
      'CustomButton: invalid config for variant $variant',
    );

    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    final child = switch (variant) {
      CustomButtonVariant.iconButton => _buildIconButton(context, primary),
      CustomButtonVariant.normalButton => _buildNormalButton(context, primary),
      CustomButtonVariant.ctaButton => _buildCtaButton(context, primary),
      CustomButtonVariant.textButton => _buildTextButton(context, primary),
    };

    final wrapped = Opacity(
      opacity: _enabled ? 1 : 0.38,
      child: child,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: wrapped);
    }
    return wrapped;
  }

  bool _isValidConfig() {
    final hasIcon = icon != null || svgPath != null;
    return switch (variant) {
      CustomButtonVariant.iconButton => hasIcon,
      CustomButtonVariant.normalButton => text.isNotEmpty,
      CustomButtonVariant.ctaButton => text.isNotEmpty,
      CustomButtonVariant.textButton =>
        text.isNotEmpty && icon == null && svgPath == null,
    };
  }

  Widget _buildIconButton(BuildContext context, Color primary) {
    final size = width ?? ButtonConstants.iconButtonSize;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? ColorConstants.backgroundDark : ColorConstants.backgroundLight;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bgColor,
        shape: CircleBorder(
          side: BorderSide(color: primary, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          onLongPress: _enabled ? onLongPress : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: ButtonConstants.iconSize,
                    height: ButtonConstants.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  )
                : _buildIcon(iconColor: primary),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalButton(BuildContext context, Color primary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? ColorConstants.backgroundDark
        : ColorConstants.backgroundLight;
    final content = _buildLabelRow(
      foreground: primary,
      iconFirst: true,
    );

    final button = Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        side: BorderSide(color: primary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        onLongPress: _enabled ? onLongPress : null,
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        splashColor: primary.withValues(alpha: isDark ? 0.16 : 0.12),
        highlightColor: primary.withValues(alpha: isDark ? 0.08 : 0.06),
        child: SizedBox(
          height: ButtonConstants.heightButton,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return IntrinsicWidth(child: button);
  }

  Widget _buildCtaButton(BuildContext context, Color primary) {
    final foreground = ButtonConstants.ctaForegroundOn(primary);
    final content = _buildLabelRow(
      foreground: foreground,
      iconFirst: true,
    );

    final button = Material(
      color: primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        onLongPress: _enabled ? onLongPress : null,
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        child: SizedBox(
          height: ButtonConstants.heightButton,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }

  Widget _buildTextButton(BuildContext context, Color primary) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled ? onPressed : null,
        onLongPress: _enabled ? onLongPress : null,
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: isLoading
              ? SizedBox(
                  width: ButtonConstants.iconSize,
                  height: ButtonConstants.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                )
              : Text(
                  text,
                  style: TextConstants.appTextRegular.copyWith(color: primary),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  Widget _buildLabelRow({
    required Color foreground,
    required bool iconFirst,
  }) {
    final textWidget = Text(
      text,
      style: TextConstants.appTextBold.copyWith(
        color: foreground,
        height: 1.0,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    Widget leading;
    if (isLoading) {
      leading = SizedBox(
        width: ButtonConstants.iconSize,
        height: ButtonConstants.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    } else {
      leading = _buildIcon(iconColor: foreground);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconFirst) ...[
          leading,
          const SizedBox(width: 8),
          Flexible(child: textWidget),
        ] else ...[
          Flexible(child: textWidget),
          const SizedBox(width: 8),
          leading,
        ],
      ],
    );
  }

  Widget _buildIcon({required Color iconColor}) {
    if (svgPath != null) {
      final pathLower = svgPath!.toLowerCase();
      if (pathLower.endsWith('.png') ||
          pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.webp')) {
        return Image.asset(
          svgPath!,
          width: ButtonConstants.iconSize,
          height: ButtonConstants.iconSize,
          fit: BoxFit.contain,
        );
      }
      return SvgPicture.asset(
        svgPath!,
        width: ButtonConstants.iconSize,
        height: ButtonConstants.iconSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    }
    return Icon(icon, size: ButtonConstants.iconSize, color: iconColor);
  }
}
