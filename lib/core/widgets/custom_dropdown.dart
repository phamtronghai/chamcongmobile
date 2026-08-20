import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  const CustomDropdown({
    super.key,
    required this.labelText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color defaultFillColor =
        theme.colorScheme.primary.withValues(alpha: 0.06);
    final Color defaultBorderColor = theme.colorScheme.primary.withValues(
      alpha: 0.6,
    );

    return Material(
      color: Colors.transparent,
      child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: theme.colorScheme.surfaceContainerHighest,
      style: theme.textTheme.bodyLarge,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.primary,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: defaultFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: defaultBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: defaultBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        ),
      ),
    ),
    );
  }
}
