import 'dart:math';
import 'package:attendancebyface/core/app_theme.dart';

import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/repositories/attendance_repository.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ManualAttendanceScreen extends StatefulWidget {
  final UserModel user;

  const ManualAttendanceScreen({super.key, required this.user});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _DayGap {
  final DateTime date;
  final List<DateTime> recorded;
  final List<DateTime> fills;

  const _DayGap({
    required this.date,
    required this.recorded,
    required this.fills,
  });
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final AttendanceRepository _repository = locator<AttendanceRepository>();
  final DateFormat _dayFmt = DateFormat('dd/MM');
  final DateFormat _timeFmt = DateFormat('HH:mm');
  final Random _random = Random();

  bool _isMultiDay = false;
  DateTime _singleDate = _dateOnly(DateTime.now());
  late DateTimeRange _range;
  bool _isLoading = false;
  List<_DayGap> _gaps = [];

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _range = DateTimeRange(
      start: DateTime(today.year, today.month, 1),
      end: today,
    );
    _loadCurrentMode();
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _minutes(DateTime t) => t.hour * 60 + t.minute;

  /// 0 sáng vào, 1 trưa ra, 2 trưa vào, 3 chiều ra.
  static int _slotOf(DateTime t) {
    final m = _minutes(t);
    if (m < 12 * 60) return 0;
    if (m < 12 * 60 + 30) return 1;
    if (m < 17 * 60) return 2;
    return 3;
  }

  List<DateTime> _daysInRange(DateTimeRange range) {
    final today = _dateOnly(DateTime.now());
    var start = _dateOnly(range.start);
    var end = _dateOnly(range.end);
    if (end.isBefore(start)) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    if (start.isAfter(today)) return [];
    if (end.isAfter(today)) end = today;

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  DateTime _randomFillForSlot(DateTime date, int slot) {
    switch (slot) {
      case 0:
        return DateTime(
          date.year,
          date.month,
          date.day,
          7,
          45 + _random.nextInt(15),
        );
      case 1:
        return DateTime(
          date.year,
          date.month,
          date.day,
          12,
          1 + _random.nextInt(29),
        );
      case 2:
        return DateTime(
          date.year,
          date.month,
          date.day,
          12,
          31 + _random.nextInt(29),
        );
      default:
        final hour = 17 + _random.nextInt(3);
        if (hour == 17) {
          return DateTime(
            date.year,
            date.month,
            date.day,
            17,
            1 + _random.nextInt(59),
          );
        }
        if (hour == 18) {
          return DateTime(
            date.year,
            date.month,
            date.day,
            18,
            _random.nextInt(60),
          );
        }
        return DateTime(
          date.year,
          date.month,
          date.day,
          19,
          _random.nextInt(16),
        );
    }
  }

  /// Giờ tường như màn chấm công: `DateFormat` dùng `hour`/`minute` của
  /// `recordtime` đã parse, không `toLocal()` (API gắn `Z` nhưng là giờ VN).
  static DateTime _wallClockOn(DateTime date, DateTime recorded) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      recorded.hour,
      recorded.minute,
    );
  }

  _DayGap _buildGap(DateTime date, List<AttendanceModel> records) {
    final recorded =
        records.map((r) => _wallClockOn(date, r.checkInTime)).toList()
          ..sort((a, b) => a.compareTo(b));
    final occupiedSlots = recorded.map(_slotOf).toSet();
    final fills = <DateTime>[];
    for (var slot = 0; slot < 4; slot++) {
      if (!occupiedSlots.contains(slot)) {
        fills.add(_randomFillForSlot(date, slot));
      }
    }
    fills.sort((a, b) => a.compareTo(b));

    return _DayGap(date: date, recorded: recorded, fills: fills);
  }

  void _loadCurrentMode() {
    if (_isMultiDay) {
      _loadRange();
    } else {
      _loadSingleDay(_singleDate);
    }
  }

  Future<void> _loadSingleDay(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      await _repository.init();
      final d = _dateOnly(date);
      final key = DateFormat('yyyy-MM-dd').format(d);
      final records = await _repository.getAttendancesByDate(key);
      final gap = _buildGap(d, records);

      if (!mounted) return;
      setState(() => _gaps = [gap]);
    } catch (_) {
      if (!mounted) return;
      setState(() => _gaps = []);
      CustomSnackbar.show(
        context: context,
        message: 'Không tải được lịch sử chấm công',
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRange() async {
    setState(() => _isLoading = true);
    try {
      await _repository.init();
      final days = _daysInRange(_range);
      final results = await Future.wait(
        days.map((d) async {
          final key = DateFormat('yyyy-MM-dd').format(d);
          final records = await _repository.getAttendancesByDate(key);
          return MapEntry(d, records);
        }),
      );

      final gaps = <_DayGap>[];
      for (final entry in results) {
        final gap = _buildGap(entry.key, entry.value);
        if (gap.fills.isNotEmpty) gaps.add(gap);
      }
      gaps.sort((a, b) => a.date.compareTo(b.date));

      if (!mounted) return;
      setState(() => _gaps = gaps);
    } catch (_) {
      if (!mounted) return;
      setState(() => _gaps = []);
      CustomSnackbar.show(
        context: context,
        message: 'Không tải được lịch sử chấm công',
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _sameTime(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  void _rerandomizeFills() {
    setState(() {
      _gaps = _gaps
          .map(
            (g) => _DayGap(
              date: g.date,
              recorded: g.recorded,
              fills: [
                for (final fill in g.fills)
                  _randomFillForSlot(g.date, _slotOf(fill)),
              ]..sort((a, b) => a.compareTo(b)),
            ),
          )
          .toList();
    });
  }

  void _removeDay(_DayGap gap) {
    setState(() {
      _gaps = _gaps.where((g) => !_sameDay(g.date, gap.date)).toList();
    });
  }

  void _removeFill(_DayGap gap, DateTime fill) {
    setState(() {
      _gaps = _gaps
          .map((g) {
            if (!_sameDay(g.date, gap.date)) return g;
            final fills = g.fills.where((t) => !_sameTime(t, fill)).toList();
            return _DayGap(date: g.date, recorded: g.recorded, fills: fills);
          })
          .where((g) => _isMultiDay ? g.fills.isNotEmpty : true)
          .toList();
    });
  }

  String _formatToUtcIso8601(DateTime localDateTime) {
    return '${DateFormat("yyyy-MM-dd'T'HH:mm:00").format(localDateTime)}Z';
  }

  int get _fillCount => _gaps.fold<int>(0, (sum, g) => sum + g.fills.length);

  Future<void> _onConfirm() async {
    if (_isLoading || _fillCount == 0) return;

    final times = <String>[];
    for (final gap in _gaps) {
      for (final fill in gap.fills) {
        times.add(_formatToUtcIso8601(fill));
      }
    }
    if (times.isEmpty) return;

    final cubit = context.read<AttendanceCubit>();
    Navigator.of(context).pop();
    await cubit.submitManualAttendance(times, widget.user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Chấm công thủ công'),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserHeader(theme),
              if (!_isLoading) _buildStatsLegend(theme),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Center(
                  child: CustomSegmentedButton<bool>(
                    options: const [
                      CustomSegmentOption(value: false, label: '1 ngày'),
                      CustomSegmentOption(value: true, label: 'Nhiều ngày'),
                    ],
                    selected: {_isMultiDay},
                    onSelectionChanged: (selected) {
                      if (selected.isEmpty) return;
                      final nextMode = selected.first;
                      if (nextMode == _isMultiDay) return;
                      setState(() {
                        _isMultiDay = nextMode;
                        if (!_isMultiDay) {
                          _singleDate = _dateOnly(DateTime.now());
                        }
                      });
                      _loadCurrentMode();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isMultiDay)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: DatePickerField(
                    mode: DatePickerFieldMode.range,
                    selectedRange: _range,
                    label: 'Khoảng ngày',
                    dialogTitle: 'Chọn khoảng ngày',
                    dialogSubtitle:
                        'Quét lịch sử chấm công trong khoảng đã chọn',
                    maxDate: _dateOnly(DateTime.now()),
                    onRangeChanged: (range) {
                      setState(() => _range = range);
                      _loadRange();
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CenteredDaySlotNavigator(
                    selectedDate: _singleDate,
                    onDateSelected: (date) {
                      setState(() => _singleDate = _dateOnly(date));
                      _loadSingleDay(_singleDate);
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(child: _buildList(theme)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    CustomButton(
                      text: 'Trộn lại',
                      icon: Icons.casino,
                      variant: CustomButtonVariant.normalButton,
                      onPressed: (_isLoading || _fillCount == 0)
                          ? null
                          : _rerandomizeFills,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Xác nhận',
                        icon: Icons.check,
                        onPressed: (_isLoading || _fillCount == 0)
                            ? null
                            : _onConfirm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final user = widget.user;
    final imageUrl = _toAbsoluteUrl(user.image);
    final hasImage = imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
            child: hasImage
                ? null
                : Text(
                    _initials(user.name),
                    style: TextConstants.appTextSemiBold.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name.isEmpty ? 'Người dùng' : user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextConstants.appTextSemiBold.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toAbsoluteUrl(String value) {
    if (value.isEmpty) return value;
    if (value.startsWith('http')) return value;
    final base = ApiClient().dio.options.baseUrl;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _buildStatsLegend(ThemeData theme) {
    final missingLabel = _isMultiDay
        ? 'Thiếu: ${_gaps.length} ngày'
        : 'Thiếu: $_fillCount mốc';

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SamcomChip(
                label: missingLabel,
                dense: true,
                variant: SamcomChipVariant.filled,
                selected: true,
                color: ColorConstants.errorColor,
              ),
              SamcomChip(
                label: 'Đã chấm',
                dense: true,
                variant: SamcomChipVariant.filled,
                selected: true,
                color: theme.colorScheme.primary,
              ),
              SamcomChip(
                label: 'Chấm bù',
                dense: true,
                variant: SamcomChipVariant.outlined,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }
    if (_gaps.isEmpty) {
      return const BaseEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: _gaps.length,
      itemBuilder: (context, index) => _buildDayCard(theme, _gaps[index]),
    );
  }

  static const _weekdayVi = <int, String>{
    DateTime.monday: 'Thứ Hai',
    DateTime.tuesday: 'Thứ Ba',
    DateTime.wednesday: 'Thứ Tư',
    DateTime.thursday: 'Thứ Năm',
    DateTime.friday: 'Thứ Sáu',
    DateTime.saturday: 'Thứ Bảy',
    DateTime.sunday: 'Chủ nhật',
  };

  Widget _buildDayCard(ThemeData theme, _DayGap gap) {
    final chips = <(DateTime, bool)>[
      for (final t in gap.recorded) (t, false),
      for (final t in gap.fills) (t, true),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final isSunday = gap.date.weekday == DateTime.sunday;
    final title =
        '${_weekdayVi[gap.date.weekday]}, ${_dayFmt.format(gap.date)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextConstants.appTextBold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSunday ? ColorConstants.primaryColor : null,
                    ),
                  ),
                ),
                if (_isMultiDay) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Material(
                      color: ColorConstants.errorColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isLoading ? null : () => _removeDay(gap),
                        child: const Icon(
                          Icons.remove,
                          color: ColorConstants.backgroundLight,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in chips)
                    SamcomChip(
                      label: _timeFmt.format(item.$1),
                      dense: true,
                      variant: item.$2
                          ? SamcomChipVariant.outlined
                          : SamcomChipVariant.filled,
                      selected: !item.$2,
                      color: theme.colorScheme.primary,
                      onPressed: item.$2 && !_isLoading
                          ? () => _removeFill(gap, item.$1)
                          : null,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
