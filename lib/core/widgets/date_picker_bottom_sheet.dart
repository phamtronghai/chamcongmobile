import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';

/// Khoảng ngày preset (inclusive, date-only).
class DateRangePresets {
  DateRangePresets._();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTimeRange today([DateTime? ref]) {
    final d = _dateOnly(ref ?? DateTime.now());
    return DateTimeRange(start: d, end: d);
  }

  /// [days] ngày gần nhất tính đến hôm nay (vd. 7 → today-6 … today).
  static DateTimeRange lastDays(int days, [DateTime? ref]) {
    final end = _dateOnly(ref ?? DateTime.now());
    final start = end.subtract(Duration(days: days - 1));
    return DateTimeRange(start: start, end: end);
  }

  static DateTimeRange get last7Days => lastDays(7);

  static DateTimeRange get last30Days => lastDays(30);
}

/// Bottom sheet chọn ngày / khoảng ngày (Syncfusion calendar).
class AppDatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final List<DateTime>? initialDates;
  final DateTimeRange? initialRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateRangePickerSelectionMode selectionMode;
  final Function(dynamic) onSelectionChanged;

  const AppDatePickerBottomSheet({
    super.key,
    this.initialDate,
    this.initialDates,
    this.initialRange,
    this.minDate,
    this.maxDate,
    this.selectionMode = DateRangePickerSelectionMode.single,
    required this.onSelectionChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn ngày',
    String? subtitle,
    required void Function(DateTime) onDateSelected,
  }) {
    return _showBottomSheet(
      context,
      title: title,
      subtitle: subtitle,
      AppDatePickerBottomSheet(
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
        selectionMode: DateRangePickerSelectionMode.single,
        onSelectionChanged: (value) => onDateSelected(value as DateTime),
      ),
    );
  }

  static Future<void> showMultiple(
    BuildContext context, {
    required List<DateTime> initialDates,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn các ngày',
    String? subtitle,
    required void Function(List<DateTime>) onDatesSelected,
  }) {
    return _showBottomSheet(
      context,
      title: title,
      subtitle: subtitle,
      AppDatePickerBottomSheet(
        initialDates: initialDates,
        minDate: minDate,
        maxDate: maxDate,
        selectionMode: DateRangePickerSelectionMode.multiple,
        onSelectionChanged: (value) => onDatesSelected(value as List<DateTime>),
      ),
    );
  }

  static Future<void> showRange(
    BuildContext context, {
    required DateTimeRange initialRange,
    DateTime? minDate,
    DateTime? maxDate,
    String title = 'Chọn khoảng ngày',
    String? subtitle,
    required void Function(DateTimeRange) onRangeSelected,
  }) {
    return _showBottomSheet(
      context,
      title: title,
      subtitle: subtitle,
      AppDatePickerBottomSheet(
        initialRange: initialRange,
        minDate: minDate,
        maxDate: maxDate,
        selectionMode: DateRangePickerSelectionMode.range,
        onSelectionChanged: (value) => onRangeSelected(value as DateTimeRange),
      ),
    );
  }

  static Future<void> _showBottomSheet(
    BuildContext context,
    Widget child, {
    required String title,
    String? subtitle,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            DialogHeader(
              icon: Icons.calendar_today,
              title: title,
              subtitle: subtitle,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<AppDatePickerBottomSheet> createState() =>
      _AppDatePickerBottomSheetState();
}

class _AppDatePickerBottomSheetState extends State<AppDatePickerBottomSheet> {
  DateTime? _selectedDate;
  List<DateTime>? _selectedDates;
  PickerDateRange? _selectedRange;

  bool get _isRangeMode =>
      widget.selectionMode == DateRangePickerSelectionMode.range;

  @override
  void initState() {
    super.initState();
    if (widget.selectionMode == DateRangePickerSelectionMode.single) {
      _selectedDate = widget.initialDate ?? DateTime.now();
    } else if (widget.selectionMode == DateRangePickerSelectionMode.multiple) {
      _selectedDates = widget.initialDates ?? [];
    } else if (_isRangeMode && widget.initialRange != null) {
      _selectedRange = PickerDateRange(
        widget.initialRange!.start,
        widget.initialRange!.end,
      );
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (widget.selectionMode == DateRangePickerSelectionMode.single) {
        _selectedDate = args.value as DateTime;
      } else if (widget.selectionMode == DateRangePickerSelectionMode.multiple) {
        _selectedDates = (args.value as List<dynamic>).cast<DateTime>();
      } else if (_isRangeMode) {
        _selectedRange = args.value as PickerDateRange;
      }
    });
  }

  void _onConfirm() {
    if (widget.selectionMode == DateRangePickerSelectionMode.single) {
      if (_selectedDate != null) {
        widget.onSelectionChanged(_selectedDate);
      }
    } else if (widget.selectionMode == DateRangePickerSelectionMode.multiple) {
      widget.onSelectionChanged(_selectedDates ?? []);
    } else if (_isRangeMode) {
      if (_selectedRange != null && _selectedRange!.startDate != null) {
        final range = DateTimeRange(
          start: _selectedRange!.startDate!,
          end: _selectedRange!.endDate ?? _selectedRange!.startDate!,
        );
        widget.onSelectionChanged(range);
      }
    }
    Navigator.pop(context);
  }

  void _applyPresetRange(DateTimeRange range) {
    widget.onSelectionChanged(range);
    Navigator.pop(context);
  }

  bool _matchesPreset(DateTimeRange preset) {
    if (_selectedRange?.startDate == null) return false;
    final start = DateTime(
      _selectedRange!.startDate!.year,
      _selectedRange!.startDate!.month,
      _selectedRange!.startDate!.day,
    );
    final end = DateTime(
      (_selectedRange!.endDate ?? _selectedRange!.startDate)!.year,
      (_selectedRange!.endDate ?? _selectedRange!.startDate)!.month,
      (_selectedRange!.endDate ?? _selectedRange!.startDate)!.day,
    );
    return start == preset.start && end == preset.end;
  }

  Widget _buildRangePresets(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final presets = <({String label, DateTimeRange range})>[
      (label: 'Hôm nay', range: DateRangePresets.today()),
      (label: '7 ngày gần nhất', range: DateRangePresets.last7Days),
      (label: '30 ngày gần nhất', range: DateRangePresets.last30Days),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final preset in presets)
          SamcomChip(
            label: preset.label,
            dense: true,
            variant: SamcomChipVariant.outlined,
            color: primary,
            selected: _matchesPreset(preset.range),
            onPressed: () => _applyPresetRange(preset.range),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final headerColor = theme.textTheme.titleMedium?.color ?? Colors.black87;
    final subTextColor =
        theme.textTheme.bodySmall?.color ?? Colors.grey.shade600;
    final primary = colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRangeMode) ...[
          _buildRangePresets(context),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: 300,
          height: 350,
          child: SfDateRangePicker(
            view: DateRangePickerView.month,
            selectionMode: widget.selectionMode,
            initialSelectedDate: _selectedDate,
            initialSelectedDates: _selectedDates,
            initialSelectedRange: _selectedRange,
            minDate: widget.minDate ?? DateTime(2020),
            maxDate: widget.maxDate ?? DateTime(2030),
            backgroundColor: backgroundColor,
            headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: backgroundColor,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
            monthViewSettings: DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1,
              dayFormat: 'EEE',
              enableSwipeSelection: false,
              showTrailingAndLeadingDates: true,
              viewHeaderStyle: DateRangePickerViewHeaderStyle(
                backgroundColor: backgroundColor,
                textStyle: TextStyle(
                  color: subTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            selectionShape: DateRangePickerSelectionShape.circle,
            selectionColor: primary,
            selectionTextStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            rangeSelectionColor: primary.withValues(alpha: 0.3),
            startRangeSelectionColor: primary,
            endRangeSelectionColor: primary,
            rangeTextStyle: TextStyle(
              color: isDark ? Colors.white : primary,
              fontWeight: FontWeight.bold,
            ),
            monthCellStyle: DateRangePickerMonthCellStyle(
              textStyle: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
              todayTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? primary : null,
              ),
            ),
            onSelectionChanged: _onSelectionChanged,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomButton(
                text: 'Hủy',
                backgroundColor:
                    isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                textColor: textColor,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Chọn',
                backgroundColor: primary,
                onPressed: _onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
