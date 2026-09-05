import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/date_picker_bottom_sheet.dart';

/// Strip chọn ngày dùng chung (vuốt xem, chạm chọn).
///
/// Hàng: 1 ô tháng–năm cố định (`09` / `26`) + 4 ô ngày cuộn.
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
  /// Số ô ngày trong cửa sổ (không gồm ô tháng cố định).
  static const int _slotLength = 4;
  /// Ngày neo nằm gần giữa cửa sổ 4 ô (index 1).
  static const int _centerIndex = 1;
  /// Carousel 3 trang: trước / hiện tại / sau — recenter sau mỗi lần vuốt.
  static const int _centerPage = 1;
  static const int _pageCount = 3;
  /// 5 slot visual (1 tháng + 4 ngày) gần vuông → tỷ lệ hàng ≈ 5.
  static const double _dayRowAspectRatio = 5;

  PageController? _pageController;
  /// Ngày neo cửa sổ 4 ô đang hiển thị ở trang [_centerPage].
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
    if (_isSameDay(next, _safeViewAnchor)) {
      setState(() {
        _monthCursor = DateTime(next.year, next.month);
      });
      return;
    }
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
    await AppDatePickerBottomSheet.show(
      context,
      initialDate: initial,
      initialDisplayDate: _safeMonthCursor,
      title: 'Chọn ngày',
      onDateSelected: (picked) {
        if (!mounted) return;
        _jumpToDate(picked);
        widget.onDateSelected(picked);
      },
    );
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
    final selected = _dateOnly(widget.selectedDate);
    final monthSource = selected;
    final controller = _pageController!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width > 0 ? width / _dayRowAspectRatio : 72.0;
        return SizedBox(
          height: height,
          width: width,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _MonthBox(
                    month: monthSource.month,
                    year: monthSource.year,
                    primary: primary,
                    deActive: deActive,
                    textStyle: textStyle,
                    onTap: _pickMonthYear,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: VerticalDivider(
                  width: 12,
                  thickness: 1,
                  color: primary.withValues(alpha: 0.35),
                ),
              ),
              Expanded(
                flex: 4,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ô tháng–năm cố định: nền primary, gạch chéo 45° (phải → trái) chia tháng / năm.
class _MonthBox extends StatelessWidget {
  final int month;
  final int year;
  final Color primary;
  final Color deActive;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const _MonthBox({
    required this.month,
    required this.year,
    required this.primary,
    required this.deActive,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = month.toString().padLeft(2, '0');
    final yearLabel = (year % 100).toString().padLeft(2, '0');
    final labelStyle = textStyle.copyWith(
      fontSize: TextConstants.fontSizeApp,
      color: deActive,
      fontWeight: FontWeight.w600,
    );

    return Material(
      color: primary,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _MonthDiagonalPainter(
                color: deActive.withValues(alpha: 0.55),
              ),
            ),
            // Phần trên-trái: tháng
            Align(
              alignment: const Alignment(-0.4, -0.35),
              child: Text(monthLabel, maxLines: 1, style: labelStyle),
            ),
            // Phần dưới-phải: năm
            Align(
              alignment: const Alignment(0.4, 0.35),
              child: Text(yearLabel, maxLines: 1, style: labelStyle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gạch chéo 45° từ góc phải-trên sang trái-dưới.
class _MonthDiagonalPainter extends CustomPainter {
  final Color color;

  const _MonthDiagonalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MonthDiagonalPainter oldDelegate) =>
      oldDelegate.color != color;
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
    final fg = isSelectable
        ? primary
        : primary.withValues(alpha: 0.45);
    final borderWidth = isSelected
        ? 2.5
        : isToday
            ? 2.0
            : 1.0;
    final borderColor = isSelected || isToday
        ? primary
        : primary.withValues(alpha: 0.35);

    return Material(
      color: deActive,
      shape: CircleBorder(
        side: BorderSide(width: borderWidth, color: borderColor),
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
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: textStyle.copyWith(
                  fontSize: TextConstants.fontSizeApp,
                  fontWeight: FontWeight.normal,
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
