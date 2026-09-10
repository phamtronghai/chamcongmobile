import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:attendancebyface/core/cubits/truc_ban_cubit.dart';
import 'package:attendancebyface/core/repositories/truc_ban_repository.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/base_info_card.dart';
import 'package:attendancebyface/core/widgets/custom_segmented_button.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/widgets/server_connection_empty_state.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/truc_ban_ui_helpers.dart';
import 'package:attendancebyface/screens/truc_ban/widgets/yeu_cau_ra_ngoai_detail_sheet.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';

class DuyetRaNgoaiTab extends StatefulWidget {
  final DateTime selectedDate;
  /// Chỉ tải / hiện lỗi server khi tab đang được chọn.
  final bool isActive;

  const DuyetRaNgoaiTab({
    super.key,
    required this.selectedDate,
    this.isActive = false,
  });

  @override
  State<DuyetRaNgoaiTab> createState() => _DuyetRaNgoaiTabState();
}

class _DuyetRaNgoaiTabState extends State<DuyetRaNgoaiTab>
    with AutomaticKeepAliveClientMixin {
  final TrucBanRepository _repository = TrucBanRepository();

  List<YeuCauRaNgoai> _items = const [];
  TrangThaiRaNgoai _filter = TrangThaiRaNgoai.choDuyet;
  bool _loading = false;
  bool _hasError = false;
  /// Bỏ qua response cũ khi đổi segment nhanh.
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadForFilter(_filter);
    }
  }

  @override
  void didUpdateWidget(covariant DuyetRaNgoaiTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dateChanged =
        !_isSameDay(oldWidget.selectedDate, widget.selectedDate);
    final becameActive = widget.isActive && !oldWidget.isActive;

    if (widget.isActive && (becameActive || dateChanged)) {
      _loadForFilter(_filter);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Chỉ gọi API đúng [status] đang chọn trên segmented button.
  Future<void> _loadForFilter(TrangThaiRaNgoai status) async {
    if (!mounted) return;
    final token = ++_loadToken;
    setState(() {
      _loading = true;
      _hasError = false;
      if (_filter == status) {
        _items = const [];
      }
    });
    try {
      final list = await _repository.layDsYeuCauRaNgoai(
        ngay: widget.selectedDate,
        trangThai: status,
      );
      if (!mounted || token != _loadToken) return;
      setState(() {
        _items = list;
        _loading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted || token != _loadToken) return;
      setState(() {
        _items = const [];
        _loading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _reloadCurrent() => _loadForFilter(_filter);

  void _onFilterChanged(TrangThaiRaNgoai next) {
    if (next == _filter && !_hasError && !_loading) return;
    setState(() => _filter = next);
    _loadForFilter(next);
  }

  void _showDetailSheet(YeuCauRaNgoai yeuCau) {
    final cubit = context.read<TrucBanCubit>();
    SamcomSheet.show(
      context: context,
      builder: (_) => YeuCauRaNgoaiDetailSheet(
        yeuCau: yeuCau,
        showActions: yeuCau.trangThai == TrangThaiRaNgoai.choDuyet,
        onApprove: () async {
          if (yeuCau.id == null) return;
          await cubit.duyetYeuCau(yeuCau.id!, yeuCau: yeuCau);
          await _reloadCurrent();
        },
        onReject: () async {
          if (yeuCau.id == null) return;
          await cubit.tuChoiYeuCau(yeuCau.id!, yeuCau: yeuCau);
          await _reloadCurrent();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final showServerError = widget.isActive && _hasError && !_loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Center(
            child: CustomSegmentedButton<TrangThaiRaNgoai>(
              options: const [
                CustomSegmentOption(
                  value: TrangThaiRaNgoai.choDuyet,
                  label: 'Chờ duyệt',
                ),
                CustomSegmentOption(
                  value: TrangThaiRaNgoai.daDuyet,
                  label: 'Đã duyệt',
                ),
                CustomSegmentOption(
                  value: TrangThaiRaNgoai.tuChoi,
                  label: 'Từ chối',
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selected) {
                if (selected.isEmpty) return;
                _onFilterChanged(selected.first);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const SizedBox.shrink()
              : showServerError
                  ? ServerConnectionEmptyState(onRefresh: _reloadCurrent)
                  : _items.isEmpty
                      ? RefreshIndicator(
                          onRefresh: _reloadCurrent,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const BaseEmptyState(),
                              SizedBox(
                                height:
                                    fabListBottomPadding(context, fabRows: 0),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _reloadCurrent,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: _items.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _items.length) {
                                return SizedBox(
                                  height: fabListBottomPadding(
                                    context,
                                    fabRows: 0,
                                  ),
                                );
                              }
                              return _DuyetCard(
                                yeuCau: _items[index],
                                onTap: () => _showDetailSheet(_items[index]),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Card tối giản: icon trái — dòng 1 tên, dòng 2 thời gian.
class _DuyetCard extends StatelessWidget {
  final YeuCauRaNgoai yeuCau;
  final VoidCallback onTap;

  const _DuyetCard({required this.yeuCau, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = TrucBanUIHelpers.getTrangThaiColor(yeuCau.trangThai);
    final timeLabel =
        '${DateFormat('HH:mm').format(yeuCau.thoiGianRa.toLocal())} - ${DateFormat('HH:mm').format(yeuCau.thoiGianVao.toLocal())}';

    return BaseInfoCard(
      title: yeuCau.nhanVien?.hoTen ?? 'N/A',
      titleMaxLines: 1,
      badge: Icon(
        TrucBanUIHelpers.getTrangThaiIcon(yeuCau.trangThai),
        color: statusColor,
      ),
      detailText: timeLabel,
      detailMaxLines: 1,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
    );
  }
}
