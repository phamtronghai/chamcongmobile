import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';

export 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';
export 'package:attendancebyface/screens/attendance/widgets/attendance_history_section.dart';
export 'package:attendancebyface/screens/attendance/widgets/daily_worklogs_section.dart';

/// Header chung: avatar + tên + vị trí, chọn ngày.
class DailyInfoSection extends StatelessWidget {
  final UserModel user;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? locationLabel;
  final VoidCallback? onMapTap;

  const DailyInfoSection({
    super.key,
    required this.user,
    required this.selectedDate,
    required this.onDateSelected,
    this.locationLabel,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _UserLocationHeader(
            user: user,
            locationLabel: locationLabel,
            onMapTap: onMapTap,
          ),
          const SizedBox(height: 10),
          CenteredDaySlotNavigator(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
        ],
      ),
    );
  }
}

/// Row trái: avatar (GradientAvatarRing); phải: tên (title) + vị trí (subtitle).
class _UserLocationHeader extends StatelessWidget {
  final UserModel user;
  final String? locationLabel;
  final VoidCallback? onMapTap;

  const _UserLocationHeader({
    required this.user,
    this.locationLabel,
    this.onMapTap,
  });

  static const double _avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasLocation =
        locationLabel != null && locationLabel!.trim().isNotEmpty;
    final locationText = hasLocation
        ? locationLabel!.trim()
        : 'Đang lấy vị trí…';

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientAvatarRing(
            size: _avatarSize,
            outerPadding: 2.5,
            innerPadding: 1.5,
            child: CircleAvatar(
              radius: (_avatarSize / 2) - 4,
              backgroundColor: colorScheme.surface,
              backgroundImage: user.image.isNotEmpty
                  ? NetworkImage(user.image)
                  : null,
              child: user.image.isEmpty
                  ? Icon(
                      Icons.account_circle,
                      size: 28,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextConstants.appTextBold.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: TextConstants.fontSizeApp,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: hasLocation ? onMapTap : null,
                  borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: hasLocation
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextConstants.appTextRegular.copyWith(
                            fontSize: TextConstants.fontSizeApp,
                            fontWeight: FontWeight.w500,
                            color: hasLocation
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
