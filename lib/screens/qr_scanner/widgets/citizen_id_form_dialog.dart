import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/services/citizen_service.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/models/citizen_id_data.dart';

class CitizenIDFormDialog extends StatefulWidget {
  final CitizenIDData citizenData;
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final bool isUpdate; // true nếu là cập nhật, false nếu là thêm mới

  const CitizenIDFormDialog({
    super.key,
    required this.citizenData,
    required this.onClose,
    required this.onConfirm,
    this.isUpdate = false,
  });

  @override
  State<CitizenIDFormDialog> createState() => _CitizenIDFormDialogState();
}

class _CitizenIDFormDialogState extends State<CitizenIDFormDialog> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Import CitizenService
      final citizenService = locator<CitizenService>();
      await citizenService.init();

      final success = widget.isUpdate
          ? await citizenService.updateCitizenInfo(widget.citizenData)
          : await citizenService.addCitizenInfo(widget.citizenData);

      if (success) {
        if (mounted) {
          // Cập nhật UserCubit
          context.read<UserCubit>().updateCitizenRegistrationStatus(true);

          CustomSnackbar.show(
            context: context,
            message: widget.isUpdate
                ? 'Đã cập nhật thông tin căn cước thành công!'
                : 'Đã thêm thông tin căn cước thành công!',
            type: CustomSnackbarType.success,
          );
          // Chỉ gọi callback, không tự đóng dialog
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
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.backgroundDark.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header với gradient background
              DialogHeader(
                icon: Icons.credit_card,
                title: widget.isUpdate ? 'CẬP NHẬT CĂN CƯỚC' : 'THÊM CĂN CƯỚC',
                subtitle: 'Xác nhận thông tin từ QR Code',
                primaryColor: primaryColor,
              ),

              // Content section
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Info Cards
                    _buildInfoCard(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'Số căn cước',
                      value: widget.citizenData.citizenId,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.credit_card_outlined,
                      label: 'Số CMT cũ',
                      value: widget.citizenData.oldId,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: 'Họ và tên',
                      value: widget.citizenData.fullName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.cake_outlined,
                      label: 'Ngày sinh',
                      value: widget.citizenData.formattedDateOfBirth,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.person_outline,
                      label: 'Giới tính',
                      value: widget.citizenData.formattedGender,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Địa chỉ',
                      value: widget.citizenData.address,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Ngày cấp',
                      value: widget.citizenData.formattedIssueDate,
                    ),

                    const SizedBox(height: 20),
                    // Hàng nút hành động: Xác nhận + nút Đóng (icon)
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
                          onPressed: () {
                            // Chỉ gọi callback, không tự đóng dialog
                            widget.onClose();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextConstants.appTextBold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextConstants.appTextRegular.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
