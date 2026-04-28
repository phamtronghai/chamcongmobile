import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class SecurityAlertDialog extends StatelessWidget {
  final String message;

  const SecurityAlertDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              icon: Icons.security_outlined,
              title: 'Thiết bị không an toàn',
              subtitle: 'Cảnh báo bảo mật hệ thống',
              primaryColor: theme.colorScheme.error,
            ),

            // Content
            _buildContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Main message
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Close button
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return CustomButton(
      text: 'Đóng ứng dụng',
      backgroundColor: Colors.red,
      textColor: Colors.white,
      icon: Icons.close,
      onPressed: () {
        // Thoát ứng dụng
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
    );
  }

  /// Static method để hiển thị dialog
  static Future<void> show({
    required BuildContext context,
    required String message,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách nhấn bên ngoài
      builder: (BuildContext context) {
        return SecurityAlertDialog(message: message);
      },
    );
  }
}
