import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class AppDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final List<DateTime>? initialDates;
  final DateTimeRange? initialRange;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateRangePickerSelectionMode selectionMode;
  final Function(dynamic) onSelectionChanged;

  const AppDatePickerDialog({
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
    required Function(DateTime) onDateSelected,
  }) {
    return _showBottomSheet(
      context,
      AppDatePickerDialog(
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
    required Function(List<DateTime>) onDatesSelected,
  }) {
    return _showBottomSheet(
      context,
      AppDatePickerDialog(
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
    required Function(DateTimeRange) onRangeSelected,
  }) {
    return _showBottomSheet(
      context,
      AppDatePickerDialog(
        initialRange: initialRange,
        minDate: minDate,
        maxDate: maxDate,
        selectionMode: DateRangePickerSelectionMode.range,
        onSelectionChanged: (value) => onRangeSelected(value as DateTimeRange),
      ),
    );
  }

  static Future<void> _showBottomSheet(BuildContext context, Widget child) {
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
            const DialogHeader(
              icon: Icons.calendar_today,
              title: 'Chọn ngày',
              subtitle: 'Xem lịch trực theo ngày',
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
  State<AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<AppDatePickerDialog> {
  DateTime? _selectedDate;
  List<DateTime>? _selectedDates;
  PickerDateRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    if (widget.selectionMode == DateRangePickerSelectionMode.single) {
      _selectedDate = widget.initialDate ?? DateTime.now();
    } else if (widget.selectionMode == DateRangePickerSelectionMode.multiple) {
      _selectedDates = widget.initialDates ?? [];
    } else if (widget.selectionMode == DateRangePickerSelectionMode.range) {
      if (widget.initialRange != null) {
        _selectedRange = PickerDateRange(
          widget.initialRange!.start,
          widget.initialRange!.end,
        );
      }
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (widget.selectionMode == DateRangePickerSelectionMode.single) {
        _selectedDate = args.value as DateTime;
      } else if (widget.selectionMode == DateRangePickerSelectionMode.multiple) {
        _selectedDates = (args.value as List<dynamic>).cast<DateTime>();
      } else if (widget.selectionMode == DateRangePickerSelectionMode.range) {
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
    } else if (widget.selectionMode == DateRangePickerSelectionMode.range) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final headerColor = Theme.of(context).textTheme.titleMedium?.color ?? Colors.black87;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey.shade600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              firstDayOfWeek: 1, // Monday
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
            selectionColor: ColorConstants.primaryColor,
            selectionTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            rangeSelectionColor: ColorConstants.primaryColor.withOpacity(0.3),
            startRangeSelectionColor: ColorConstants.primaryColor,
            endRangeSelectionColor: ColorConstants.primaryColor,
            rangeTextStyle: TextStyle(
              color: isDark ? Colors.white : ColorConstants.primaryColor,
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
                color: isDark ? ColorConstants.primaryColor : null,
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
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                textColor: textColor,
                onPressed: () => Navigator.pop(context),
              ),
             ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Chọn',
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: _onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
