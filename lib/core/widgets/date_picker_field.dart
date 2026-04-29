import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/date_picker_dialog.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';

/// Hiển thị một ngày hoặc khoảng ngày (định dạng `dd/MM/yyyy`), chạm mở bottom sheet picker.
enum DatePickerFieldMode { single, range }

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.mode,
    this.selectedDate,
    this.selectedRange,
    this.onDateChanged,
    this.onRangeChanged,
    this.label,
    this.minDate,
    this.maxDate,
    this.dialogTitle,
    this.dialogSubtitle,
    this.enabled = true,
    this.hintSingle,
    this.hintRange,
    /// Chip nhỏ hơn — dùng trong hàng header cạnh chip khác.
    this.compact = false,
  })  : assert(
          mode != DatePickerFieldMode.single ||
              (onDateChanged != null),
          'onDateChanged is required for single mode',
        ),
        assert(
          mode != DatePickerFieldMode.range || (onRangeChanged != null),
          'onRangeChanged is required for range mode',
        );

  final DatePickerFieldMode mode;
  final DateTime? selectedDate;
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<DateTimeRange>? onRangeChanged;
  final String? label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? dialogTitle;
  final String? dialogSubtitle;
  final bool enabled;
  final String? hintSingle;
  final String? hintRange;
  final bool compact;

  static final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  String _displayText(BuildContext context) {
    switch (mode) {
      case DatePickerFieldMode.single:
        if (selectedDate == null) {
          return hintSingle ?? 'Chọn ngày';
        }
        return _fmt.format(selectedDate!);
      case DatePickerFieldMode.range:
        if (selectedRange == null) {
          return hintRange ?? 'Chọn khoảng ngày';
        }
        final r = selectedRange!;
        return '${_fmt.format(r.start)} – ${_fmt.format(r.end)}';
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;
    switch (mode) {
      case DatePickerFieldMode.single:
        await AppDatePickerDialog.show(
          context,
          initialDate: selectedDate ?? DateTime.now(),
          minDate: minDate,
          maxDate: maxDate,
          title: dialogTitle ?? 'Chọn ngày',
          subtitle: dialogSubtitle,
          onDateSelected: onDateChanged!,
        );
      case DatePickerFieldMode.range:
        final now = DateTime.now();
        final initial = selectedRange ??
            DateTimeRange(
              start: now,
              end: now.add(const Duration(days: 1)),
            );
        await AppDatePickerDialog.showRange(
          context,
          initialRange: initial,
          minDate: minDate,
          maxDate: maxDate,
          title: dialogTitle ?? 'Chọn khoảng ngày',
          subtitle: dialogSubtitle,
          onRangeSelected: onRangeChanged!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = _displayText(context);
    final isPlaceholder = (mode == DatePickerFieldMode.single &&
            selectedDate == null) ||
        (mode == DatePickerFieldMode.range && selectedRange == null);

    final SamcomChip chip = SamcomChip(
      label: text,
      leading: Icon(
        mode == DatePickerFieldMode.single
            ? Icons.calendar_today_outlined
            : Icons.date_range_outlined,
        size: compact ? 16 : 18,
        color: enabled
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      onPressed: enabled ? () => _openPicker(context) : null,
      variant: SamcomChipVariant.outlined,
      color: theme.dividerColor,
      dense: compact,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : null,
    );

    final Widget chipWidget =
        isPlaceholder ? Opacity(opacity: 0.55, child: chip) : chip;

    final Widget field = Center(child: chipWidget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
        ],
        field,
      ],
    );
  }
}
