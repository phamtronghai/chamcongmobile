import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';

import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/screens/attendance/widgets/daily_info_section.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';

class DanhSachTrucBanTab extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback? onShowCamera;

  const DanhSachTrucBanTab({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.onShowCamera,
  });

  @override
  State<DanhSachTrucBanTab> createState() => _DanhSachTrucBanTabState();
}

class _DanhSachTrucBanTabState extends State<DanhSachTrucBanTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            _buildMoCuaSection(),
            _buildDateHeader(),
            _buildTrucChiHuyBanner(),
            Expanded(
              child: BlocBuilder<TrucBanCubit, TrucBanState>(
                buildWhen: (previous, current) =>
                    current is TrucBanStateDanhSachTrucBanLoaded ||
                    (current is TrucBanStateLoading &&
                        current.target == TrucBanLoadTarget.dsTrucBan) ||
                    current is TrucBanStateError,
                builder: (context, state) {
                  if (state is TrucBanStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TrucBanStateDanhSachTrucBanLoaded) {
                    if (state.danhSach.isEmpty) {
                      return const BaseEmptyState();
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
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context
                          .read<TrucBanCubit>()
                          .layDanhSachTrucBan(widget.selectedDate),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        _buildFabStack(),
      ],
    );
  }

  Widget _buildFabStack() {
    return BlocBuilder<TrucBanCubit, TrucBanState>(
      buildWhen: (prev, curr) => curr is TrucBanStatePhanQuyenLoaded,
      builder: (context, state) {
        if (state is! TrucBanStatePhanQuyenLoaded ||
            !state.phanQuyen.canViewCamera ||
            widget.onShowCamera == null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: kNavBarHorizontalPadding,
          bottom: MediaQuery.paddingOf(context).bottom,
          child: CustomButton(
            text: 'Camera',
            tooltip: 'Camera',
            variant: CustomButtonVariant.normalButton,
            icon: Icons.videocam_outlined,
            onPressed: widget.onShowCamera,
          ),
        );
      },
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: CenteredDaySlotNavigator(
        selectedDate: widget.selectedDate,
        onDateSelected: widget.onDateChanged,
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
          final title = [
            if (chiHuy.capBac != null && chiHuy.capBac!.isNotEmpty)
              chiHuy.capBac!,
            chiHuy.hoTen,
          ].join(' ');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                BaseInfoCard(
                  title: title,
                  onTap:
                      (chiHuy.soDienThoai != null &&
                          chiHuy.soDienThoai!.isNotEmpty)
                      ? () => _callPhone(chiHuy.soDienThoai!)
                      : null,
                  badge: Icon(
                    Icons.shield_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  highlightText: 'Trực chỉ huy',
                  highlightBackgroundColor: ColorConstants.errorColor.withAlpha(
                    40,
                  ),
                  highlightTextColor: ColorConstants.errorColor,
                  detailText: chiHuy.donVi?.isNotEmpty == true
                      ? '• ${chiHuy.donVi}'
                      : null,
                  subInfoWidget:
                      (chiHuy.soDienThoai != null &&
                          chiHuy.soDienThoai!.isNotEmpty)
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.errorColor,
                            borderRadius: BorderRadius.circular(
                              ColorConstants.defaultBorderRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: ColorConstants.backgroundLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                chiHuy.soDienThoai!,
                                style: TextStyle(
                                  color: ColorConstants.backgroundLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.25,
                    child: const Divider(height: 10, thickness: 0.5),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMoCuaSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.surface,
      //   border: Border(
      //     bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      //   ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.door_sliding_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('Mở cửa', style: TextConstants.appTextBold),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ô TÔ',
                  icon: Icons.directions_car,
                  variant: CustomButtonVariant.normalButton,
                  onPressed: () =>
                      context.read<TrucBanCubit>().moCua(LoaiPhuongTien.oto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'XE KHÁC',
                  icon: Icons.two_wheeler,
                  variant: CustomButtonVariant.normalButton,
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
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      highlightText: '${trucBan.thoiGianBatDau} - ${trucBan.thoiGianKetThuc}',
      detailText: '• ${trucBan.donVi}',
      subInfoWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ColorConstants.successColor,
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.phone,
              size: 14,
              color: ColorConstants.backgroundLight,
            ),
            const SizedBox(width: 4),
            Text(
              trucBan.soDienThoai,
              style: TextStyle(
                color: ColorConstants.backgroundLight,
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
