import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/worklog_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';

/// Hiển thị lời chào, lịch sử chấm công + danh sách công việc trong ngày
class DailyInfoSection extends StatefulWidget {
  /// User hiện tại để hiển thị lời chào
  final UserModel user;

  final bool isLoadingRecords;
  final List<AttendanceModel> attendanceRecords;
  final DateTime selectedDate;
  final VoidCallback onRefresh;
  final VoidCallback onSelectDate;
  final Future<void> Function(AttendanceModel) onShowLocation;

  final bool isLoadingWorklogs;
  final List<WorklogModel> worklogs;
  final VoidCallback onAddWorklog;

  /// Giờ server dạng text (HH:mm) + callback refresh giờ server
  final String serverTimeText;
  final VoidCallback onRefreshServerTime;

  const DailyInfoSection({
    super.key,
    required this.user,
    required this.isLoadingRecords,
    required this.attendanceRecords,
    required this.selectedDate,
    required this.onRefresh,
    required this.onSelectDate,
    required this.onShowLocation,
    required this.isLoadingWorklogs,
    required this.worklogs,
    required this.onAddWorklog,
    required this.serverTimeText,
    required this.onRefreshServerTime,
  });

  @override
  State<DailyInfoSection> createState() => _DailyInfoSectionState();
}

class _DailyInfoSectionState extends State<DailyInfoSection> {
  /// Session đang được chọn để hiển thị công việc (1: Sáng, 2: Trưa, 3: Ngoài giờ)
  int _selectedSessionId = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER chung (Lời chào + hàng chip Refresh/Date/Time server)
        _buildHeader(theme),
        // Section: Lịch sử chấm công
        _buildAttendanceHistorySection(theme),
        // Section: Công việc trong ngày
        _buildDailyWorklogs(theme),
      ],
    );
  }

  /// HEADER: 2 dòng – Dòng 1: lời chào, Dòng 2: hàng chip (Refresh + Date + Time server)
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dòng 1: lời chào
          GreetingSection(user: widget.user),
          const SizedBox(height: 3),
          // Dòng 2: hàng chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRefreshChip(theme),
              const SizedBox(width: 8),
              _buildDateChip(theme),
              const SizedBox(width: 8),
              _buildServerTimeChip(theme),
            ],
          ),
        ],
      ),
    );
  }

  /// Section: Lịch sử chấm công (tiêu đề + dải chip thời gian / empty state)
  Widget _buildAttendanceHistorySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch sử chấm công',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 1),
          SizedBox(
            height: 50,
            child: widget.isLoadingRecords
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : widget.attendanceRecords.isEmpty
                ? _buildEmptyState(theme)
                : _buildSortedAttendanceList(theme),
          ),
        ],
      ),
    );
  }

  // --- TRẠNG THÁI RỖNG DÙNG CHUNG ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SamcomChip(
        label: 'Chưa có dữ liệu',
        onPressed: null,
        variant: SamcomChipVariant.outlined,
        color: theme.colorScheme.outline,
        dense: true,
      ),
    );
  }

  // --- TRẠNG THÁI CÓ DỮ LIỆU (Lịch sử chấm công) ---
  Widget _buildSortedAttendanceList(ThemeData theme) {
    // Sắp xếp: Mới nhất lên đầu
    final sortedList = List<AttendanceModel>.from(widget.attendanceRecords)
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedList.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final attendance = sortedList[index];
        final isLatest = index == 0;

        return _buildTimeChip(theme, attendance, isLatest);
      },
    );
  }

  /// Section: "Công việc trong ngày"
  Widget _buildDailyWorklogs(ThemeData theme) {
    if (widget.isLoadingWorklogs) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Session icons + Add button
          Row(
            children: [
              Text(
                'Công việc trong ngày',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              // Session icon - taps to cycle through Sáng/Trưa/Ngoài giờ
              _buildCyclingSessionIcon(theme),
              // Circular Add button
              SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onAddWorklog,
                    child: const Icon(Icons.add, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 50, child: _buildWorklogChipsRow(theme)),
        ],
      ),
    );
  }

  /// Cycling icon button for session selection (Sáng → Trưa → Ngoài giờ → Sáng...)
  Widget _buildCyclingSessionIcon(ThemeData theme) {
    final Color color = _sessionColor(theme, _selectedSessionId);
    final IconData icon = _sessionIcon(_selectedSessionId);
    final String label = _sessionLabel(_selectedSessionId);

    return GestureDetector(
      onTap: () => setState(() {
        // Cycle: 1 -> 2 -> 3 -> 1
        _selectedSessionId = (_selectedSessionId % 3) + 1;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label for session
  String _sessionLabel(int sessionId) {
    switch (sessionId) {
      case 1:
        return 'Sáng';
      case 2:
        return 'Trưa';
      case 3:
        return 'Ngoài giờ';
      default:
        return '';
    }
  }

  /// Tạo dải chip công việc trong ngày (kèm chip "+"
  Widget _buildWorklogChipsRow(ThemeData theme) {
    // Lọc theo sessionId đang được chọn
    final List<WorklogModel> items = widget.worklogs
        .where((w) => w.sessionId == _selectedSessionId)
        .toList();

    if (items.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Sắp xếp theo thời gian thêm (cũ trước, mới sau)
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final List<Widget> chips = <Widget>[];
    for (final WorklogModel w in items) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildWorklogChip(theme, w, _selectedSessionId),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }

  /// Chip nội dung công việc (1 dòng, nền theo theme, viền theo sessionId)
  Widget _buildWorklogChip(
    ThemeData theme,
    WorklogModel worklog,
    int sessionId,
  ) {
    final Color borderColor = _sessionColor(theme, sessionId);

    return SamcomChip(
      label: worklog.workName,
      onPressed: null,
      variant: SamcomChipVariant.outlined,
      color: borderColor,
      leading: Icon(_sessionIcon(sessionId), size: 18, color: borderColor),
      dense: true,
    );
  }

  /// Màu phân loại session – dùng cho viền worklog chip
  Color _sessionColor(ThemeData theme, int sessionId) {
    switch (sessionId) {
      case 1:
        return theme.colorScheme.primary;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return theme.dividerColor;
    }
  }

  /// Icon phân loại session – dùng cho legend và chip công việc
  IconData _sessionIcon(int sessionId) {
    switch (sessionId) {
      case 1:
        return Icons.wb_sunny_outlined;
      case 2:
        return Icons.lunch_dining;
      case 3:
        return Icons.nights_stay;
      default:
        return Icons.work_outline;
    }
  }

  /// Legend nhỏ minh hoạ màu + icon cho từng session (Sáng/Trưa/Ngoài giờ)
  Widget _buildSessionLegendChip(ThemeData theme, String label, int sessionId) {
    final Color color = _sessionColor(theme, sessionId);
    final bool isSelected = _selectedSessionId == sessionId;
    final Color iconColor = isSelected ? theme.colorScheme.onPrimary : color;

    return SamcomChip(
      label: label,
      leading: Icon(_sessionIcon(sessionId), size: 16, color: iconColor),
      onPressed: () {
        setState(() {
          _selectedSessionId = sessionId;
        });
      },
      variant: isSelected
          ? SamcomChipVariant.filled
          : SamcomChipVariant.outlined,
      color: color,
      selected: isSelected,
      dense: true,
    );
  }

  // 1. Widget Chip Refresh
  Widget _buildRefreshChip(ThemeData theme) {
    return SamcomChip(
      label: '',
      leading: Icon(Icons.refresh, size: 20, color: theme.colorScheme.primary),
      onPressed: widget.onRefresh,
      variant: SamcomChipVariant.outlined,
      color: theme.dividerColor,
      dense: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // 2. Widget Chip Ngày tháng (Dùng trên Header)
  Widget _buildDateChip(ThemeData theme) {
    return SamcomChip(
      label: DateFormat('dd/MM').format(widget.selectedDate),
      leading: Icon(
        Icons.calendar_today,
        size: 16,
        color: theme.colorScheme.onSurface,
      ),
      onPressed: widget.onSelectDate,
      variant: SamcomChipVariant.outlined,
      color: theme.dividerColor,
      dense: true,
    );
  }

  // 3. Widget Chip Time server (HH:mm)
  Widget _buildServerTimeChip(ThemeData theme) {
    return SamcomChip(
      label: widget.serverTimeText,
      leading: Icon(
        Icons.access_time,
        size: 18,
        color: theme.colorScheme.primary,
      ),
      onPressed: widget.onRefreshServerTime,
      variant: SamcomChipVariant.outlined,
      color: theme.dividerColor,
      dense: true,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  // 4. Widget Chip Thời gian
  Widget _buildTimeChip(
    ThemeData theme,
    AttendanceModel attendance,
    bool isLatest,
  ) {
    final timeLabel = DateFormat('HH:mm').format(attendance.checkInTime);
    final primaryColor = theme.colorScheme.primary;

    return SamcomChip(
      label: timeLabel,
      onPressed: () => widget.onShowLocation(attendance),
      variant: SamcomChipVariant.filled,
      color: primaryColor,
      selected: isLatest,
      dense: true,
    );
  }
}

/// Phần chào user (dùng trên màn chấm công)
class GreetingSection extends StatelessWidget {
  final UserModel user;

  const GreetingSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      // Lời chào
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Overpass',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          children: [
            const TextSpan(text: 'Xin chào, '),
            TextSpan(
              text: user.name,
              style: TextStyle(
                fontFamily: 'Overpass',
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
