import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/gen/assets.gen.dart';

class AttendanceActionButtons extends StatelessWidget {
  final bool hasRegisteredFace;
  final bool isProcessing;
  final VoidCallback onTakeAttendance;
  final VoidCallback onNavigateToRegisterFace;
  final VoidCallback? onManualAttendance;

  const AttendanceActionButtons({
    super.key,
    required this.hasRegisteredFace,
    required this.isProcessing,
    required this.onTakeAttendance,
    required this.onNavigateToRegisterFace,
    this.onManualAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTooltip = hasRegisteredFace
        ? 'Chấm công (Nhấn giữ để chấm công thủ công)'
        : 'Đăng ký khuôn mặt';

    final primaryIcon = hasRegisteredFace ? Icons.timer : null;
    final primarySvg = hasRegisteredFace ? null : Assets.icon.faceID.path;

    return IntrinsicWidth(
      child: CustomButton(
        text: hasRegisteredFace ? 'CHẤM CÔNG' : 'ĐĂNG KÝ',
        tooltip: primaryTooltip,
        variant: CustomButtonVariant.ctaButton,
        icon: primaryIcon,
        svgPath: primarySvg,
        isLoading: isProcessing,
        onPressed: isProcessing
            ? null
            : (hasRegisteredFace ? onTakeAttendance : onNavigateToRegisterFace),
        onLongPress: hasRegisteredFace ? onManualAttendance : null,
      ),
    );
  }
}
