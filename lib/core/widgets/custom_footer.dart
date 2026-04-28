import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Image.asset('assets/images/logoToNCPTKHCN.png', height: 60),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: '© 2025 Bản quyền thuộc về '),
              TextSpan(
                text: 'SAMCOM',
                style: TextStyle(
                  fontWeight: TextConstants.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: TextConstants.small,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Phát triển bởi '),
              TextSpan(
                text: 'Tổ nghiên cứu Phát triển Khoa học Công nghệ.',
                style: TextStyle(
                  fontWeight: TextConstants.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: TextConstants.small,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
