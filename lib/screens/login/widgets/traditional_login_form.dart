import 'package:flutter/material.dart';
import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';

class TraditionalLoginForm extends StatelessWidget {
  final List<OrganizationUnit> units;
  final OrganizationUnit? selectedUnit;
  final ValueChanged<OrganizationUnit?> onUnitChanged;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberAccount;
  final ValueChanged<bool?> onRememberAccountChanged;
  final String? errorMessage;
  final VoidCallback onLoginPressed;
  final bool biometricEnabled;
  final VoidCallback onSwitchToBiometric;

  const TraditionalLoginForm({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.usernameController,
    required this.passwordController,
    required this.rememberAccount,
    required this.onRememberAccountChanged,
    this.errorMessage,
    required this.onLoginPressed,
    required this.biometricEnabled,
    required this.onSwitchToBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chọn đơn vị
        if (units.isNotEmpty) ...[
          CustomDropdown<OrganizationUnit>(
            labelText: 'Chọn đơn vị',
            value: selectedUnit,
            items: units
                .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                .toList(),
            onChanged: onUnitChanged,
            validator: (v) => v == null ? 'Vui lòng chọn đơn vị' : null,
          ),
          const SizedBox(height: 16),
        ],

        // Username field với CustomTextField
        CustomTextField(
          label: 'Tên đăng nhập',
          hint: 'Nhập tên đăng nhập của bạn',
          prefixIcon: Icons.person_outline,
          controller: usernameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên đăng nhập';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password field với CustomTextField
        CustomTextField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu của bạn',
          prefixIcon: Icons.lock_outline,
          fieldType: CustomTextFieldType.password,
          controller: passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

        // Tickbox "Nhớ tài khoản" - căn giữa và hình tròn
        GestureDetector(
          onTap: () {
            onRememberAccountChanged(!rememberAccount);
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: rememberAccount,
                  onChanged: onRememberAccountChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(), // Hình tròn
                ),
                Text(
                  'Nhớ tài khoản',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Error message
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorConstants.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ColorConstants.defaultBorderRadius,
              ),
              border: Border.all(
                color: ColorConstants.errorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              errorMessage!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColorConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (errorMessage != null) const SizedBox(height: 16),

        // Nút đăng nhập chính - full width
        CustomButton(
          text: 'Đăng nhập',
          onPressed: onLoginPressed,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),

        // Text "Đăng nhập bằng sinh trắc học" để quay lại giao diện sinh trắc học
        if (biometricEnabled)
          CustomButton(
            text: 'Đăng nhập bằng sinh trắc học',
            onPressed: onSwitchToBiometric,
            buttonType: ButtonType.circular,
            icon: Icons.arrow_back,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.white,
            tooltip: 'Quay lại đăng nhập sinh trắc học',
          ),
      ],
    );
  }
}
