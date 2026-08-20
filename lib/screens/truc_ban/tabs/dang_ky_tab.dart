import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/truc_ban_sheets.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/lich_su_lists.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/dang_ky_sheet_forms.dart';
import 'package:attendancebyface/core/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<TrucBanCubit, TrucBanState>(
      listener: (context, state) {
        if (state is TrucBanStateSuccess) {
          _reloadHistory();
        }
      },
      child: RefreshIndicator(
        onRefresh: () async => _reloadHistory(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
              if (_kind == _DangKyKind.raNgoai) ...[
                _buildSectionHeader(
                  title: 'Ra ngoài',
                  icon: Icons.directions_walk,
                  onAdd: () => _showDangKyRaNgoaiSheet(context),
                ),
                const SizedBox(height: 12),
                const LichSuRaNgoaiList(),
              ] else ...[
                _buildSectionHeader(
                  title: 'Đăng ký khách',
                  icon: Icons.people_outline,
                  onAdd: () => _showDangKyKhachSheet(context),
                ),
                const SizedBox(height: 12),
                const LichSuKhachList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextConstants.appTextBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        CustomButton(
          text: '',
          icon: Icons.add,
          variant: CustomButtonVariant.iconButton,
          onPressed: onAdd,
          width: 36,
        ),
      ],
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
