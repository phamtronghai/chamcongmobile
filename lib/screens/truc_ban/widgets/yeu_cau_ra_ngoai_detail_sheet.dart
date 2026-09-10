import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_chip.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/truc_ban_ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sheet chi tiết yêu cầu ra ngoài — phê duyệt / từ chối (giống nghỉ phép).
class YeuCauRaNgoaiDetailSheet extends StatelessWidget {
  final YeuCauRaNgoai yeuCau;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const YeuCauRaNgoaiDetailSheet({
    super.key,
    required this.yeuCau,
    this.onApprove,
    this.onReject,
    this.showActions = true,
  });

  String get _timeLabel {
    final fmt = DateFormat('HH:mm');
    return '${fmt.format(yeuCau.thoiGianRa.toLocal())} - ${fmt.format(yeuCau.thoiGianVao.toLocal())}';
  }

  String get _dateLabel {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(yeuCau.thoiGianRa.toLocal());
  }

  bool get _canAct =>
      showActions &&
      yeuCau.trangThai == TrangThaiRaNgoai.choDuyet &&
      onApprove != null &&
      onReject != null;

  Widget _buildSubtitle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = TrucBanUIHelpers.getTrangThaiColor(yeuCau.trangThai);

    return Row(
      children: [
        Expanded(
          child: Text(
            '$_dateLabel · $_timeLabel',
            style: TextConstants.appTextRegular.copyWith(
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SamcomChip(
          label: yeuCau.trangThai.moTa,
          dense: true,
          fontSize: 12,
          variant: SamcomChipVariant.outlined,
          color: statusColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = colorScheme.onSurface.withValues(alpha: 0.55);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: muted, size: 18),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextConstants.appTextRegular.copyWith(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextConstants.appTextRegular.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = yeuCau.nhanVien?.hoTen.trim().isNotEmpty == true
        ? yeuCau.nhanVien!.hoTen
        : 'N/A';
    final donVi = yeuCau.nhanVien?.donVi.trim() ?? '';

    return SamcomSheet(
      title: name,
      subtitleWidget: _buildSubtitle(context),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (donVi.isNotEmpty) ...[
                    _buildInfoRow(
                      context: context,
                      icon: Icons.business_outlined,
                      title: 'Đơn vị',
                      content: donVi,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildInfoRow(
                    context: context,
                    icon: Icons.access_time,
                    title: 'Thời gian ra ngoài',
                    content: '$_dateLabel · $_timeLabel',
                  ),
                  if (yeuCau.lyDo.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.subject_rounded,
                      title: 'Lý do',
                      content: yeuCau.lyDo.trim(),
                    ),
                  ],
                  if (_canAct) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Từ chối',
                            icon: Icons.close,
                            variant: CustomButtonVariant.normalButton,
                            onPressed: () {
                              Navigator.pop(context);
                              onReject!();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Phê duyệt',
                            icon: Icons.check,
                            onPressed: () {
                              Navigator.pop(context);
                              onApprove!();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
          ],
        ),
      ),
    );
  }
}
