import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet nhập công việc (tách riêng từ AttendanceScreen)
class WorklogBottomSheet extends StatefulWidget {
  final UserModel user;
  final WorklogRepository worklogRepository;
  /// Callback sau khi thêm công việc thành công để màn hình cha refresh UI
  final Future<void> Function()? onSuccess;

  const WorklogBottomSheet({
    super.key,
    required this.user,
    required this.worklogRepository,
    this.onSuccess,
  });

  @override
  State<WorklogBottomSheet> createState() => _WorklogBottomSheetState();
}

class _WorklogBottomSheetState extends State<WorklogBottomSheet> {
  final TextEditingController _workNameController = TextEditingController();
  final FocusNode _workNameFocusNode = FocusNode();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final Set<int> _selectedSessionIds = <int>{};
  DateTimeRange? _selectedRange;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mặc định: hôm nay
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedRange = DateTimeRange(start: today, end: today);
    _workNameFocusNode.addListener(_handleWorkNameFocusChange);
  }

  @override
  void dispose() {
    _workNameFocusNode.removeListener(_handleWorkNameFocusChange);
    _workNameFocusNode.dispose();
    _sheetController.dispose();
    _workNameController.dispose();
    super.dispose();
  }

  void _handleWorkNameFocusChange() {
    if (!_workNameFocusNode.hasFocus || !_sheetController.isAttached) return;
    _sheetController.animateTo(
      0.9,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

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

  List<DateTime> _expandSelectedDates() {
    if (_selectedRange == null) return <DateTime>[];
    final start = DateTime(
      _selectedRange!.start.year,
      _selectedRange!.start.month,
      _selectedRange!.start.day,
    );
    final end = DateTime(
      _selectedRange!.end.year,
      _selectedRange!.end.month,
      _selectedRange!.end.day,
    );
    if (end.isBefore(start)) return <DateTime>[];
    final days = end.difference(start).inDays;
    return List<DateTime>.generate(
      days + 1,
      (index) => start.add(Duration(days: index)),
    );
  }

  DateTime _minDateByPolicy() {
    final DateTime now = DateTime.now();
    final bool isUnrestrictedDepartment =
        widget.user.departmentSlug == 'to-ncpt-khoa-hoc-cong-nghe';
    return isUnrestrictedDepartment
        ? DateTime(now.year - 1)
        : now.subtract(
            const Duration(
              days: AppConfig.worklogDateRangeDays,
            ),
          );
  }

  DateTime _maxDateByPolicy() {
    final DateTime now = DateTime.now();
    final bool isUnrestrictedDepartment =
        widget.user.departmentSlug == 'to-ncpt-khoa-hoc-cong-nghe';
    return isUnrestrictedDepartment
        ? DateTime(now.year + 1)
        : now.add(
            const Duration(
              days: AppConfig.worklogDateRangeDays,
            ),
          );
  }

  Future<void> _onSubmit() async {
    final String workName = _workNameController.text.trim();

    if (workName.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng nhập nội dung công việc',
        type: CustomSnackbarType.error,
      );
      return;
    }

    if (_selectedSessionIds.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn khung giờ (Sáng/Chiều/Ngoài giờ)',
        type: CustomSnackbarType.error,
      );
      return;
    }

    final selectedDates = _expandSelectedDates();
    if (selectedDates.isEmpty) {
      CustomSnackbar.show(
        context: context,
        message: 'Vui lòng chọn ngày báo cáo',
        type: CustomSnackbarType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.worklogRepository.init();
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      for (final int sessionId in _selectedSessionIds) {
        for (final DateTime date in selectedDates) {
          final String dateStr = dateFormat.format(date);
          final Map<String, dynamic> result =
              await widget.worklogRepository.createWorklog(
            userId: widget.user.id,
            workName: workName,
            sessionId: sessionId,
            date: dateStr,
          );
          if (result['success'] != true) {
            throw Exception(
              result['message'] ??
                  'Nhập công việc không thành công!',
            );
          }
        }
      }

      if (!mounted) return;

      // Cho phép màn hình cha reload danh sách công việc
      if (widget.onSuccess != null) {
        await widget.onSuccess!.call();
      }

      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackbar.show(
          context: context,
          message:
              'Nhập công việc thành công cho ${selectedDates.length} ngày',
          type: CustomSnackbarType.success,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Nhập công việc không thành công!',
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          controller: _sheetController,
          expand: false,
          minChildSize: 0.28,
          initialChildSize: 0.38,
          maxChildSize: 0.9,
          builder:
              (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Nhập công việc',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Nội dung công việc',
                      fieldType: CustomTextFieldType.multiline,
                      controller: _workNameController,
                      focusNode: _workNameFocusNode,
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSessionChip(
                            theme: theme,
                            label: 'Sáng',
                            sessionId: 1,
                          ),
                          _buildSessionChip(
                            theme: theme,
                            label: 'Chiều',
                            sessionId: 2,
                          ),
                          _buildSessionChip(
                            theme: theme,
                            label: 'Ngoài giờ',
                            sessionId: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DatePickerField(
                      mode: DatePickerFieldMode.range,
                      selectedRange: _selectedRange,
                      minDate: _minDateByPolicy(),
                      maxDate: _maxDateByPolicy(),
                      dialogTitle: 'Chọn khoảng ngày',
                      dialogSubtitle: 'Khoảng ngày báo cáo nhật ký công việc',
                      hintRange: 'Chọn ngày',
                      onRangeChanged: (range) {
                        setState(() => _selectedRange = range);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'XÁC NHẬN',
                      isLoading: _isSubmitting,
                      backgroundColor: theme.colorScheme.primary,
                      textColor: Colors.white,
                      onPressed: _isSubmitting
                          ? null
                          : _onSubmit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionChip({
    required ThemeData theme,
    required String label,
    required int sessionId,
  }) {
    final bool isSelected = _selectedSessionIds.contains(sessionId);
    final Color color = _sessionColor(theme, sessionId);

    return SamcomChip(
      label: label,
      onPressed: () {
        setState(() {
          if (isSelected) {
            _selectedSessionIds.remove(sessionId);
          } else {
            _selectedSessionIds.add(sessionId);
          }
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
}


