import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/services/admin_service.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/models/admin_org_models.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/screens/attendance/manual_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sheet chi tiết nhân viên (ẩn workName / approval_*).
///
/// Phân vùng: liên hệ → số công → công việc → hành động admin.
class AdminEmployeeSheet {
  static Future<void> show(
    BuildContext context,
    AdminEmployee employee, {
    String? imageUrl,
  }) {
    final subtitleParts = <String>[
      if (employee.position.isNotEmpty) employee.position,
      if (employee.department.isNotEmpty) employee.department,
    ];
    return SamcomSheet.show<void>(
      context: context,
      builder: (_) => SamcomSheet(
        title: employee.name.isEmpty ? 'Nhân viên' : employee.name,
        subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
        leading: _EmployeeAvatar(name: employee.name, imageUrl: imageUrl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _AdminEmployeeSheetBody(
            employee: employee,
            imageUrl: imageUrl,
          ),
        ),
      ),
    );
  }

  static String formatCount(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }
}

class _AdminEmployeeSheetBody extends StatefulWidget {
  final AdminEmployee employee;
  final String? imageUrl;

  const _AdminEmployeeSheetBody({required this.employee, this.imageUrl});

  @override
  State<_AdminEmployeeSheetBody> createState() =>
      _AdminEmployeeSheetBodyState();
}

class _AdminEmployeeSheetBodyState extends State<_AdminEmployeeSheetBody> {
  final AdminService _service = AdminService();
  bool _busy = false;

  AdminEmployee get _employee => widget.employee;

  Future<void> _runBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    CustomSnackbar.show(
      context: context,
      message: message,
      type: error ? CustomSnackbarType.error : CustomSnackbarType.success,
    );
  }

  Future<void> _onResetPassword() async {
    if (_employee.userId.isEmpty) {
      _toast('Không có userId', error: true);
      return;
    }
    final newPassword = await _promptNewPassword();
    if (newPassword == null || newPassword.isEmpty) return;

    await _runBusy(() async {
      try {
        await _service.setUserPassword(
          userId: _employee.userId,
          newPassword: newPassword,
        );
        _toast('Đã đặt lại mật khẩu');
      } catch (_) {
        _toast('Không đặt lại được mật khẩu', error: true);
      }
    });
  }

  Future<String?> _promptNewPassword() {
    return SamcomSheet.show<String>(
      context: context,
      builder: (ctx) {
        return SamcomSheet(
          title: 'Đặt lại mật khẩu',
          subtitle: _employee.name,
          icon: Icons.lock_reset_outlined,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: _ResetPasswordForm(),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteFace() async {
    if (_employee.userId.isEmpty) {
      _toast('Không có userId', error: true);
      return;
    }

    await _runBusy(() async {
      try {
        await _service.deleteFaceId(_employee.userId);
        _toast('Đã xoá khuôn mặt');
      } catch (_) {
        _toast('Không xoá được khuôn mặt', error: true);
      }
    });
  }

  void _onManualAttendance() {
    final loggedInId = context.read<UserCubit>().currentUser?.id ?? '';
    if (loggedInId != kAdminManualAttendanceUserId) {
      _toast('Bạn không có quyền chấm công thủ công', error: true);
      return;
    }
    if (_employee.userId.isEmpty) {
      _toast('Không có userId', error: true);
      return;
    }

    final targetUser = UserModel(
      id: _employee.userId,
      name: _employee.name,
      email: _employee.email,
      image: widget.imageUrl ?? _employee.image ?? '',
      role: '',
      username: '',
      position: _employee.position,
      phone: _employee.phone,
      department: _employee.department,
      departmentSlug: _employee.departmentSlug,
      canApprove: 'nv',
    );

    // Đóng sheet chi tiết rồi mở màn chấm công thủ công.
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => AttendanceCubit(),
          child: ManualAttendanceScreen(user: targetUser),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedInId = context.watch<UserCubit>().currentUser?.id ?? '';
    final canManualAttendance = loggedInId == kAdminManualAttendanceUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactSection(employee: _employee),
        const SizedBox(height: 14),
        _AttendanceStatsSection(employee: _employee),
        const SizedBox(height: 14),
        _WorkCountSection(
          value: AdminEmployeeSheet.formatCount(_employee.workCount),
        ),
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: _busy,
          child: Opacity(
            opacity: _busy ? 0.55 : 1,
            child: _AdminActionsRow(
              canManualAttendance: canManualAttendance,
              onResetPassword: _onResetPassword,
              onDeleteFace: _onDeleteFace,
              onManualAttendance: _onManualAttendance,
            ),
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }
}

class _ResetPasswordForm extends StatefulWidget {
  const _ResetPasswordForm();

  @override
  State<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<_ResetPasswordForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final value = _controller.text.trim();
    if (value.length < 8) {
      CustomSnackbar.show(
        context: context,
        message: 'Mật khẩu phải có ít nhất 8 ký tự',
        type: CustomSnackbarType.error,
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _controller,
          label: 'Mật khẩu mới',
          hint: 'Tối thiểu 8 ký tự',
          fieldType: CustomTextFieldType.password,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 16),
        CustomButton(text: 'Xác nhận', onPressed: _onConfirm),
      ],
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _EmployeeAvatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      child: hasImage
          ? null
          : Text(
              _initials(name),
              style: TextConstants.appTextSemiBold.copyWith(
                color: colorScheme.primary,
              ),
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _ContactSection extends StatelessWidget {
  final AdminEmployee employee;

  const _ContactSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasEmail = employee.email.isNotEmpty;
    final hasPhone =
        employee.phone != null && employee.phone!.trim().isNotEmpty;

    if (!hasEmail && !hasPhone) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasEmail)
              Expanded(
                child: _ContactCell(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: employee.email,
                ),
              ),
            if (hasEmail && hasPhone)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            if (hasPhone)
              Expanded(
                child: _ContactCell(
                  icon: Icons.phone_outlined,
                  label: 'Số điện thoại',
                  value: employee.phone!.trim(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextConstants.appTextMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextConstants.appTextSemiBold.copyWith(
            color: colorScheme.onSurface,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatsSection extends StatelessWidget {
  final AdminEmployee employee;

  const _AttendanceStatsSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final thisMonth = now.month;
    final lastMonth = thisMonth == 1 ? 12 : thisMonth - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số công'.toUpperCase(),
          style: TextConstants.appTextSemiBold.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Năm',
                value: AdminEmployeeSheet.formatCount(employee.countYear),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                label: 'Tháng $lastMonth',
                value: AdminEmployeeSheet.formatCount(employee.countLastMonth),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                label: 'Tháng $thisMonth',
                value: AdminEmployeeSheet.formatCount(employee.countThisMonth),
                emphasize: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _StatTile({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = emphasize
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final valueColor = emphasize ? colorScheme.primary : colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextConstants.appTextBold.copyWith(color: valueColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextConstants.appTextMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkCountSection extends StatelessWidget {
  final String value;

  const _WorkCountSection({required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số lượng công việc',
                  style: TextConstants.appTextMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Trong năm',
                  style: TextConstants.appTextRegular.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextConstants.appTextBold.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionsRow extends StatelessWidget {
  final bool canManualAttendance;
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteFace;
  final VoidCallback onManualAttendance;

  const _AdminActionsRow({
    required this.canManualAttendance,
    required this.onResetPassword,
    required this.onDeleteFace,
    required this.onManualAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionIconButton(
            icon: Icons.lock_reset_outlined,
            label: 'Đặt lại mật khẩu',
            onPressed: onResetPassword,
          ),
        ),
        Expanded(
          child: _ActionIconButton(
            svgPath: 'assets/icon/FaceID.svg',
            label: 'Xoá khuôn mặt',
            onPressed: onDeleteFace,
            accentColor: ColorConstants.errorColor,
          ),
        ),
        if (canManualAttendance)
          Expanded(
            child: _ActionIconButton(
              icon: Icons.timer,
              label: 'Chấm công',
              onPressed: onManualAttendance,
            ),
          ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String label;
  final VoidCallback? onPressed;
  final Color? accentColor;

  const _ActionIconButton({
    this.icon,
    this.svgPath,
    required this.label,
    required this.onPressed,
    this.accentColor,
  }) : assert(icon != null || svgPath != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final color = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.28)
        : accentColor ?? colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          icon: icon,
          svgPath: svgPath,
          variant: CustomButtonVariant.iconButton,
          accentColor: accentColor,
          onPressed: onPressed,
          tooltip: label,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextConstants.appTextMedium.copyWith(
            fontSize: 12,
            color: color,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
