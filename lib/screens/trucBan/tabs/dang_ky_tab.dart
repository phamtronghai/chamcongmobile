import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/cubits/truc_ban_state.dart';
import 'package:attendancebyface/screens/trucBan/widgets/truc_ban_dialogs.dart';
import 'package:attendancebyface/screens/trucBan/widgets/lich_su_lists.dart';
import 'package:attendancebyface/screens/trucBan/widgets/dang_ky_dialog_forms.dart';
import 'package:attendancebyface/core/widgets/date_picker_dialog.dart';

class DangKyTab extends StatefulWidget {
  const DangKyTab({super.key});

  @override
  State<DangKyTab> createState() => _DangKyTabState();
}

class _DangKyTabState extends State<DangKyTab>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedDateRaNgoai = DateTime.now();
  DateTime _selectedDateKhach = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load history for both sections
    context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(_selectedDateRaNgoai);
    context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDateKhach);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<TrucBanCubit, TrucBanState>(
      listener: (context, state) {
        if (state is TrucBanStateSuccess) {
          // Auto-reload lịch sử sau khi đăng ký thành công
          // (Thông báo SnackBar đã được xử lý bởi truc_ban_screen.dart)
          context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(
            _selectedDateRaNgoai,
          );
          context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDateKhach);
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(
            _selectedDateRaNgoai,
          );
          context.read<TrucBanCubit>().layLichSuKhachCaNhan(_selectedDateKhach);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: RA NGOÀI CÁ NHÂN ---
              _buildSectionHeader(
                title: 'Ra ngoài cá nhân',
                icon: Icons.directions_walk,
                selectedDate: _selectedDateRaNgoai,
                onDateChanged: (date) {
                  setState(() => _selectedDateRaNgoai = date);
                  context.read<TrucBanCubit>().layLichSuRaNgoaiCaNhan(date);
                },
                onAdd: () => _showDangKyRaNgoaiDialog(context),
              ),
              const SizedBox(height: 12),
              const LichSuRaNgoaiList(),

              const SizedBox(height: 24),

              // --- SECTION 2: ĐĂNG KÝ KHÁCH ---
              _buildSectionHeader(
                title: 'Đăng ký khách',
                icon: Icons.people_outline,
                selectedDate: _selectedDateKhach,
                onDateChanged: (date) {
                  setState(() => _selectedDateKhach = date);
                  context.read<TrucBanCubit>().layLichSuKhachCaNhan(date);
                },
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
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
    required VoidCallback onAdd,
  }) {
    final isToday =
        selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;

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
        // Date Chip
        ActionChip(
          label: Text(
            isToday ? 'Hôm nay' : DateFormat('dd/MM').format(selectedDate),
            style: const TextStyle(fontSize: 12),
          ),
          avatar: Icon(
            Icons.calendar_today,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Colors.grey.shade100,
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          labelPadding: const EdgeInsets.only(right: 8),
          onPressed: () {
            AppDatePickerDialog.show(
              context,
              initialDate: selectedDate,
              onDateSelected: onDateChanged,
            );
          },
        ),
        const SizedBox(width: 12),
        // Add Button
        CustomButton(
          text: '',
          icon: Icons.add,
          buttonType: ButtonType.circular,
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

