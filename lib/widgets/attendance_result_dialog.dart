import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class AttendanceResultDialog extends StatelessWidget {
  final bool isSuccess;
  final String? errorMessage;
  final VoidCallback? onClose;
  final VoidCallback? onSecondaryAction;

  const AttendanceResultDialog({
    super.key,
    required this.isSuccess,
    this.errorMessage,
    this.onClose,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = isSuccess
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final String title = isSuccess ? 'Thành công' : 'Thất bại';
    final IconData icon = isSuccess
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    final String subtitle = isSuccess
        ? 'Thông tin chấm công đã được ghi nhận'
        : (errorMessage ?? 'Vui lòng thử lại sau');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
              icon: icon,
              title: title,
              subtitle: subtitle,
              primaryColor: primaryColor,
            ),

            // Content section
            Container(
              padding: const EdgeInsets.all(24),
              child: isSuccess
                  ? // Nếu thành công: chỉ hiển thị nút Đóng
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'Đóng',
                          buttonType: ButtonType.circular,
                          icon: Icons.close,
                          backgroundColor: primaryColor,
                          textColor: primaryColor,
                          tooltip: 'Đóng',
                          onPressed: () {
                            Navigator.of(context).pop();
                            onClose?.call();
                          },
                        ),
                      ],
                    )
                  : // Nếu thất bại: hiển thị nút Thử lại và Đóng
                    Row(
                children: [
                  Expanded(
                    child: CustomButton(
                            text: 'Thử lại',
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSecondaryAction?.call();
                      },
                      backgroundColor: primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    text: 'Đóng',
                    buttonType: ButtonType.circular,
                    icon: Icons.close,
                    backgroundColor: primaryColor,
                    textColor: primaryColor,
                    tooltip: 'Đóng',
                    onPressed: () {
                      Navigator.of(context).pop();
                      onClose?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
