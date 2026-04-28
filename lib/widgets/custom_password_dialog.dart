import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class CustomPasswordDialog extends StatefulWidget {
  final String title;
  final String label;
  final String hint;
  final void Function(String password)? onConfirm;

  const CustomPasswordDialog({
    super.key,
    this.title = 'Xác nhận mật khẩu',
    this.label = 'Mật khẩu',
    this.hint = 'Nhập mật khẩu',
    this.onConfirm,
  });

  @override
  State<CustomPasswordDialog> createState() => _CustomPasswordDialogState();
}

class _CustomPasswordDialogState extends State<CustomPasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient background
            DialogHeader(
              icon: Icons.lock_outline,
              title: widget.title,
              subtitle: 'Vui lòng nhập mật khẩu để xác nhận',
              primaryColor: primaryColor,
            ),

            // Content section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _controller,
                    fieldType: CustomTextFieldType.password,
                    label: widget.label,
                    hint: widget.hint,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixIconPressed: () =>
                        setState(() => _obscure = !_obscure),
                    onSubmitted: (value) => _onConfirm(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Xác nhận',
                          onPressed: _onConfirm,
                          backgroundColor: primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Hủy',
                        buttonType: ButtonType.circular,
                        icon: Icons.close,
                        backgroundColor: primaryColor,
                        textColor: primaryColor,
                        tooltip: 'Hủy',
                        width: 48,
                        height: 48,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onConfirm() {
    if (widget.onConfirm != null) {
      widget.onConfirm!(_controller.text);
    }
    Navigator.pop(context, _controller.text);
  }
}
