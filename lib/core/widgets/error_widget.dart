import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Widget tái sử dụng cho error state
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;
  final String actionText;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.title,
    this.actionText = 'Thử lại',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.error_outline, size: 64, color: ColorConstants.errorColor),
          const SizedBox(height: 16),
          Text(
            (title ?? 'Lỗi khi tải dữ liệu').toUpperCase(),
            style: TextConstants.appTextBold.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorConstants.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextConstants.appTextRegular.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: actionText,
            icon: Icons.refresh,
            width: 180,
            onPressed: onRetry ?? () => context.read<UserCubit>().refresh(),
          ),
        ],
      ),
    );
  }
}
