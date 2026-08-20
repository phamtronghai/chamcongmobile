import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';

export 'package:attendancebyface/core/widgets/centered_day_slot_navigator.dart';
export 'package:attendancebyface/screens/attendance/widgets/attendance_history_section.dart';
export 'package:attendancebyface/screens/attendance/widgets/daily_worklogs_section.dart';

/// Header: chào user + vị trí (center), chọn ngày.
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

class _UserLocationHeader extends StatelessWidget {
  final UserModel user;
  final String? locationLabel;
  final VoidCallback? onMapTap;

  const _UserLocationHeader({
    required this.user,
    this.locationLabel,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasLocation =
        locationLabel != null && locationLabel!.trim().isNotEmpty;
    final locationText = hasLocation
        ? locationLabel!.trim()
        : 'Đang lấy vị trí…';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Xin chào, ${user.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextConstants.appTextBold.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: TextConstants.fontSizeApp,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: hasLocation ? onMapTap : null,
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: hasLocation
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    locationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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
        ),
      ],
    );
  }
}
