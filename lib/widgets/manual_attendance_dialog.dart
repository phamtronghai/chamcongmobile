import 'dart:math';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/date_picker_dialog.dart';
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
  bool _isWinterSeason = true; // Mặc định mùa đông
  final Random _random = Random();

  @override
  void dispose() {
    for (final controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Hiển thị dialog chọn ngày
  void _showDatePicker() {
    AppDatePickerDialog.show(
      context,
      initialDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
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

  /// Random thời gian dựa trên mùa đã chọn
  void _randomizeTimes() {
    setState(() {
      // Thời gian 1: phụ thuộc mùa
      if (_isWinterSeason) {
        // Mùa đông: 07:45-07:59
        final hour = 7;
        final minute = 45 + _random.nextInt(15); // 45-59
        _timeControllers[0].text =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } else {
        // Mùa hè: 07:15-07:29
        final hour = 7;
        final minute = 15 + _random.nextInt(15); // 15-29
        _timeControllers[0].text =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }

      // Thời gian 2: phụ thuộc mùa
      if (_isWinterSeason) {
        // Mùa đông: 12:01-12:29
        final hour = 12;
        final minute = 1 + _random.nextInt(29); // 1-29
        _timeControllers[1].text =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } else {
        // Mùa hè: 11:30-12:29
        // Có thể là 11:30-11:59 hoặc 12:00-12:29
        final isBefore12 = _random.nextBool();
        if (isBefore12) {
          // 11:30-11:59
          final hour = 11;
          final minute = 30 + _random.nextInt(30); // 30-59
          _timeControllers[1].text =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        } else {
          // 12:00-12:29
          final hour = 12;
          final minute = _random.nextInt(30); // 0-29
          _timeControllers[1].text =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        }
      }

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
                      // Date picker button
                      CustomButton(
                        text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                        icon: Icons.calendar_today,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        textColor: theme.colorScheme.onPrimaryContainer,
                        onPressed: _isSubmitting ? null : _showDatePicker,
                      ),
                      const SizedBox(height: 16),

                      // Hàng toggle mùa và random
                      Row(
                        children: [
                          // Nút toggle mùa
                          Expanded(
                            child: CustomButton(
                              text: _isWinterSeason ? 'Mùa đông' : 'Mùa hè',
                              icon: _isWinterSeason
                                  ? Icons.ac_unit
                                  : Icons.wb_sunny,
                              backgroundColor: _isWinterSeason
                                  ? Colors.blue.shade100
                                  : Colors.orange.shade100,
                              textColor: _isWinterSeason
                                  ? Colors.blue.shade900
                                  : Colors.orange.shade900,
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _isWinterSeason = !_isWinterSeason;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Nút random
                          CustomButton(
                            text: '',
                            buttonType: ButtonType.circular,
                            icon: Icons.shuffle,
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            tooltip: 'Random thời gian',
                            onPressed: _isSubmitting ? null : _randomizeTimes,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Time input fields dạng lưới 2x2 với nút xóa
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                            ),
                        itemCount: _timeControllers.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              CustomTextField(
                                controller: _timeControllers[index],
                                label: 'Thời gian ${index + 1}',
                                hint: 'HH:mm',
                                keyboardType: TextInputType.datetime,
                              ),
                              // Nút xóa nhỏ gọn ở góc trên bên phải
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isSubmitting
                                      ? null
                                      : () => _clearTime(index),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
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
                                              'Vui lòng nhập ít nhất một thời gian',
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
