import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';

enum _QuickAction { oto, khac, camera }

class DanhSachTrucBanTab extends StatefulWidget {
  final DateTime selectedDate;

  const DanhSachTrucBanTab({super.key, required this.selectedDate});

  @override
  State<DanhSachTrucBanTab> createState() => _DanhSachTrucBanTabState();
}

class _DanhSachTrucBanTabState extends State<DanhSachTrucBanTab>
    with AutomaticKeepAliveClientMixin {
  _QuickAction? _quickAction;
  List<TrucBan>? _danhSach;
  TrucChiHuy? _trucChiHuy;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<TrucBanCubit>().state;
    if (cubitState is TrucBanStateDanhSachTrucBanLoaded) {
      _danhSach = cubitState.danhSach;
      _trucChiHuy = cubitState.trucChiHuy;
    }
  }

  @override
  void didUpdateWidget(covariant DanhSachTrucBanTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _danhSach = null;
        _trucChiHuy = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        BlocBuilder<TrucBanCubit, TrucBanState>(
          buildWhen: (prev, curr) => curr is TrucBanStatePhanQuyenLoaded,
          builder: (context, state) {
            final canViewCamera =
                context.read<TrucBanCubit>().phanQuyen?.canViewCamera == true;
            return _buildQuickActionBar(canViewCamera: canViewCamera);
          },
        ),
        _buildSectionTitle('Trực chỉ huy'),
        _buildTrucChiHuyBanner(),
        _buildSectionTitle('Danh sách trực ban'),
        Expanded(
          child: BlocConsumer<TrucBanCubit, TrucBanState>(
            listenWhen: (prev, curr) =>
                curr is TrucBanStateDanhSachTrucBanLoaded,
            listener: (context, state) {
              if (state is TrucBanStateDanhSachTrucBanLoaded) {
                setState(() {
                  _danhSach = state.danhSach;
                  _trucChiHuy = state.trucChiHuy;
                });
              }
            },
            buildWhen: (previous, current) =>
                current is TrucBanStateDanhSachTrucBanLoaded ||
                (current is TrucBanStateLoading &&
                    current.target == TrucBanLoadTarget.dsTrucBan) ||
                current is TrucBanStateError,
            builder: (context, state) {
              if (state is TrucBanStateLoading && _danhSach == null) {
                return const SizedBox.shrink();
              }
              if (_danhSach != null) {
                if (_danhSach!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<TrucBanCubit>()
                        .layDanhSachTrucBan(widget.selectedDate),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [BaseEmptyState()],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context
                      .read<TrucBanCubit>()
                      .layDanhSachTrucBan(widget.selectedDate),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    itemCount: _danhSach!.length,
                    itemBuilder: (context, index) {
                      return _buildTrucBanCard(_danhSach![index]);
                    },
                  ),
                );
              }
              if (state is TrucBanStateError && _danhSach == null) {
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
    );
  }

  Widget _buildQuickActionBar({required bool canViewCamera}) {
    final options = [
      const CustomSegmentOption(
        value: _QuickAction.oto,
        label: 'Ô tô',
        icon: Icons.directions_car,
      ),
      const CustomSegmentOption(
        value: _QuickAction.khac,
        label: 'Xe khác',
        icon: Icons.two_wheeler,
      ),
      if (canViewCamera)
        const CustomSegmentOption(
          value: _QuickAction.camera,
          label: 'Camera',
          icon: Icons.videocam_outlined,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: CustomSegmentedButton<_QuickAction>(
        options: options,
        selected: _quickAction == null ? {} : {_quickAction!},
        emptySelectionAllowed: true,
        onSelectionChanged: (selected) {
          if (selected.isEmpty) return;
          final action = selected.first;
          final cubit = context.read<TrucBanCubit>();
          switch (action) {
            case _QuickAction.oto:
              cubit.moCua(LoaiPhuongTien.oto);
            case _QuickAction.khac:
              cubit.moCua(LoaiPhuongTien.khac);
            case _QuickAction.camera:
              AppRouter.goToCameraRtsp(context);
          }
          setState(() => _quickAction = null);
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextConstants.appTextBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTrucChiHuyBanner() {
    if (_trucChiHuy != null) {
      final chiHuy = _trucChiHuy!;
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
                            style: const TextStyle(
                              color: ColorConstants.backgroundLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            const Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.25,
                child: Divider(height: 10, thickness: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_danhSach != null && _trucChiHuy == null) {
      return const BaseEmptyState();
    }

    return const SizedBox.shrink();
  }

  Widget _buildTrucBanCard(TrucBan trucBan) {
    var isActive = false;
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
              style: const TextStyle(
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
      final startParts = start.split(':');
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      final endParts = end.split(':');
      var endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      return now.isAfter(startTime) && now.isBefore(endTime);
    } catch (_) {
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
