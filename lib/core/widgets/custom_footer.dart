import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_theme.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.7);
    final primary = Theme.of(context).colorScheme.primary;
    final mutedStyle = TextConstants.appTextRegular.copyWith(
      color: muted,
      fontSize: 10,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(AppConfig.logoOrg, height: 48, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Phát triển bởi', style: mutedStyle),
                Text(
                  'Tổ nghiên cứu phát triển khoa học công nghệ',
                  style: TextConstants.appTextBold.copyWith(
                    color: primary,
                    fontSize: 10,
                  ),
                ),
                Text('©${DateTime.now().year}. SAMCOM', style: mutedStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
