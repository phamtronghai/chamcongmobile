import 'dart:math';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:intl/intl.dart';

/// Dialog để nhập thời gian chấm công thủ công
class ManualAttendanceDialog extends StatefulWidget {
  final String userId;

  const ManualAttendanceDialog({super.key, required this.userId});

  @override
  State<ManualAttendanceDialog> createState() => _ManualAttendanceDialogState();
}

class _ManualAttendanceDialogState extends State<ManualAttendanceDialog> {
  DateTime _selectedDate = DateTime.now();
  final List<TextEditingController> _timeControllers = [
    TextEditingController(text: '07:55'),
    TextEditingController(text: '12:01'),
    TextEditingController(text: '12:31'),
    TextEditingController(text: '17:01'),
  ];
  final bool _isSubmitting = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _randomizeTimes();
  }

  @override
  void dispose() {
    for (final controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Lấy danh sách thời gian đã nhập (bỏ qua TextField trống)
  List<String> _getValidTimes() {
    final List<String> validTimes = [];
    for (final controller in _timeControllers) {
      final time = controller.text.trim();
      if (time.isNotEmpty) {
        validTimes.add(time);
      }
    }
    return validTimes;
  }

  /// Chuyển đổi thời gian sang format ISO 8601
  String _formatToUtcIso8601(DateTime date, String timeStr) {
    // Parse time string (HH:mm)
    final timeParts = timeStr.split(':');
    if (timeParts.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);

    if (hour == null || minute == null) {
      throw FormatException('Invalid time format: $timeStr');
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException('Time out of range: $timeStr');
    }

    // Tạo DateTime với ngày và giờ đã chọn (local time)
    final localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Format theo ISO 8601: YYYY-MM-DDTHH:mm:00Z
    return '${DateFormat("yyyy-MM-dd'T'HH:mm:00").format(localDateTime)}Z';
  }

  /// Xóa thời gian ở index
  void _clearTime(int index) {
    setState(() {
      _timeControllers[index].clear();
    });
  }

  List<int> _visibleTimeIndexes() {
    return List<int>.generate(
      _timeControllers.length,
      (index) => index,
    ).where((index) => _timeControllers[index].text.trim().isNotEmpty).toList();
  }

  /// Random thời gian theo khung chuẩn (logic mùa đông)
  void _randomizeTimes() {
    setState(() {
      // Thời gian 1: 07:45-07:59
      final hour = 7;
      final minute = 45 + _random.nextInt(15); // 45-59
      _timeControllers[0].text =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

      // Thời gian 2: 12:01-12:29
      final hour2 = 12;
      final minute2 = 1 + _random.nextInt(29); // 1-29
      _timeControllers[1].text =
          '${hour2.toString().padLeft(2, '0')}:${minute2.toString().padLeft(2, '0')}';

      // Thời gian 3: không phụ thuộc mùa - 12:31-12:59
      final hour3 = 12;
      final minute3 = 31 + _random.nextInt(29); // 31-59
      _timeControllers[2].text =
          '${hour3.toString().padLeft(2, '0')}:${minute3.toString().padLeft(2, '0')}';

      // Thời gian 4: không phụ thuộc mùa - 17:01-19:15
      // Có thể là 17:01-17:59, 18:00-18:59, hoặc 19:00-19:15
      final startHour = 17;
      final endHour = 19;
      final hour4 =
          startHour +
          _random.nextInt(endHour - startHour + 1); // 17, 18, hoặc 19

      if (hour4 == 17) {
        // 17:01-17:59
        final minute4 = 1 + _random.nextInt(59); // 1-59
        _timeControllers[3].text =
            '${hour4.toString().padLeft(2, '0')}:${minute4.toString().padLeft(2, '0')}';
      } else if (hour4 == 18) {
        // 18:00-18:59
        final minute4 = _random.nextInt(60); // 0-59
        _timeControllers[3].text =
            '${hour4.toString().padLeft(2, '0')}:${minute4.toString().padLeft(2, '0')}';
      } else {
        // 19:00-19:15
        final minute4 = _random.nextInt(16); // 0-15
        _timeControllers[3].text =
            '${hour4.toString().padLeft(2, '0')}:${minute4.toString().padLeft(2, '0')}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient background
            DialogHeader(
              icon: Icons.access_time,
              title: 'Chấm công thủ công',
              subtitle: 'Nhập thời gian chấm công cho ngày đã chọn',
              primaryColor: primaryColor,
            ),

            // Content section
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DatePickerField(
                        mode: DatePickerFieldMode.single,
                        selectedDate: _selectedDate,
                        label: 'Ngày chấm công',
                        dialogTitle: 'Chọn ngày',
                        dialogSubtitle:
                            'Áp dụng các mốc thời gian chấm bên dưới cho ngày này',
                        enabled: !_isSubmitting,
                        onDateChanged: (date) {
                          setState(() => _selectedDate = date);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Hiển thị các mốc thời gian, không đủ chỗ sẽ tự xuống dòng.
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List<Widget>.generate(
                          _visibleTimeIndexes().length,
                          (visibleIndex) {
                            final visibleIndexes = _visibleTimeIndexes();
                            final index = visibleIndexes[visibleIndex];
                            final value = _timeControllers[index].text.trim();
                            return SamcomChip(
                              label: value,
                              variant: SamcomChipVariant.filled,
                              color: theme.colorScheme.primary,
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _clearTime(index),
                              dense: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          CustomButton(
                            text: '',
                            variant: CustomButtonVariant.iconCircle,
                            icon: Icons.shuffle,
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            tooltip: 'Random thời gian',
                            onPressed: _isSubmitting ? null : _randomizeTimes,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Xác nhận',
                              backgroundColor: theme.colorScheme.primary,
                              isLoading: _isSubmitting,
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      final validTimes = _getValidTimes();
                                      if (validTimes.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Vui lòng chọn ít nhất một mốc thời gian',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Format times và trả về
                                      final List<String> formattedTimes = [];
                                      for (final time in validTimes) {
                                        try {
                                          final formatted = _formatToUtcIso8601(
                                            _selectedDate,
                                            time,
                                          );
                                          formattedTimes.add(formatted);
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Thời gian không hợp lệ: $time',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                      }

                                      Navigator.of(context).pop({
                                        'date': _selectedDate,
                                        'times': formattedTimes,
                                      });
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
