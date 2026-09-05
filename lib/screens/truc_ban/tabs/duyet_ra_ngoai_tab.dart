import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';

class DuyetRaNgoaiTab extends StatefulWidget {
  const DuyetRaNgoaiTab({super.key});

  @override
  State<DuyetRaNgoaiTab> createState() => _DuyetRaNgoaiTabState();
}

class _DuyetRaNgoaiTabState extends State<DuyetRaNgoaiTab>
    with AutomaticKeepAliveClientMixin {
  List<YeuCauRaNgoai>? _danhSach;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<TrucBanCubit>().state;
    if (cubitState is TrucBanStateDanhSachRaNgoaiLoaded) {
      _danhSach = cubitState.danhSach;
    }
    _loadData();
  }

  void _loadData() {
    context.read<TrucBanCubit>().layDsYeuCauRaNgoai(
          ngay: DateTime.now(),
          trangThai: TrangThaiRaNgoai.choDuyet,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<TrucBanCubit, TrucBanState>(
      listenWhen: (prev, curr) => curr is TrucBanStateDanhSachRaNgoaiLoaded,
      listener: (context, state) {
        if (state is TrucBanStateDanhSachRaNgoaiLoaded) {
          setState(() {
            _danhSach = state.danhSach;
          });
        }
      },
      buildWhen: (previous, current) =>
          current is TrucBanStateDanhSachRaNgoaiLoaded ||
          (current is TrucBanStateLoading &&
              current.target == TrucBanLoadTarget.raNgoaiCaNhan) ||
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
                return _DuyetCard(yeuCau: _danhSach![index]);
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

class _DuyetCard extends StatelessWidget {
  final YeuCauRaNgoai yeuCau;

  const _DuyetCard({required this.yeuCau});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrucBanCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(yeuCau.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                if (yeuCau.id != null) {
                  await cubit.tuChoiYeuCau(yeuCau.id!, yeuCau: yeuCau);
                  cubit.layDsYeuCauRaNgoai(
                    ngay: DateTime.now(),
                    trangThai: TrangThaiRaNgoai.choDuyet,
                  );
                }
              },
              foregroundColor: ColorConstants.errorColor,
              icon: Icons.close,
              label: 'Từ chối',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(ColorConstants.defaultBorderRadius),
              ),
            ),
            SlidableAction(
              onPressed: (_) async {
                if (yeuCau.id != null) {
                  await cubit.duyetYeuCau(yeuCau.id!, yeuCau: yeuCau);
                  cubit.layDsYeuCauRaNgoai(
                    ngay: DateTime.now(),
                    trangThai: TrangThaiRaNgoai.choDuyet,
                  );
                }
              },
              foregroundColor: ColorConstants.successColor,
              icon: Icons.check,
              label: 'Duyệt',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(ColorConstants.defaultBorderRadius),
              ),
            ),
          ],
        ),
        child: BaseInfoCard(
          title: yeuCau.nhanVien?.hoTen ?? 'N/A',
          badge: const Icon(Icons.person, color: ColorConstants.infoColor),
          highlightText: yeuCau.nhanVien?.donVi,
          detailText: yeuCau.lyDo,
          detailMaxLines: 2,
          margin: EdgeInsets.zero,
          subInfoWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorConstants.successColor.withAlpha(25),
              borderRadius: BorderRadius.circular(
                ColorConstants.defaultBorderRadius,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: ColorConstants.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(yeuCau.thoiGianRa)} - ${DateFormat('HH:mm').format(yeuCau.thoiGianVao)}',
                  style: const TextStyle(
                    color: ColorConstants.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
