import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';

// ─────────────────────────────────────────────
// Kiểu chọn ngày
// ─────────────────────────────────────────────
enum CustomDatePickerMode {
  /// Chọn đúng một ngày.
  single,

  /// Chọn nhiều ngày rời rạc (mặc định).
  multi,

  /// Chọn khoảng ngày liên tục.
  range,
}

// ─────────────────────────────────────────────
// Widget chính
// ─────────────────────────────────────────────

/// Datepicker toàn tháng dùng chung.
///
/// - Mặc định [mode] = [CustomDatePickerMode.multi]: chọn nhiều ngày.
/// - [mode] = [CustomDatePickerMode.range]: chọn khoảng.
///   Khi chuyển sang range, tự lấy ngày xa & gần nhất từ [selectedDates].
/// - Chip tháng/năm ở góc phải mở dropdown tháng + năm inline.
class CustomDatePicker extends StatefulWidget {
  /// Tập ngày đang được chọn (truyền vào để sync từ ngoài).
  final Set<DateTime> selectedDates;

  /// Callback mỗi khi tập ngày thay đổi.
  final ValueChanged<Set<DateTime>> onChanged;

  /// Chế độ chọn.
  final CustomDatePickerMode mode;

  /// Callback khi chế độ thay đổi.
  final ValueChanged<CustomDatePickerMode>? onModeChanged;

  /// Ngày hiển thị mặc định (tháng/năm ban đầu).
  final DateTime? initialDisplayDate;

  /// Có hiển thị bộ chọn chế độ (multi / range) không.
  final bool showModeToggle;

  const CustomDatePicker({
    super.key,
    required this.selectedDates,
    required this.onChanged,
    this.mode = CustomDatePickerMode.multi,
    this.onModeChanged,
    this.initialDisplayDate,
    this.showModeToggle = true,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime _displayMonth; // tháng/năm đang hiển thị
  bool _showMonthYearPicker = false;

  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDisplayDate ?? DateTime.now();
    _displayMonth = DateTime(base.year, base.month);
    _selectedMonth = _displayMonth.month;
    _selectedYear = _displayMonth.year;
  }

  // ── helpers ──────────────────────────────────────────────────────────

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSelected(DateTime d) {
    final day = _dateOnly(d);
    return widget.selectedDates.any((s) => _dateOnly(s) == day);
  }

  bool _isInRange(DateTime d) {
    if (widget.mode != CustomDatePickerMode.range) return false;
    if (widget.selectedDates.length < 2) return false;
    final sorted = widget.selectedDates.map(_dateOnly).toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    final day = _dateOnly(d);
    return day.isAfter(first) && day.isBefore(last);
  }

  bool _isRangeEdge(DateTime d) {
    if (widget.mode != CustomDatePickerMode.range) return false;
    if (widget.selectedDates.length < 2) return false;
    final sorted = widget.selectedDates.map(_dateOnly).toList()..sort();
    final day = _dateOnly(d);
    return day == sorted.first || day == sorted.last;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(last.day, (i) => first.add(Duration(days: i)));
  }

  // ── toggle ngày ──────────────────────────────────────────────────────

  void _toggleDay(DateTime day) {
    final d = _dateOnly(day);
    final current = widget.selectedDates.map(_dateOnly).toSet();

    switch (widget.mode) {
      case CustomDatePickerMode.single:
        // Chỉ 1 ngày duy nhất
        widget.onChanged({d});
      case CustomDatePickerMode.multi:
        if (current.contains(d)) {
          current.remove(d);
        } else {
          current.add(d);
        }
        widget.onChanged(current);
      case CustomDatePickerMode.range:
        // Chọn đúng 2 điểm mút; nếu đã có 2 → bắt đầu lại
        if (current.isEmpty || current.length >= 2) {
          widget.onChanged({d});
        } else {
          current.add(d);
          final sorted = current.toList()..sort();
          widget.onChanged({sorted.first, sorted.last});
        }
    }
  }

  // ── chuyển chế độ ────────────────────────────────────────────────────

  void _switchMode(CustomDatePickerMode newMode) {
    if (newMode == widget.mode) return;
    Set<DateTime> newDates = {};
    final existing = widget.selectedDates.map(_dateOnly).toList()..sort();
    switch (newMode) {
      case CustomDatePickerMode.single:
        newDates = existing.isNotEmpty ? {existing.first} : {};
      case CustomDatePickerMode.range:
        newDates = existing.isNotEmpty
            ? {existing.first, existing.last}
            : {};
      case CustomDatePickerMode.multi:
        newDates = existing.toSet();
    }
    widget.onModeChanged?.call(newMode);
    widget.onChanged(newDates);
  }

  // ── điều hướng tháng ─────────────────────────────────────────────────

  void _prevMonth() {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month - 1);
      _selectedMonth = _displayMonth.month;
      _selectedYear = _displayMonth.year;
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month + 1);
      _selectedMonth = _displayMonth.month;
      _selectedYear = _displayMonth.year;
    });
  }

  void _applyMonthYear() {
    setState(() {
      _displayMonth = DateTime(_selectedYear, _selectedMonth);
      _showMonthYearPicker = false;
    });
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final surface =
        isDark ? theme.colorScheme.onPrimary : theme.colorScheme.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── header ──────────────────────────────────────────────────────
        _buildHeader(primary, surface),
        const SizedBox(height: 8),

        // ── dropdown tháng/năm (inline) ──────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _showMonthYearPicker
              ? _buildMonthYearPicker(primary)
              : const SizedBox.shrink(),
        ),

        // ── lưới ngày ───────────────────────────────────────────────────
        _buildWeekdayLabels(primary),
        const SizedBox(height: 4),
        _buildDayGrid(primary, surface),

        // ── toggle chế độ ───────────────────────────────────────────────
        if (widget.showModeToggle) ...[
          const SizedBox(height: 12),
          _buildModeToggle(primary, surface),
        ],
      ],
    );
  }

  // ── header: mũi tên + chip tháng/năm ─────────────────────────────────

  Widget _buildHeader(Color primary, Color surface) {
    final label = DateFormat('MMMM yyyy', 'vi').format(_displayMonth);
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: primary),
          onPressed: _prevMonth,
          tooltip: 'Tháng trước',
        ),
        const Spacer(),
        // Chip tháng/năm
        _MonthYearChip(
          label: label,
          primary: primary,
          surface: surface,
          onTap: () => setState(
            () => _showMonthYearPicker = !_showMonthYearPicker,
          ),
          active: _showMonthYearPicker,
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.chevron_right, color: primary),
          onPressed: _nextMonth,
          tooltip: 'Tháng sau',
        ),
      ],
    );
  }

  // ── dropdown chọn tháng/năm (inline) ─────────────────────────────────

  Widget _buildMonthYearPicker(Color primary) {
    final now = DateTime.now();
    final months = List.generate(
      12,
      (i) => DropdownMenuItem<int>(
        value: i + 1,
        child: Text(DateFormat('MMMM', 'vi').format(DateTime(2000, i + 1))),
      ),
    );
    final years = List.generate(
      11,
      (i) {
        final y = now.year - 5 + i;
        return DropdownMenuItem<int>(value: y, child: Text('$y'));
      },
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdown<int>(
                  labelText: 'Tháng',
                  value: _selectedMonth,
                  items: months,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMonth = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomDropdown<int>(
                  labelText: 'Năm',
                  value: _selectedYear,
                  items: years,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedYear = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Áp dụng',
            icon: Icons.check,
            onPressed: _applyMonthYear,
          ),
        ],
      ),
    );
  }

  // ── nhãn thứ ──────────────────────────────────────────────────────────

  Widget _buildWeekdayLabels(Color primary) {
    // Bắt đầu từ Thứ Hai (ISO: 1=Mon … 7=Sun)
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Row(
      children: weekdays
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextConstants.appTextSemiBold.copyWith(
                    fontSize: TextConstants.fontSizeApp - 2,
                    color: primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── lưới ngày ─────────────────────────────────────────────────────────

  Widget _buildDayGrid(Color primary, Color surface) {
    final days = _daysInMonth(_displayMonth);
    // weekday 1=Mon, 7=Sun → số ô trống đầu
    final firstWeekday = days.first.weekday; // 1..7
    final leadingBlanks = firstWeekday - 1; // 0..6

    // Tổng số ô = blanks + số ngày, làm tròn lên bội số 7
    final total = leadingBlanks + days.length;
    final cells = (total / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: cells,
      itemBuilder: (context, index) {
        final dayIndex = index - leadingBlanks;
        if (dayIndex < 0 || dayIndex >= days.length) {
          return const SizedBox.shrink();
        }
        final day = days[dayIndex];
        return _DayCell(
          date: day,
          isSelected: _isSelected(day),
          isInRange: _isInRange(day),
          isRangeEdge: _isRangeEdge(day),
          primary: primary,
          surface: surface,
          onTap: () => _toggleDay(day),
        );
      },
    );
  }

  // ── toggle chế độ ─────────────────────────────────────────────────────

  Widget _buildModeToggle(Color primary, Color surface) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _ModeChip(
          label: 'Một ngày',
          active: widget.mode == CustomDatePickerMode.single,
          primary: primary,
          surface: surface,
          onTap: () => _switchMode(CustomDatePickerMode.single),
        ),
        _ModeChip(
          label: 'Nhiều ngày',
          active: widget.mode == CustomDatePickerMode.multi,
          primary: primary,
          surface: surface,
          onTap: () => _switchMode(CustomDatePickerMode.multi),
        ),
        _ModeChip(
          label: 'Khoảng',
          active: widget.mode == CustomDatePickerMode.range,
          primary: primary,
          surface: surface,
          onTap: () => _switchMode(CustomDatePickerMode.range),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Chip tháng/năm
// ─────────────────────────────────────────────

class _MonthYearChip extends StatelessWidget {
  final String label;
  final Color primary;
  final Color surface;
  final VoidCallback onTap;
  final bool active;

  const _MonthYearChip({
    required this.label,
    required this.primary,
    required this.surface,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? primary.withValues(alpha: 0.12) : primary,
      borderRadius:
          BorderRadius.circular(ColorConstants.defaultBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(ColorConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextConstants.appTextSemiBold.copyWith(
                  color: active ? primary : surface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                active
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: active ? primary : surface,
                size: ButtonConstants.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Chip chế độ (multi / range)
// ─────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color primary;
  final Color surface;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.active,
    required this.primary,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? primary : primary.withValues(alpha: 0.1),
      borderRadius:
          BorderRadius.circular(ColorConstants.defaultBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(ColorConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextConstants.appTextSemiBold.copyWith(
              color: active ? surface : primary,
              fontSize: TextConstants.fontSizeApp - 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ô ngày trong lưới
// ─────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isInRange;
  final bool isRangeEdge;
  final Color primary;
  final Color surface;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isInRange,
    required this.isRangeEdge,
    required this.primary,
    required this.surface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isSunday = date.weekday == DateTime.sunday;

    Color bgColor;
    Color fgColor;
    if (isSelected || isRangeEdge) {
      bgColor = primary;
      fgColor = surface;
    } else if (isInRange) {
      bgColor = primary.withValues(alpha: 0.18);
      fgColor = primary;
    } else {
      bgColor = Colors.transparent;
      fgColor = isSunday
          ? ColorConstants.errorColor
          : primary;
    }

    return Material(
      color: bgColor,
      shape: isInRange && !isRangeEdge
          ? const RoundedRectangleBorder()
          : CircleBorder(
              side: BorderSide(
                width: isToday ? 2 : 1,
                color: isSelected || isRangeEdge || isToday
                    ? primary
                    : primary.withValues(alpha: 0.25),
              ),
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: isInRange && !isRangeEdge
            ? const RoundedRectangleBorder()
            : const CircleBorder(),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: TextConstants.fontSizeApp - 1,
              fontWeight:
                  isSelected || isRangeEdge ? FontWeight.bold : FontWeight.w400,
              color: fgColor.withValues(
                alpha: fgColor == primary && !isSelected && !isRangeEdge
                    ? 0.85
                    : 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper: hiện datepicker trong bottom sheet
// ─────────────────────────────────────────────

/// Mở [CustomDatePicker] trong bottom sheet, trả về tập ngày đã chọn.
///
/// Ví dụ:
/// ```dart
/// final dates = await showCustomDatePickerSheet(
///   context: context,
///   initialDates: {DateTime.now()},
/// );
/// ```
Future<Set<DateTime>?> showCustomDatePickerSheet({
  required BuildContext context,
  Set<DateTime>? initialDates,
  CustomDatePickerMode initialMode = CustomDatePickerMode.multi,
  DateTime? initialDisplayDate,
  bool showModeToggle = true,
  String confirmLabel = 'Xác nhận',
}) async {
  Set<DateTime> current = {...?initialDates};
  CustomDatePickerMode mode = initialMode;

  return showModalBottomSheet<Set<DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ColorConstants.defaultBorderRadius),
      ),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CustomDatePicker(
                  selectedDates: current,
                  mode: mode,
                  initialDisplayDate: initialDisplayDate,
                  showModeToggle: showModeToggle,
                  onModeChanged: (m) => setModalState(() => mode = m),
                  onChanged: (dates) =>
                      setModalState(() => current = dates),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: confirmLabel,
                  icon: Icons.check,
                  onPressed: () => Navigator.of(ctx).pop(current),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}
