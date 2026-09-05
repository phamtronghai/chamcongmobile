import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';

class KhachDonViTab extends StatefulWidget {
  const KhachDonViTab({super.key});

  @override
  State<KhachDonViTab> createState() => _KhachDonViTabState();
}

class _KhachDonViTabState extends State<KhachDonViTab>
    with AutomaticKeepAliveClientMixin {
  List<Khach>? _danhSach;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<TrucBanCubit>().state;
    if (cubitState is TrucBanStateDanhSachKhachLoaded) {
      _danhSach = cubitState.danhSach;
    }
    _loadData();
  }

  void _loadData() {
    context.read<TrucBanCubit>().layDsKhachToanDonVi(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<TrucBanCubit, TrucBanState>(
      listenWhen: (prev, curr) => curr is TrucBanStateDanhSachKhachLoaded,
      listener: (context, state) {
        if (state is TrucBanStateDanhSachKhachLoaded) {
          setState(() {
            _danhSach = state.danhSach;
          });
        }
      },
      buildWhen: (previous, current) =>
          current is TrucBanStateDanhSachKhachLoaded ||
          (current is TrucBanStateLoading &&
              current.target == TrucBanLoadTarget.dsKhachToanDonVi) ||
          current is TrucBanStateError,
      builder: (context, state) {
        if (state is TrucBanStateLoading && _danhSach == null) {
          return const SizedBox.shrink();
        }
        if (_danhSach != null) {
          if (_danhSach!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  BaseEmptyState(),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _danhSach!.length,
              itemBuilder: (context, index) {
                return _KhachCard(khach: _danhSach![index]);
              },
            ),
          );
        }
        if (state is TrucBanStateError && _danhSach == null) {
          return AppErrorWidget(message: state.message, onRetry: _loadData);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _KhachCard extends StatelessWidget {
  final Khach khach;

  const _KhachCard({required this.khach});

  @override
  Widget build(BuildContext context) {
    IconData badgeIcon = Icons.person;
    if (khach.loaiPhuongTien == LoaiPhuongTien.oto) {
      badgeIcon = Icons.directions_car;
    }

    return BaseInfoCard(
      title: khach.hoTenKhach,
      badge: Icon(
        badgeIcon,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      highlightText: khach.bienSoXe,
      detailText: khach.nguoiDangKy != null
          ? '• Bởi: ${khach.nguoiDangKy!.hoTen}'
          : null,
      subInfoWidget: khach.soCanCuoc.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.successColor,
                borderRadius: BorderRadius.circular(
                  ColorConstants.defaultBorderRadius,
                ),
              ),
              child: Text(
                khach.soCanCuoc,
                style: const TextStyle(
                  color: ColorConstants.backgroundLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
