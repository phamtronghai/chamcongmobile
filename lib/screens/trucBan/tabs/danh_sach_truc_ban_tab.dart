import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';

import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';

class DanhSachTrucBanTab extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DanhSachTrucBanTab({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DanhSachTrucBanTab> createState() => _DanhSachTrucBanTabState();
}

class _DanhSachTrucBanTabState extends State<DanhSachTrucBanTab>
    with AutomaticKeepAliveClientMixin {
  bool _isLockStateError(TrucBanState state) {
    if (state is! TrucBanStateError) return false;
    final message = state.message.toLowerCase();
    return message.contains('trạng thái khóa') ||
        message.contains('khoa he thong') ||
        message.contains('khóa hệ thống') ||
        message.contains('mo khoa') ||
        message.contains('mở khóa');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _buildDateHeader(),
        _buildTrucChiHuyBanner(),
        Expanded(
          child: BlocBuilder<TrucBanCubit, TrucBanState>(
            buildWhen: (previous, current) =>
                current is TrucBanStateDanhSachTrucBanLoaded ||
                (current is TrucBanStateLoading &&
                    current.target == TrucBanLoadTarget.dsTrucBan) ||
                (current is TrucBanStateError &&
                    !_isLockStateError(current)),
            builder: (context, state) {
              if (state is TrucBanStateLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TrucBanStateDanhSachTrucBanLoaded) {
                if (state.danhSach.isEmpty) {
                  return const BaseEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'Không có lịch trực ban',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context
                      .read<TrucBanCubit>()
                      .layDanhSachTrucBan(widget.selectedDate),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: state.danhSach.length,
                    itemBuilder: (context, index) {
                      return _buildTrucBanCard(state.danhSach[index]);
                    },
                  ),
                );
              }
              if (state is TrucBanStateError) {
                return BaseEmptyState(
                  icon: Icons.error_outline,
                  title: state.message,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        // Nút mở cửa ở cuối
        _buildMoCuaSection(),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Refresh Chip
          SamcomChip(
            label: '',
            leading: Icon(
              Icons.refresh,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.read<TrucBanCubit>().layDanhSachTrucBan(
              widget.selectedDate,
            ),
            variant: SamcomChipVariant.outlined,
            color: Theme.of(context).dividerColor,
            dense: true,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 160,
            child: DatePickerField(
              compact: true,
              mode: DatePickerFieldMode.single,
              selectedDate: widget.selectedDate,
              dialogTitle: 'Chọn ngày',
              dialogSubtitle: 'Xem danh sách trực ban theo ngày',
              onDateChanged: widget.onDateChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrucChiHuyBanner() {
    return BlocBuilder<TrucBanCubit, TrucBanState>(
      buildWhen: (previous, current) =>
          current is TrucBanStateDanhSachTrucBanLoaded,
      builder: (context, state) {
        if (state is TrucBanStateDanhSachTrucBanLoaded &&
            state.trucChiHuy != null) {
          final chiHuy = state.trucChiHuy!;
          final label = [
            if (chiHuy.capBac != null) chiHuy.capBac,
            chiHuy.hoTen,
          ].join(' ');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorConstants.primaryColor.withAlpha(50),
                ),
              ),
              child: Text(
                'Trực chỉ huy: $label',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMoCuaSection() {
    return Container(
      // Thêm padding dưới lớn để tránh bị navbar che
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.door_sliding_outlined,
                size: 18,
                color: ColorConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Mở cửa',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ô TÔ',
                  icon: Icons.directions_car,
                  backgroundColor: ColorConstants.primaryColor,
                  textColor: Colors.white,
                  height: 56,
                  onPressed: () =>
                      context.read<TrucBanCubit>().moCua(LoaiPhuongTien.oto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'XE KHÁC',
                  icon: Icons.two_wheeler,
                  backgroundColor: ColorConstants.accentColor,
                  textColor: Colors.white,
                  height: 56,
                  onPressed: () =>
                      context.read<TrucBanCubit>().moCua(LoaiPhuongTien.khac),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrucBanCard(TrucBan trucBan) {
    bool isActive = false;
    // Check if shift is active
    if (widget.selectedDate.year == DateTime.now().year &&
        widget.selectedDate.month == DateTime.now().month &&
        widget.selectedDate.day == DateTime.now().day) {
      isActive = _isShiftActive(
        trucBan.thoiGianBatDau,
        trucBan.thoiGianKetThuc,
      );
    }

    return BaseInfoCard(
      title: trucBan.hoTen,
      isActive: isActive,
      onTap: () => _callPhone(trucBan.soDienThoai),
      badge: Text(
        '${trucBan.caTruc}',
        style: TextStyle(
          color: ColorConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: TextConstants.body,
        ),
      ),
      highlightText: '${trucBan.thoiGianBatDau} - ${trucBan.thoiGianKetThuc}',
      detailText: '• ${trucBan.donVi}',
      subInfoWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ColorConstants.successColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              trucBan.soDienThoai,
              style: TextStyle(
                fontSize: TextConstants.caption,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isShiftActive(String start, String end) {
    try {
      final now = DateTime.now();
      // Parse start time
      final startParts = start.split(':');
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      // Parse end time
      final endParts = end.split(':');
      var endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      // Handle overnight shifts (end time < start time)
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      return now.isAfter(startTime) && now.isBefore(endTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  bool get wantKeepAlive => true;
}
