import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';

class CustomPasswordSheet {
  static Future<String?> show(
    BuildContext context, {
    String title = 'Xác nhận mật khẩu',
    String label = 'Mật khẩu',
    String hint = 'Nhập mật khẩu',
    void Function(String password)? onConfirm,
  }) {
    return SamcomSheet.show<String>(
      context: context,
      builder: (_) => SamcomSheet(
        title: title,
        subtitle: 'Vui lòng nhập mật khẩu để xác nhận',
        icon: Icons.lock_outline,
        child: _PasswordForm(label: label, hint: hint, onConfirm: onConfirm),
      ),
    );
  }
}

class _PasswordForm extends StatefulWidget {
  final String label;
  final String hint;
  final void Function(String)? onConfirm;

  const _PasswordForm({required this.label, required this.hint, this.onConfirm});

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    widget.onConfirm?.call(_controller.text);
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _controller,
            fieldType: CustomTextFieldType.password,
            label: widget.label,
            hint: widget.hint,
            prefixIcon: Icons.lock_outline,
            suffixIcon: _obscure ? Icons.visibility_off : Icons.visibility,
            onSuffixIconPressed: () => setState(() => _obscure = !_obscure),
            onSubmitted: (_) => _onConfirm(),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Xác nhận',
            icon: Icons.check,
            onPressed: _onConfirm,
          ),
        ],
      ),
    );
  }
}
