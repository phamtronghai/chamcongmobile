import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';

class AttendanceActionButtons extends StatelessWidget {
  final bool hasRegisteredFace;
  final bool isProcessing;
  final VoidCallback onTakeAttendance;
  final VoidCallback onNavigateToRegisterFace;
  final VoidCallback? onManualAttendance;
  final bool hasPermissionViewReport;
  final bool isLoadingReport;
  final VoidCallback onViewReport;

  const AttendanceActionButtons({
    super.key,
    required this.hasRegisteredFace,
    required this.isProcessing,
    required this.onTakeAttendance,
    required this.onNavigateToRegisterFace,
    this.onManualAttendance,
    required this.hasPermissionViewReport,
    required this.isLoadingReport,
    required this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          // Nút chấm công hoặc đăng ký khuôn mặt
          Expanded(
            child: CustomButton(
              text: hasRegisteredFace ? 'CHẤM CÔNG' : 'ĐĂNG KÝ',
              tooltip: hasRegisteredFace
                  ? 'Chấm công (Nhấn giữ để chấm công thủ công)'
                  : 'Đăng ký khuôn mặt',
              backgroundColor: Theme.of(context).colorScheme.primary,
              onPressed: isProcessing
                  ? null
                  : (hasRegisteredFace
                      ? onTakeAttendance
                      : onNavigateToRegisterFace),
              onLongPress: onManualAttendance,
            ),
          ),
          // Nút quân số (nếu có quyền xem báo cáo quân số)
          if (hasPermissionViewReport) ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'QUÂN SỐ',
                tooltip: 'Xem báo cáo quân số',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                textColor: Colors.white,
                fontSize: 14,
                isLoading: isLoadingReport,
                onPressed: isLoadingReport ? null : onViewReport,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
