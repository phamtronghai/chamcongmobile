import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/date_picker_dialog.dart';

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
  final Set<int> _selectedSessionIds = <int>{};
  List<DateTime> _selectedDates = <DateTime>[];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Mặc định: hôm nay
    final now = DateTime.now();
    _selectedDates = <DateTime>[DateTime(now.year, now.month, now.day)];
  }

  @override
  void dispose() {
    _workNameController.dispose();
    super.dispose();
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

  String _buildDateLabel() {
    if (_selectedDates.isEmpty) {
      return 'Chọn ngày';
    }

    final DateFormat fmt = DateFormat('dd/MM/yyyy');
    final DateTime today = DateTime.now();
    final DateTime todayDate =
        DateTime(today.year, today.month, today.day);

    if (_selectedDates.length == 1) {
      final DateTime d = _selectedDates.first;
      final DateTime onlyDate = DateTime(d.year, d.month, d.day);
      final String formatted = fmt.format(d);

      if (onlyDate == todayDate) {
        return 'Hôm nay: $formatted';
      }

      return 'Ngày: $formatted';
    }

    return 'Đã chọn: ${_selectedDates.length} ngày';
  }

  Future<void> _openDatePicker(BuildContext context) async {
    List<DateTime> tempSelectedDates =
        List<DateTime>.from(_selectedDates);

    final DateTime now = DateTime.now();
    final bool isUnrestrictedDepartment =
        widget.user.departmentSlug == 'to-ncpt-khoa-hoc-cong-nghe';

    final DateTime minDate = isUnrestrictedDepartment
        ? DateTime(now.year - 1)
        : now.subtract(
            const Duration(
              days: AppConfig.worklogDateRangeDays,
            ),
          );
    final DateTime maxDate = isUnrestrictedDepartment
        ? DateTime(now.year + 1)
        : now.add(
            const Duration(
              days: AppConfig.worklogDateRangeDays,
            ),
          );

    await AppDatePickerDialog.showMultiple(
      context,
      initialDates: tempSelectedDates,
      minDate: minDate,
      maxDate: maxDate,
      onDatesSelected: (dates) {
        if (dates.isNotEmpty) {
          setState(() {
            _selectedDates = dates;
          });
        }
      },
    );
  }

  Future<void> _onSubmit(BuildContext parentContext) async {
    final String workName = _workNameController.text.trim();

    if (workName.isEmpty) {
      CustomSnackbar.show(
        context: parentContext,
        message: 'Vui lòng nhập nội dung công việc',
        type: CustomSnackbarType.error,
      );
      return;
    }

    if (_selectedSessionIds.isEmpty) {
      CustomSnackbar.show(
        context: parentContext,
        message: 'Vui lòng chọn khung giờ (Sáng/Trưa/Ngoài giờ)',
        type: CustomSnackbarType.error,
      );
      return;
    }

    if (_selectedDates.isEmpty) {
      CustomSnackbar.show(
        context: parentContext,
        message: 'Vui lòng chọn ít nhất một ngày',
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
        for (final DateTime date in _selectedDates) {
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
        Navigator.of(parentContext).pop();
        CustomSnackbar.show(
          context: parentContext,
          message:
              'Nhập công việc thành công cho ${_selectedDates.length} ngày',
          type: CustomSnackbarType.success,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: parentContext,
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
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.4,
          initialChildSize: 0.55,
          maxChildSize: 0.9,
          builder:
              (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSessionChip(
                          theme: theme,
                          label: 'Sáng',
                          sessionId: 1,
                        ),
                        _buildSessionChip(
                          theme: theme,
                          label: 'Trưa',
                          sessionId: 2,
                        ),
                        _buildSessionChip(
                          theme: theme,
                          label: 'Ngoài giờ',
                          sessionId: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: _buildDateLabel(),
                      backgroundColor: theme.colorScheme.secondary,
                      textColor: Colors.white,
                      onPressed: () => _openDatePicker(context),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'HỦY',
                            backgroundColor: Colors.grey.shade200,
                            textColor: theme.colorScheme.onSurface,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'XÁC NHẬN',
                            isLoading: _isSubmitting,
                            backgroundColor: theme.colorScheme.primary,
                            textColor: Colors.white,
                            onPressed: _isSubmitting
                                ? null
                                : () => _onSubmit(context),
                          ),
                        ),
                      ],
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


