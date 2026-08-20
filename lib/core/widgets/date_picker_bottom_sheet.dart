import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_datepicker.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

/// Bottom sheet chọn ngày / khoảng ngày / nhiều ngày dùng [CustomDatePicker].
///
/// Public API giữ nguyên — các call site không cần sửa.
class AppDatePickerBottomSheet {
  // ── single ────────────────────────────────────────────────────────────

  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn ngày',
    String? subtitle,
    required void Function(DateTime) onDateSelected,
  }) {
    final init = initialDate ?? DateTime.now();
    return _present(
      context,
      title: title,
      subtitle: subtitle,
      initialDates: {init},
      initialMode: CustomDatePickerMode.single,
      showModeToggle: false,
      minDate: minDate,
      maxDate: maxDate,
      onConfirm: (dates) {
        if (dates.isNotEmpty) onDateSelected(dates.first);
      },
    );
  }

  // ── range ─────────────────────────────────────────────────────────────

  static Future<void> showRange(
    BuildContext context, {
    required DateTimeRange initialRange,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn khoảng ngày',
    String? subtitle,
    required void Function(DateTimeRange) onRangeSelected,
  }) {
    return _present(
      context,
      title: title,
      subtitle: subtitle,
      initialDates: {initialRange.start, initialRange.end},
      initialMode: CustomDatePickerMode.range,
      showModeToggle: false,
      minDate: minDate,
      maxDate: maxDate,
      onConfirm: (dates) {
        if (dates.isEmpty) return;
        final sorted = dates.toList()..sort();
        onRangeSelected(
          DateTimeRange(start: sorted.first, end: sorted.last),
        );
      },
    );
  }

  // ── private helper ─────────────────────────────────────────────────────

  static Future<void> _present(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Set<DateTime> initialDates,
    required CustomDatePickerMode initialMode,
    required bool showModeToggle,
    DateTime? minDate,
    DateTime? maxDate,
    required void Function(Set<DateTime>) onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ColorConstants.defaultBorderRadius),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      builder: (ctx) => _DatePickerSheet(
        title: title,
        subtitle: subtitle,
        initialDates: initialDates,
        initialMode: initialMode,
        showModeToggle: showModeToggle,
        minDate: minDate,
        maxDate: maxDate,
        onConfirm: onConfirm,
      ),
    );
  }
}

// ── sheet widget ───────────────────────────────────────────────────────────

class _DatePickerSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Set<DateTime> initialDates;
  final CustomDatePickerMode initialMode;
  final bool showModeToggle;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(Set<DateTime>) onConfirm;

  const _DatePickerSheet({
    required this.title,
    this.subtitle,
    required this.initialDates,
    required this.initialMode,
    required this.showModeToggle,
    this.minDate,
    this.maxDate,
    required this.onConfirm,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late Set<DateTime> _dates;
  late CustomDatePickerMode _mode;

  @override
  void initState() {
    super.initState();
    _dates = {...widget.initialDates};
    _mode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          DialogHeader(
            icon: Icons.calendar_today,
            title: widget.title,
            subtitle: widget.subtitle,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: CustomDatePicker(
                selectedDates: _dates,
                mode: _mode,
                showModeToggle: widget.showModeToggle,
                onModeChanged: (m) => setState(() => _mode = m),
                onChanged: (dates) => setState(() => _dates = dates),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Hủy',
                  icon: Icons.close,
                  variant: CustomButtonVariant.normalButton,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Chọn',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onConfirm(_dates);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
