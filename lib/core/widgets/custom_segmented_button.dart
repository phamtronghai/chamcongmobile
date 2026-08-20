import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';

class CustomSegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const CustomSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// [SegmentedButton] chuẩn SAMCOM — style lấy từ [ThemeData.segmentedButtonTheme].
class CustomSegmentedButton<T> extends StatelessWidget {
  final List<CustomSegmentOption<T>> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final ButtonStyle? style;

  const CustomSegmentedButton({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        this.style ?? Theme.of(context).segmentedButtonTheme.style;
    return SegmentedButton<T>(
      segments: options
          .map(
            (option) => ButtonSegment<T>(
              value: option.value,
              label: Text(option.label),
              icon: option.icon == null
                  ? null
                  : Icon(option.icon, size: ButtonConstants.iconSize),
            ),
          )
          .toList(),
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      showSelectedIcon: showSelectedIcon,
      style: style,
    );
  }
}
