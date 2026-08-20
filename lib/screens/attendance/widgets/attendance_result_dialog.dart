import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_header.dart';
import 'package:attendancebyface/core/app_theme.dart';

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
        ? theme.colorScheme.primary
        : ColorConstants.errorColor;
    final String title = isSuccess ? 'Thành công' : 'Thất bại';
    final IconData icon = isSuccess
        ? Icons.check_circle_rounded
        : Icons.error_rounded;
    final String subtitle = isSuccess
        ? 'Thông tin chấm công đã được ghi nhận'
        : (errorMessage ?? 'Vui lòng thử lại sau');

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SamcomHeader(
            icon: icon,
            title: title,
            subtitle: subtitle,
            primaryColor: primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: isSuccess
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Đóng',
                        variant: CustomButtonVariant.iconButton,
                        icon: Icons.close,
                        tooltip: 'Đóng',
                        onPressed: () {
                          Navigator.of(context).pop();
                          onClose?.call();
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Thử lại',
                          icon: Icons.refresh,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onSecondaryAction?.call();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Đóng',
                        variant: CustomButtonVariant.iconButton,
                        icon: Icons.close,
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
    );
  }
}
