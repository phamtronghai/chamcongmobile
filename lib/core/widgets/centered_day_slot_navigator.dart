import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_datepicker.dart';

/// Strip chọn ngày dùng chung (vuốt xem, chạm chọn).
class CenteredDaySlotNavigator extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CenteredDaySlotNavigator({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CenteredDaySlotNavigator> createState() =>
      _CenteredDaySlotNavigatorState();
}

class _CenteredDaySlotNavigatorState extends State<CenteredDaySlotNavigator> {
  static const int _slotLength = 5;
  static const int _centerIndex = 2; // ngày giữa cửa sổ xem (5 ô)
  /// Carousel 3 trang: trước / hiện tại / sau — recenter sau mỗi lần vuốt.
  static const int _centerPage = 1;
  static const int _pageCount = 3;
  /// 5 ô gần vuông → tỷ lệ hàng ≈ 5.
  static const double _dayRowAspectRatio = 5;

  PageController? _pageController;
  /// Ngày giữa cửa sổ 5 ô đang hiển thị ở trang [_centerPage].
  DateTime? _viewAnchor;
  DateTime? _monthCursor;
  bool _ignorePageCallback = false;

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// Hot reload không chạy lại [initState] — khởi tạo lười an toàn.
  void _ensureInitialized() {
    final d = _dateOnly(widget.selectedDate);
    _viewAnchor ??= d;
    _monthCursor ??= DateTime(d.year, d.month);
    _pageController ??= PageController(initialPage: _centerPage);
  }

  DateTime get _safeViewAnchor =>
      _viewAnchor ?? _dateOnly(widget.selectedDate);

  DateTime get _safeMonthCursor =>
      _monthCursor ??
      DateTime(widget.selectedDate.year, widget.selectedDate.month);

  @override
  void didUpdateWidget(covariant CenteredDaySlotNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureInitialized();
    final next = _dateOnly(widget.selectedDate);
    final prev = _dateOnly(oldWidget.selectedDate);
    if (next == prev) return;
    if (_isSameDay(next, _safeViewAnchor)) return;
    _jumpToDate(next);
  }

  void _jumpToDate(DateTime date) {
    _ensureInitialized();
    final d = _dateOnly(date);
    setState(() {
      _viewAnchor = d;
      _monthCursor = DateTime(d.year, d.month);
    });
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    _ignorePageCallback = true;
    controller.jumpToPage(_centerPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ignorePageCallback = false;
    });
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelectable(DateTime date) => true;

  DateTime _anchorForPage(int page) {
    final deltaDays = (page - _centerPage) * _slotLength;
    return _dateOnly(_safeViewAnchor.add(Duration(days: deltaDays)));
  }

  List<DateTime> _daysForAnchor(DateTime anchor) {
    return List.generate(
      _slotLength,
      (i) => anchor.subtract(Duration(days: _centerIndex - i)),
    );
  }

  void _onPageChanged(int page) {
    if (_ignorePageCallback || page == _centerPage) return;
    _ensureInitialized();

    final deltaDays = page < _centerPage ? -_slotLength : _slotLength;
    final anchor = _dateOnly(
      _safeViewAnchor.add(Duration(days: deltaDays)),
    );

    setState(() {
      _viewAnchor = anchor;
      _monthCursor = DateTime(anchor.year, anchor.month);
    });

    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    _ignorePageCallback = true;
    controller.jumpToPage(_centerPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ignorePageCallback = false;
    });
  }

  Future<void> _pickMonthYear() async {
    _ensureInitialized();
    final initial = _dateOnly(widget.selectedDate);
    final result = await showCustomDatePickerSheet(
      context: context,
      initialDates: {initial},
      initialMode: CustomDatePickerMode.single,
      initialDisplayDate: _safeMonthCursor,
      showModeToggle: false,
      confirmLabel: 'Chọn ngày',
    );
    if (result == null || result.isEmpty || !mounted) return;

    final picked = result.first;
    _jumpToDate(picked);
    widget.onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = colorScheme.primary;
    final deActive = isDark ? colorScheme.onPrimary : colorScheme.surface;
    final textStyle = TextConstants.appTextRegular;
    final monthYearLabel = DateFormat(
      'MMMM yyyy',
      'vi',
    ).format(_safeMonthCursor);
    final selected = _dateOnly(widget.selectedDate);
    final controller = _pageController!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _MonthYearChip(
              label: monthYearLabel,
              primary: primary,
              deActive: deActive,
              onTap: _pickMonthYear,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width > 0 ? width / _dayRowAspectRatio : 72.0;
            return SizedBox(
              height: height,
              width: width,
              child: PageView.builder(
                controller: controller,
                itemCount: _pageCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) {
                  final days = _daysForAnchor(_anchorForPage(page));
                  return Row(
                    children: [
                      for (final date in days)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _DayBox(
                              date: date,
                              isSelected: _isSameDay(date, selected),
                              isSelectable: _isSelectable(date),
                              primary: primary,
                              deActive: deActive,
                              textStyle: textStyle,
                              onTap: _isSelectable(date)
                                  ? () {
                                      _jumpToDate(date);
                                      widget.onDateSelected(date);
                                    }
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MonthYearChip extends StatelessWidget {
  final String label;
  final Color primary;
  final Color deActive;
  final VoidCallback onTap;

  const _MonthYearChip({
    required this.label,
    required this.primary,
    required this.deActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextConstants.appTextSemiBold.copyWith(
              color: deActive,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isSelectable;
  final Color primary;
  final Color deActive;
  final TextStyle textStyle;
  final VoidCallback? onTap;

  const _DayBox({
    required this.date,
    required this.isSelected,
    required this.isSelectable,
    required this.primary,
    required this.deActive,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEE', 'vi').format(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final fg = isSelected
        ? deActive
        : isSelectable
        ? primary
        : primary.withValues(alpha: 0.45);

    return Material(
      color: isSelected ? primary : deActive,
      shape: CircleBorder(
        side: BorderSide(
          width: isToday ? 2.5 : 1,
          color: isSelected || isToday
              ? primary
              : primary.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekday,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle.copyWith(
                  fontSize: TextConstants.fontSizeApp,
                  color: fg,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: textStyle.copyWith(
                  fontSize: TextConstants.fontSizeApp,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
