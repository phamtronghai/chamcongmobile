import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendancebyface/core/app_theme.dart';

enum CustomTextFieldType { normal, password, email, number, phone, multiline }

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final VoidCallback? onPrefixIconPressed;
  final CustomTextFieldType fieldType;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextCapitalization textCapitalization;
  final bool showCursor;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onPrefixIconPressed,
    this.fieldType = CustomTextFieldType.normal,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.textCapitalization = TextCapitalization.none,
    this.showCursor = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late TextInputType _keyboardType;

  @override
  void initState() {
    super.initState();
    _initializeKeyboardType();
  }

  void _initializeKeyboardType() {
    if (widget.keyboardType != null) {
      _keyboardType = widget.keyboardType!;
    } else {
      switch (widget.fieldType) {
        case CustomTextFieldType.email:
          _keyboardType = TextInputType.emailAddress;
          break;
        case CustomTextFieldType.number:
          _keyboardType = TextInputType.number;
          break;
        case CustomTextFieldType.phone:
          _keyboardType = TextInputType.phone;
          break;
        case CustomTextFieldType.multiline:
          _keyboardType = TextInputType.multiline;
          break;
        default:
          _keyboardType = TextInputType.text;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color defaultFillColor = theme.colorScheme.surface;
    final Color defaultBorderColor = theme.colorScheme.primary.withValues(
      alpha: 0.6,
    );

    final int effectiveMaxLines =
        widget.maxLines ??
        (widget.fieldType == CustomTextFieldType.multiline ? 5 : 1);
    final int effectiveMinLines =
        widget.minLines ??
        (widget.fieldType == CustomTextFieldType.multiline ? 3 : 1);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText:
          widget.fieldType == CustomTextFieldType.password && _obscureText,
      keyboardType: _keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      maxLines: effectiveMaxLines,
      minLines: effectiveMinLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      showCursor: widget.showCursor,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      inputFormatters: widget.inputFormatters,
      style: widget.textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        filled: true,
        fillColor: widget.fillColor ?? defaultFillColor,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle:
            widget.labelStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
        hintStyle:
            widget.hintStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
        prefixIcon: widget.prefixIcon != null
            ? IconButton(
                icon: Icon(
                  widget.prefixIcon,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                onPressed: widget.onPrefixIconPressed,
              )
            : widget.prefix,
        suffixIcon: _buildSuffixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: widget.borderColor ?? defaultBorderColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(
            color: widget.borderColor ?? defaultBorderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.fieldType == CustomTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    } else {
      return widget.suffix;
    }
  }
}
