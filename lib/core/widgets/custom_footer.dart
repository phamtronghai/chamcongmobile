import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_config.dart';
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
        Image.asset(
          AppConfig.logoOrg,
          height: AppConfig.sizeLogoApp,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '© ${DateTime.now().year}. Bản quyền thuộc về '),
              TextSpan(
                text: 'SAMCOM',
                style: TextConstants.appTextBold.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            style: TextConstants.appTextRegular.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
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
                text: 'Tổ nghiên cứu phát triển khoa học công nghệ',
                style: TextConstants.appTextBold.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
            style: TextConstants.appTextRegular.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
