import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';

class ChangePasswordSheet {
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(
      String currentPassword,
      String newPassword,
      bool revokeOtherSessions,
    ) onConfirm,
    VoidCallback? onSuccess,
  }) {
    return SamcomSheet.show(
      context: context,
      builder: (_) => SamcomSheet(
        title: 'Đổi mật khẩu',
        subtitle: 'Cập nhật mật khẩu tài khoản của bạn',
        icon: Icons.lock_reset,
        child: _ChangePasswordForm(onConfirm: onConfirm, onSuccess: onSuccess),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final Future<void> Function(String, String, bool) onConfirm;
  final VoidCallback? onSuccess;

  const _ChangePasswordForm({required this.onConfirm, this.onSuccess});

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (!_validateInputs()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm(
        _currentPasswordController.text,
        _newPasswordController.text,
        false,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess?.call();
      }
    } catch (_) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi đổi mật khẩu',
          type: CustomSnackbarType.error,
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _currentPasswordController,
            fieldType: CustomTextFieldType.password,
            label: 'Mật khẩu hiện tại',
            hint: 'Nhập mật khẩu hiện tại',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _obscureCurrent ? Icons.visibility_off : Icons.visibility,
            onSuffixIconPressed: () =>
                setState(() => _obscureCurrent = !_obscureCurrent),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _newPasswordController,
            fieldType: CustomTextFieldType.password,
            label: 'Mật khẩu mới',
            hint: 'Nhập mật khẩu mới',
            prefixIcon: Icons.lock_outline,
            suffixIcon: _obscureNew ? Icons.visibility_off : Icons.visibility,
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
    );
  }
}
