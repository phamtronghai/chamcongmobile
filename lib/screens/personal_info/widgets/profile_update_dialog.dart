import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class ProfileUpdateDialog extends StatefulWidget {
  final String initialName;
  final String? initialPhone;

  const ProfileUpdateDialog({
    super.key,
    required this.initialName,
    this.initialPhone,
  });

  @override
  State<ProfileUpdateDialog> createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
              icon: Icons.person_outline,
              title: 'Cập nhật thông tin',
              subtitle: 'Cập nhật họ tên và số điện thoại',
              primaryColor: primaryColor,
            ),

            // Content section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Họ và tên',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    fieldType: CustomTextFieldType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cập nhật',
                          onPressed: () {
                            Navigator.pop(context, {
                              'name': _nameController.text.trim(),
                              'phone': _phoneController.text.trim(),
                            });
                          },
                          backgroundColor: primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Hủy',
                        variant: CustomButtonVariant.iconCircle,
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
}
