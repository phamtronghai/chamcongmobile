import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/screens/trucBan/widgets/truc_ban_dialogs.dart';
import 'package:attendancebyface/screens/trucBan/widgets/lich_su_lists.dart';
import 'package:attendancebyface/screens/trucBan/widgets/dang_ky_dialog_forms.dart';
import 'package:attendancebyface/core/widgets/date_picker_field.dart';

class DangKyTab extends StatefulWidget {
  const DangKyTab({super.key});

  @override
  State<DangKyTab> createState() => _DangKyTabState();
}

class _DangKyTabState extends State<DangKyTab>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load history for both sections
    context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(_selectedDate);
    context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<TrucBanCubit, TrucBanState>(
      listener: (context, state) {
        if (state is TrucBanStateSuccess) {
          // Auto-reload lịch sử sau khi đăng ký thành công
          // (Thông báo SnackBar đã được xử lý bởi truc_ban_screen.dart)
          context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(_selectedDate);
          context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDate);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(_selectedDate);
          context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDate);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 180,
                  child: DatePickerField(
                    compact: true,
                    mode: DatePickerFieldMode.single,
                    selectedDate: _selectedDate,
                    dialogTitle: 'Chọn ngày',
                    dialogSubtitle: 'Lọc lịch sử theo ngày',
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                      context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(date);
                      context.read<TrucBanCubit>().layLichSuKhachCaNhan(date);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // --- SECTION 1: RA NGOÀI CÁ NHÂN ---
              _buildSectionHeader(
                title: 'Ra ngoài cá nhân',
                icon: Icons.directions_walk,
                onAdd: () => _showDangKyRaNgoaiDialog(context),
              ),
              const SizedBox(height: 12),
              const LichSuRaNgoaiList(),

              const SizedBox(height: 24),

              // --- SECTION 2: ĐĂNG KÝ KHÁCH ---
              _buildSectionHeader(
                title: 'Đăng ký khách',
                icon: Icons.people_outline,
                onAdd: () => _showDangKyKhachDialog(context),
              ),
              const SizedBox(height: 12),
              const LichSuKhachList(),
              const SizedBox(height: 100),
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
        Icon(icon, color: ColorConstants.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        // Add Button
        CustomButton(
          text: '',
          icon: Icons.add,
          textColor: Theme.of(context).colorScheme.onPrimary,
          variant: CustomButtonVariant.iconCircle,
          backgroundColor: ColorConstants.primaryColor,
          onPressed: onAdd,
          width: 36,
          height: 36,
        ),
      ],
    );
  }

  void _showDangKyRaNgoaiDialog(BuildContext context) {
    final cubit = context.read<TrucBanCubit>();
    TrucBanDialogs.showCustomDialog<TrucBanCubit>(
      context: context,
      title: 'Đăng ký ra ngoài',
      subtitle: 'Nhập thông tin ra ngoài',
      icon: Icons.directions_walk,
      content: const DangKyRaNgoaiDialogForm(),
      blocValue: cubit,
    );
  }

  void _showDangKyKhachDialog(BuildContext context) {
    final cubit = context.read<TrucBanCubit>();
    TrucBanDialogs.showCustomDialog<TrucBanCubit>(
      context: context,
      title: 'Đăng ký khách',
      subtitle: 'Nhập thông tin khách đến',
      icon: Icons.person_add,
      content: const DangKyKhachDialogForm(),
      blocValue: cubit,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
