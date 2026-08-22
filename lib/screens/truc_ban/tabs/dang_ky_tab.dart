import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/truc_ban_sheets.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/lich_su_lists.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/dang_ky_sheet_forms.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';

enum _DangKyKind { raNgoai, khach }

class DangKyTab extends StatefulWidget {
  final DateTime selectedDate;

  const DangKyTab({super.key, required this.selectedDate});

  @override
  State<DangKyTab> createState() => _DangKyTabState();
}

class _DangKyTabState extends State<DangKyTab>
    with AutomaticKeepAliveClientMixin {
  _DangKyKind _kind = _DangKyKind.raNgoai;

  @override
  void initState() {
    super.initState();
    _reloadHistory();
  }

  @override
  void didUpdateWidget(covariant DangKyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _reloadHistory();
    }
  }

  void _reloadHistory() {
    context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(widget.selectedDate);
    context.read<TrucBanCubit>().layLichSuKhachCaNhan(widget.selectedDate);
  }

  void _onDangKyPressed() {
    if (_kind == _DangKyKind.raNgoai) {
      _showDangKyRaNgoaiSheet(context);
    } else {
      _showDangKyKhachSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fabBottomPadding =
        MediaQuery.paddingOf(context).bottom + kFabFilledPillHeight;

    return BlocListener<TrucBanCubit, TrucBanState>(
      listener: (context, state) {
        if (state is TrucBanStateSuccess) {
          _reloadHistory();
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RefreshIndicator(
            onRefresh: () async => _reloadHistory(),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + fabBottomPadding),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CustomSegmentedButton<_DangKyKind>(
                      options: const [
                        CustomSegmentOption(
                          value: _DangKyKind.raNgoai,
                          label: 'Ra ngoài',
                          icon: Icons.directions_walk,
                        ),
                        CustomSegmentOption(
                          value: _DangKyKind.khach,
                          label: 'Đăng ký khách',
                          icon: Icons.people_outline,
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: (selected) {
                        if (selected.isEmpty) return;
                        setState(() => _kind = selected.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_kind == _DangKyKind.raNgoai)
                    const LichSuRaNgoaiList()
                  else
                    const LichSuKhachList(),
                ],
              ),
            ),
          ),
          Positioned(
            right: kNavBarHorizontalPadding,
            bottom: MediaQuery.paddingOf(context).bottom,
            child: IntrinsicWidth(
              child: CustomButton(
                text: 'Đăng ký',
                tooltip: 'Đăng ký',
                variant: CustomButtonVariant.ctaButton,
                icon: Icons.add,
                onPressed: _onDangKyPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDangKyRaNgoaiSheet(BuildContext context) {
    final cubit = context.read<TrucBanCubit>();
    TrucBanSheets.showSheet<TrucBanCubit>(
      context: context,
      title: 'Đăng ký ra ngoài',
      subtitle: 'Nhập thông tin ra ngoài',
      icon: Icons.directions_walk,
      content: const DangKyRaNgoaiSheetForm(),
      blocValue: cubit,
    );
  }

  void _showDangKyKhachSheet(BuildContext context) {
    final cubit = context.read<TrucBanCubit>();
    TrucBanSheets.showSheet<TrucBanCubit>(
      context: context,
      title: 'Đăng ký khách',
      subtitle: 'Nhập thông tin khách đến',
      icon: Icons.person_add,
      content: const DangKyKhachSheetForm(),
      blocValue: cubit,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
