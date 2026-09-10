import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sheet chi tiết người trực ban + nút gọi.
class TrucBanDetailSheet extends StatelessWidget {
  final TrucBan trucBan;

  const TrucBanDetailSheet({super.key, required this.trucBan});

  String get _timeLabel =>
      '${trucBan.thoiGianBatDau} - ${trucBan.thoiGianKetThuc}';

  Future<void> _callPhone(BuildContext context) async {
    final phone = trucBan.soDienThoai.trim();
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
    final phone = trucBan.soDienThoai.trim();
    final donViParts = <String>[
      if (trucBan.donVi.isNotEmpty) trucBan.donVi,
      if (trucBan.donViCap != null && trucBan.donViCap!.isNotEmpty)
        trucBan.donViCap!,
    ];

    return SamcomSheet(
      icon: Icons.security_outlined,
      title: trucBan.hoTen.isEmpty ? 'Trực ban' : trucBan.hoTen,
      subtitle: 'Ca ${trucBan.caTruc} · $_timeLabel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                _buildInfoRow(
                  context: context,
                  icon: Icons.badge_outlined,
                  title: 'Ca trực',
                  content: '${trucBan.caTruc}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context: context,
                  icon: Icons.schedule_outlined,
                  title: 'Thời gian',
                  content: _timeLabel,
                ),
                if (donViParts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.apartment_outlined,
                    title: 'Đơn vị',
                    content: donViParts.join(' · '),
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Số điện thoại',
                    content: phone,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: phone.isEmpty ? 'Không có số điện thoại' : 'Gọi trực ban',
                    icon: Icons.phone,
                    onPressed: phone.isEmpty ? null : () => _callPhone(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 20),
        ],
      ),
    );
  }
}
