import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/services/citizen_service.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

/// Model để parse dữ liệu QR căn cước công dân
class CitizenIDData {
  final String citizenId; // Số căn cước
  final String oldId; // Số CMT cũ
  final String fullName; // Họ và tên
  final String dateOfBirth; // Ngày tháng năm sinh
  final String gender; // Giới tính
  final String address; // Địa chỉ thường trú
  final String issueDate; // Ngày cấp căn cước

  CitizenIDData({
    required this.citizenId,
    required this.oldId,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.issueDate,
  });

  /// Parse dữ liệu từ QR code căn cước
  factory CitizenIDData.fromQRData(String qrData) {
    final parts = qrData.split('|');

    if (parts.length < 7) {
      throw Exception('Dữ liệu QR không hợp lệ');
    }

    return CitizenIDData(
      citizenId: parts[0].trim(),
      oldId: parts[1].trim(),
      fullName: parts[2].trim(),
      dateOfBirth: parts[3].trim(),
      gender: parts[4].trim(),
      address: parts[5].trim(),
      issueDate: parts[6].trim(),
    );
  }

  /// Format ngày sinh từ DDMMYYYY thành DD/MM/YYYY
  String get formattedDateOfBirth {
    if (dateOfBirth.length == 8) {
      return '${dateOfBirth.substring(0, 2)}/${dateOfBirth.substring(2, 4)}/${dateOfBirth.substring(4, 8)}';
    }
    return dateOfBirth;
  }

  /// Format ngày cấp từ DDMMYYYY thành DD/MM/YYYY
  String get formattedIssueDate {
    if (issueDate.length == 8) {
      return '${issueDate.substring(0, 2)}/${issueDate.substring(2, 4)}/${issueDate.substring(4, 8)}';
    }
    return issueDate;
  }

  /// Format giới tính từ mã số thành text
  String get formattedGender {
    switch (gender.toLowerCase()) {
      case 'nam':
      case '1':
        return 'Nam';
      case 'nữ':
      case '0':
        return 'Nữ';
      default:
        return gender;
    }
  }

  /// Convert to JSON format for API
  Map<String, dynamic> toJson() {
    return {
      'citizenNumber': citizenId,
      'oldIdNumber': oldId,
      'fullName': fullName,
      'dateOfBirth': _formatDateForAPI(dateOfBirth),
      'gender': formattedGender,
      'address': address,
      'issuedDate': _formatDateForAPI(issueDate),
    };
  }

  /// Format ngày từ DDMMYYYY thành YYYY-MM-DD cho API
  String _formatDateForAPI(String dateString) {
    if (dateString.length == 8) {
      final day = dateString.substring(0, 2);
      final month = dateString.substring(2, 4);
      final year = dateString.substring(4, 8);
      return '$year-$month-$day';
    }
    return dateString;
  }
}

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
      final citizenService = CitizenService();
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
    final Color primaryColor = ColorConstants.primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.shadowColor,
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
                            backgroundColor: primaryColor,
                            textColor: Colors.white,
                            onPressed: _handleConfirm,
                            icon: Icons.check,
                            isLoading: _isSubmitting,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          text: 'Đóng',
                          variant: CustomButtonVariant.iconCircle,
                          icon: Icons.close,
                          backgroundColor: primaryColor,
                          textColor: primaryColor,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
