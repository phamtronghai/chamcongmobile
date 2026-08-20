import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/services/citizen_service.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/models/citizen_id_data.dart';

class CitizenIDFormSheet {
  static Future<void> show(
    BuildContext context, {
    required CitizenIDData citizenData,
    required VoidCallback onClose,
    required VoidCallback onConfirm,
    bool isUpdate = false,
  }) {
    return SamcomSheet.show(
      context: context,
      builder: (_) => SamcomSheet(
        title: isUpdate ? 'Cập nhật căn cước' : 'Thêm căn cước',
        subtitle: 'Xác nhận thông tin từ QR Code',
        icon: Icons.credit_card,
        child: _CitizenIDFormContent(
          citizenData: citizenData,
          onClose: onClose,
          onConfirm: onConfirm,
          isUpdate: isUpdate,
        ),
      ),
    );
  }
}

class _CitizenIDFormContent extends StatefulWidget {
  final CitizenIDData citizenData;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final bool isUpdate;

  const _CitizenIDFormContent({
    required this.citizenData,
    required this.onClose,
    required this.onConfirm,
    required this.isUpdate,
  });

  @override
  State<_CitizenIDFormContent> createState() => _CitizenIDFormContentState();
}

class _CitizenIDFormContentState extends State<_CitizenIDFormContent> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    try {
      final citizenService = locator<CitizenService>();
      await citizenService.init();

      final success = widget.isUpdate
          ? await citizenService.updateCitizenInfo(widget.citizenData)
          : await citizenService.addCitizenInfo(widget.citizenData);

      if (success) {
        if (mounted) {
          context.read<UserCubit>().updateCitizenRegistrationStatus(true);
          CustomSnackbar.show(
            context: context,
            message: widget.isUpdate
                ? 'Đã cập nhật thông tin căn cước thành công!'
                : 'Đã thêm thông tin căn cước thành công!',
            type: CustomSnackbarType.success,
          );
          widget.onConfirm();
        }
      } else {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: widget.isUpdate
                ? 'Cập nhật thông tin căn cước thất bại'
                : 'Thêm thông tin căn cước thất bại',
            type: CustomSnackbarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi cập nhật thông tin: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoCard(context, icon: Icons.badge_outlined, label: 'Số căn cước', value: widget.citizenData.citizenId),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.credit_card_outlined, label: 'Số CMT cũ', value: widget.citizenData.oldId),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.person_outline_rounded, label: 'Họ và tên', value: widget.citizenData.fullName),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.cake_outlined, label: 'Ngày sinh', value: widget.citizenData.formattedDateOfBirth),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.person_outline, label: 'Giới tính', value: widget.citizenData.formattedGender),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.location_on_outlined, label: 'Địa chỉ', value: widget.citizenData.address),
          const SizedBox(height: 12),
          _buildInfoCard(context, icon: Icons.calendar_today_outlined, label: 'Ngày cấp', value: widget.citizenData.formattedIssueDate),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: widget.isUpdate ? 'Cập nhật' : 'Thêm',
                  onPressed: _handleConfirm,
                  icon: Icons.check,
                  isLoading: _isSubmitting,
                ),
              ),
              const SizedBox(width: 12),
              CustomButton(
                text: 'Đóng',
                variant: CustomButtonVariant.iconButton,
                icon: Icons.close,
                tooltip: 'Đóng',
                onPressed: widget.onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextConstants.appTextBold.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextConstants.appTextRegular.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
