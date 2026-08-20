import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';

class ProfileUpdateSheet {
  static Future<Map<String, String>?> show(
    BuildContext context, {
    required String initialName,
    String? initialPhone,
  }) {
    return SamcomSheet.show<Map<String, String>>(
      context: context,
      builder: (_) => SamcomSheet(
        title: 'Cập nhật thông tin',
        subtitle: 'Cập nhật họ tên và số điện thoại',
        icon: Icons.person_outline,
        child: _ProfileUpdateForm(
          initialName: initialName,
          initialPhone: initialPhone,
        ),
      ),
    );
  }
}

class _ProfileUpdateForm extends StatefulWidget {
  final String initialName;
  final String? initialPhone;

  const _ProfileUpdateForm({required this.initialName, this.initialPhone});

  @override
  State<_ProfileUpdateForm> createState() => _ProfileUpdateFormState();
}

class _ProfileUpdateFormState extends State<_ProfileUpdateForm> {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': _nameController.text.trim(),
                      'phone': _phoneController.text.trim(),
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              CustomButton(
                text: 'Hủy',
                variant: CustomButtonVariant.iconButton,
                icon: Icons.close,
                tooltip: 'Hủy',
                width: 48,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
