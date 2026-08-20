import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/app_theme.dart';

class ChangePasswordDialog extends StatefulWidget {
  final Function(
    String currentPassword,
    String newPassword,
    bool revokeOtherSessions,
  )
  onConfirm;
  final VoidCallback? onSuccess;

  const ChangePasswordDialog({
    super.key,
    required this.onConfirm,
    this.onSuccess,
  });

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  final bool _revokeOtherSessions = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _onConfirm() async {
    if (_validateInputs()) {
      setState(() => _isLoading = true);

      try {
        await widget.onConfirm(
          _currentPasswordController.text,
          _newPasswordController.text,
          _revokeOtherSessions,
        );

        if (mounted) {
          Navigator.of(context).pop();
          // Gọi callback thành công (để thực hiện đăng xuất)
          widget.onSuccess?.call();
        }
      } catch (e) {
        if (mounted) {
          // Hiển thị thông báo lỗi bằng CustomSnackbar
          CustomSnackbar.show(
            context: context,
            message: 'Lỗi khi đổi mật khẩu',
            type: CustomSnackbarType.error,
          );

          // Đóng dialog
          Navigator.of(context).pop();
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  bool _validateInputs() {
    if (_currentPasswordController.text.isEmpty) {
      _showError('Vui lòng nhập mật khẩu hiện tại');
      return false;
    }

    if (_newPasswordController.text.isEmpty) {
      _showError('Vui lòng nhập mật khẩu mới');
      return false;
    }

    if (_newPasswordController.text.length < 8) {
      _showError('Mật khẩu mới phải có ít nhất 8 ký tự');
      return false;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showError('Mật khẩu mới phải khác mật khẩu hiện tại');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    CustomSnackbar.show(
      context: context,
      message: message,
      type: CustomSnackbarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      child: Container(
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
              DialogHeader(
                icon: Icons.lock_reset,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu tài khoản của bạn',
                primaryColor: primaryColor,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mật khẩu hiện tại
                    CustomTextField(
                      controller: _currentPasswordController,
                      fieldType: CustomTextFieldType.password,
                      label: 'Mật khẩu hiện tại',
                      hint: 'Nhập mật khẩu hiện tại',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureCurrent
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    // Mật khẩu mới
                    CustomTextField(
                      controller: _newPasswordController,
                      fieldType: CustomTextFieldType.password,
                      label: 'Mật khẩu mới',
                      hint: 'Nhập mật khẩu mới',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureNew
                          ? Icons.visibility_off
                          : Icons.visibility,
                      onSuffixIconPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: _isLoading ? 'Đang xử lý...' : 'Đổi mật khẩu',
                      icon: Icons.lock_outline,
                      onPressed: _isLoading ? null : _onConfirm,
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
}
