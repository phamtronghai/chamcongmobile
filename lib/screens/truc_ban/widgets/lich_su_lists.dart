import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/truc_ban_ui_helpers.dart';

class LichSuRaNgoaiList extends StatelessWidget {
  const LichSuRaNgoaiList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrucBanCubit, TrucBanState>(
      buildWhen: (previous, current) =>
          current is TrucBanStateDanhSachRaNgoaiLoaded ||
          (current is TrucBanStateLoading &&
              current.target == TrucBanLoadTarget.raNgoaiCaNhan),
      builder: (context, state) {
        if (state is TrucBanStateDanhSachRaNgoaiLoaded) {
          if (state.danhSach.isEmpty) {
            return const BaseEmptyState();
          }
          return Column(
            children: state.danhSach.map((yeuCau) {
              final color = TrucBanUIHelpers.getTrangThaiColor(
                yeuCau.trangThai,
              );
              final icon = TrucBanUIHelpers.getTrangThaiIcon(yeuCau.trangThai);

              return BaseInfoCard(
                title: yeuCau.lyDo,
                badge: Icon(icon, size: 20, color: color),
                highlightText:
                    '${DateFormat('HH:mm').format(yeuCau.thoiGianRa.toLocal())} - ${DateFormat('HH:mm').format(yeuCau.thoiGianVao.toLocal())}',
                subInfoWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                  ),
                  child: Text(
                    yeuCau.trangThai.moTa,
                    style: TextStyle(
                      fontSize: TextConstants.fontSizeApp,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
        if (state is TrucBanStateLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class LichSuKhachList extends StatelessWidget {
  const LichSuKhachList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrucBanCubit, TrucBanState>(
      buildWhen: (previous, current) =>
          current is TrucBanStateDanhSachKhachLoaded ||
          (current is TrucBanStateLoading &&
              current.target == TrucBanLoadTarget.dangKyKhach),
      builder: (context, state) {
        if (state is TrucBanStateDanhSachKhachLoaded) {
          if (state.danhSach.isEmpty) {
            return const BaseEmptyState();
          }
          return Column(
            children: state.danhSach.map((khach) {
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
                subInfoWidget: khach.soCanCuoc.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConstants.successColor,
                          borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                        ),
                        child: Text(
                          khach.soCanCuoc,
                          style: const TextStyle(
                            fontSize: TextConstants.fontSizeApp,
                            color: ColorConstants.backgroundLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                detailText: khach.ngayDangKy,
              );
            }).toList(),
          );
        }
        if (state is TrucBanStateLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
