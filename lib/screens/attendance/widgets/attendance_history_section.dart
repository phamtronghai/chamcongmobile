import 'package:attendancebyface/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_timeline.dart';

/// Timeline lịch sử chấm công: giờ + vị trí (tự resolve địa chỉ).
class AttendanceHistorySection extends StatefulWidget {
  final bool isLoadingRecords;
  final List<AttendanceModel> attendanceRecords;

  const AttendanceHistorySection({
    super.key,
    required this.isLoadingRecords,
    required this.attendanceRecords,
  });

  @override
  State<AttendanceHistorySection> createState() =>
      _AttendanceHistorySectionState();
}

class _AttendanceHistorySectionState extends State<AttendanceHistorySection> {
  final LocationRepository _locationRepository = LocationRepository();
  final Map<String, String> _resolvedAddresses = {};
  final Set<String> _loadingIds = {};
  int _resolveToken = 0;

  @override
  void initState() {
    super.initState();
    _resolveAddresses();
  }

  @override
  void didUpdateWidget(covariant AttendanceHistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.attendanceRecords, widget.attendanceRecords)) {
      _resolveAddresses();
    }
  }

  String _recordKey(AttendanceModel att) {
    if (att.id.isNotEmpty) return att.id;
    return '${att.checkInTime.toIso8601String()}_${att.lat}_${att.long}';
  }

  Future<void> _resolveAddresses() async {
    final token = ++_resolveToken;
    final records = List<AttendanceModel>.from(widget.attendanceRecords);
    final nextLoading = <String>{};

    for (final att in records) {
      final key = _recordKey(att);
      if (_resolvedAddresses.containsKey(key)) continue;
      if (att.location.trim().isNotEmpty) {
        _resolvedAddresses[key] = att.location.trim();
        continue;
      }
      if (att.lat == null || att.long == null) {
        _resolvedAddresses[key] = 'Không có vị trí';
        continue;
      }
      nextLoading.add(key);
    }

    if (!mounted || token != _resolveToken) return;
    setState(() {
      _loadingIds
        ..clear()
        ..addAll(nextLoading);
    });

    if (nextLoading.isEmpty) return;

    await _locationRepository.init();
    await Future.wait(
      records.where((att) => nextLoading.contains(_recordKey(att))).map((
        att,
      ) async {
        final key = _recordKey(att);
        try {
          final address = await _locationRepository.getAddressFromLatLng(
            att.lat!,
            att.long!,
          );
          _resolvedAddresses[key] = (address == null || address.trim().isEmpty)
              ? (att.location.trim().isEmpty
                    ? 'Không lấy được địa chỉ'
                    : att.location)
              : address;
        } catch (_) {
          _resolvedAddresses[key] = att.location.trim().isEmpty
              ? 'Lỗi khi lấy địa chỉ'
              : att.location;
        }
      }),
    );

    if (!mounted || token != _resolveToken) return;
    setState(() => _loadingIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoadingRecords && widget.attendanceRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.attendanceRecords.isEmpty) {
      return const BaseEmptyState();
    }

    final sorted = List<AttendanceModel>.from(widget.attendanceRecords)
      ..sort((a, b) => a.checkInTime.compareTo(b.checkInTime));

    // Slot 1–4: chỉ bản ghi sớm nhất trong mỗi khoảng được gắn số.
    final earliestKeyBySlot = <int, String>{};
    for (final att in sorted) {
      final slot = attendanceSlotNumber(att.checkInTime);
      if (slot == null) continue;
      earliestKeyBySlot.putIfAbsent(slot, () => _recordKey(att));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final att = sorted[index];
        final key = _recordKey(att);
        final isLast = index == sorted.length - 1;
        final timeLabel = DateFormat('HH:mm').format(att.checkInTime);
        final isResolving = _loadingIds.contains(key);
        final location =
            _resolvedAddresses[key] ??
            (att.location.trim().isEmpty ? 'Đang lấy vị trí…' : att.location);
        final slot = attendanceSlotNumber(att.checkInTime);
        final isSlotPrimary = slot != null && earliestKeyBySlot[slot] == key;
        final isDuplicateInSlot = slot != null && !isSlotPrimary;
        // Mốc 3 (12h30–17h): từ 13h trở đi luôn nền đỏ.
        final isLateSlot3 =
            slot == 3 &&
            (att.checkInTime.hour * 60 + att.checkInTime.minute) >= 13 * 60;
        final highlightRed = isDuplicateInSlot || isLateSlot3;

        return AttendanceTimelineTile(
          isLast: isLast,
          slotNumber: isSlotPrimary ? slot : null,
          reserveLeading: true,
          isDuplicateHighlight: highlightRed,
          title: timeLabel,
          child: isResolving
              ? Row(
                  children: [
                    SizedBox(
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đang lấy vị trí…',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: timelineContentStyle(
                          theme,
                          muted: true,
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: timelineContentStyle(theme),
                ),
        );
      },
    );
  }
}
