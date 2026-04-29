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

    Widget primaryFab = CustomButton(
      text: hasRegisteredFace ? 'CHẤM CÔNG' : 'ĐĂNG KÝ',
      tooltip: primaryTooltip,
      variant: CustomButtonVariant.iconCircle,
      icon: primaryIcon,
      svgPath: primarySvg,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: isProcessing
          ? null
          : (hasRegisteredFace ? onTakeAttendance : onNavigateToRegisterFace),
      onLongPress: hasRegisteredFace ? onManualAttendance : null,
    );

    if (isProcessing) {
      primaryFab = SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0.35, child: primaryFab),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return primaryFab;
  }
}
