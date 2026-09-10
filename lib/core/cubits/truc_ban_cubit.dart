import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/truc_ban_repository.dart';
import 'package:attendancebyface/core/services/truc_ban_service.dart';
import 'package:attendancebyface/core/services/approver_service.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';
import 'truc_ban_state.dart';

/// Cubit quản lý state cho chức năng trực ban
class TrucBanCubit extends Cubit<TrucBanState> {
  final TrucBanRepository _repository;

  /// Cache phân quyền để không phải gọi API nhiều lần
  PhanQuyen? _cachedPhanQuyen;

  TrucBanCubit({TrucBanRepository? repository})
    : _repository = repository ?? TrucBanRepository(),
      super(const TrucBanState.initial());

  /// Getter cho phân quyền đã cache
  PhanQuyen? get phanQuyen => _cachedPhanQuyen;

  String _cleanErrorMessage(dynamic e) {
    var msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring('Exception: '.length);
    }
    return msg;
  }

  // ======== PHÂN QUYỀN ========

  /// Lấy thông tin phân quyền
  Future<void> layPhanQuyen({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPhanQuyen != null) {
      // Nếu đã có cache và không yêu cầu refresh, trả về ngay cache
      emit(TrucBanState.phanQuyenLoaded(phanQuyen: _cachedPhanQuyen!));
      return;
    }

    emit(const TrucBanState.loading(target: TrucBanLoadTarget.general));
    try {
      _cachedPhanQuyen = await _repository.layPhanQuyen();
      emit(TrucBanState.phanQuyenLoaded(phanQuyen: _cachedPhanQuyen!));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  // ======== TRỰC BAN ========

  /// Lấy danh sách trực ban + trực chỉ huy (song song)
  Future<void> layDanhSachTrucBan(DateTime ngay) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.dsTrucBan));
    try {
      final results = await Future.wait([
        _repository.layDanhSachTrucBan(ngay),
        _repository.layTrucChiHuy(ngay),
      ]);
      final danhSach = results[0] as List<TrucBan>;
      final trucChiHuy = results[1] as TrucChiHuy?;
      emit(
        TrucBanState.danhSachTrucBanLoaded(
          danhSach: danhSach,
          trucChiHuy: trucChiHuy,
        ),
      );
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  // ======== ĐĂNG KÝ KHÁCH ========

  /// Đăng ký khách mới
  Future<void> dangKyKhach({
    required String hoTenKhach,
    required String soCanCuoc,
    required String bienSoXe,
    required LoaiPhuongTien loaiPhuongTien,
    required DateTime ngayDangKy,
    String mucDich = '',
    String sdtKhach = '',
  }) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.general));
    try {
      await _repository.dangKyKhach(
        hoTenKhach: hoTenKhach,
        soCanCuoc: soCanCuoc,
        bienSoXe: bienSoXe,
        loaiPhuongTien: loaiPhuongTien,
        ngayDangKy: ngayDangKy,
        mucDich: mucDich,
        sdtKhach: sdtKhach,
      );
      emit(const TrucBanState.success(message: 'Đăng ký khách thành công'));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Lấy lịch sử khách cá nhân
  Future<void> layLichSuKhachCaNhan(DateTime ngay) async {
    debugLog('[TrucBan/Cubit] layLichSuKhachCaNhan START ngay=$ngay');
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.dangKyKhach));
    try {
      final danhSach = await _repository.layLichSuKhachCaNhan(ngay);
      debugLog(
        '[TrucBan/Cubit] layLichSuKhachCaNhan OK → ${danhSach.length} khách',
      );
      emit(TrucBanState.danhSachKhachLoaded(danhSach: danhSach));
    } catch (e, st) {
      debugLog('[TrucBan/Cubit] layLichSuKhachCaNhan FAIL → emit Error: $e');
      debugLog('$st');
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Lấy danh sách khách toàn đơn vị
  Future<void> layDsKhachToanDonVi(DateTime ngay) async {
    emit(
      const TrucBanState.loading(target: TrucBanLoadTarget.dsKhachToanDonVi),
    );
    try {
      final danhSach = await _repository.layDsKhachToanDonVi(ngay);
      emit(TrucBanState.danhSachKhachLoaded(danhSach: danhSach));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  // ======== ĐĂNG KÝ RA NGOÀI ========

  /// Đăng ký ra ngoài + gửi thông báo cho trưởng/phó phòng.
  /// LANH_DAO_PHONG / LANH_DAO: tự gọi API phê duyệt, không cần vào tab Duyệt.
  Future<void> dangKyRaNgoai({
    required DateTime thoiGianRa,
    required DateTime thoiGianVao,
    required String lyDo,
    String? tenNguoiDangKy,
  }) async {
    debugLog(
      '[TrucBan/Cubit] dangKyRaNgoai START '
      'ra=$thoiGianRa vao=$thoiGianVao lyDo=$lyDo',
    );
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.general));
    try {
      if (_cachedPhanQuyen == null) {
        try {
          _cachedPhanQuyen = await _repository.layPhanQuyen();
        } catch (_) {}
      }

      final createdId = await _repository.dangKyRaNgoai(
        thoiGianRa: thoiGianRa,
        thoiGianVao: thoiGianVao,
        lyDo: lyDo,
      );
      debugLog('[TrucBan/Cubit] dangKyRaNgoai API OK id=$createdId');

      final nhom = _cachedPhanQuyen?.nhomQuyen;
      final autoDuyet = nhom == NhomQuyen.lanhDaoPhong ||
          nhom == NhomQuyen.lanhDao;

      if (autoDuyet) {
        final idToApprove = createdId ??
            await _timIdYeuCauChoDuyetMoi(
              ngay: thoiGianRa,
              lyDo: lyDo,
              thoiGianRa: thoiGianRa,
              thoiGianVao: thoiGianVao,
            );
        if (idToApprove != null && idToApprove.isNotEmpty) {
          await _repository.duyetYeuCauRaNgoai(idToApprove);
          debugLog('[TrucBan/Cubit] tự phê duyệt yêu cầu $idToApprove');
          emit(
            const TrucBanState.success(
              message: 'Đăng ký ra ngoài thành công (đã tự phê duyệt)',
            ),
          );
          return;
        }
        debugLog(
          '[TrucBan/Cubit] auto-duyệt: không tìm được id — chỉ đăng ký',
        );
      }

      emit(const TrucBanState.success(message: 'Đăng ký ra ngoài thành công'));

      if (!autoDuyet) {
        _guiThongBaoDangKyRaNgoai(
          tenNguoiDangKy: tenNguoiDangKy ?? '',
          thoiGianRa: thoiGianRa,
          thoiGianVao: thoiGianVao,
          lyDo: lyDo,
        );
      }
    } catch (e, st) {
      debugLog('[TrucBan/Cubit] dangKyRaNgoai FAIL: $e\n$st');
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Fallback: lấy lịch sử cá nhân trong ngày, tìm đơn chờ duyệt khớp vừa tạo.
  Future<String?> _timIdYeuCauChoDuyetMoi({
    required DateTime ngay,
    required String lyDo,
    required DateTime thoiGianRa,
    required DateTime thoiGianVao,
  }) async {
    try {
      final list = await _repository.layLichSuRaNgoaiCaNhan(ngay);
      final pending = list
          .where((e) => e.trangThai == TrangThaiRaNgoai.choDuyet)
          .toList();
      if (pending.isEmpty) return null;

      final lyDoNorm = lyDo.trim();
      final matched = pending.where((e) {
        final sameLyDo = e.lyDo.trim() == lyDoNorm;
        final sameRa = e.thoiGianRa.toLocal().hour == thoiGianRa.hour &&
            e.thoiGianRa.toLocal().minute == thoiGianRa.minute;
        final sameVao = e.thoiGianVao.toLocal().hour == thoiGianVao.hour &&
            e.thoiGianVao.toLocal().minute == thoiGianVao.minute;
        return sameLyDo && sameRa && sameVao;
      });
      if (matched.isNotEmpty) return matched.first.id;

      pending.sort((a, b) {
        final aT = a.thoiGianTao ?? a.thoiGianRa;
        final bT = b.thoiGianTao ?? b.thoiGianRa;
        return bT.compareTo(aT);
      });
      return pending.first.id;
    } catch (e) {
      debugLog('[TrucBan/Cubit] _timIdYeuCauChoDuyetMoi FAIL: $e');
      return null;
    }
  }

  /// Gửi thông báo cho tất cả trưởng/phó phòng khi đăng ký ra ngoài
  Future<void> _guiThongBaoDangKyRaNgoai({
    required String tenNguoiDangKy,
    required DateTime thoiGianRa,
    required DateTime thoiGianVao,
    required String lyDo,
  }) async {
    try {
      final approverService = locator<ApproverService>();
      final managers = await approverService.getDepartmentManagers();
      final service = locator<TrucBanService>();

      final gioRa =
          '${thoiGianRa.hour.toString().padLeft(2, '0')}:${thoiGianRa.minute.toString().padLeft(2, '0')}';
      final gioVao =
          '${thoiGianVao.hour.toString().padLeft(2, '0')}:${thoiGianVao.minute.toString().padLeft(2, '0')}';
      final message =
          'Đ/c $tenNguoiDangKy xin ra ngoài $gioRa-$gioVao. Lý do: $lyDo';

      for (final manager in managers) {
        await service.guiThongBao(
          userId: manager.id,
          title: 'Xin ra ngoài',
          message: message,
        );
      }
    } catch (e) {
      debugLog('❌ Lỗi gửi thông báo đăng ký ra ngoài: $e');
    }
  }

  /// Lấy lịch sử ra ngoài cá nhân
  Future<void> layLichSuRaNgoaiCaNhan(DateTime ngay) async {
    debugLog('[TrucBan/Cubit] layLichSuRaNgoaiCaNhan START ngay=$ngay');
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.raNgoaiCaNhan));
    try {
      final danhSach = await _repository.layLichSuRaNgoaiCaNhan(ngay);
      debugLog(
        '[TrucBan/Cubit] layLichSuRaNgoaiCaNhan OK → ${danhSach.length} yêu cầu',
      );
      emit(TrucBanState.danhSachRaNgoaiLoaded(danhSach: danhSach));
    } catch (e, st) {
      debugLog('[TrucBan/Cubit] layLichSuRaNgoaiCaNhan FAIL → emit Error: $e');
      debugLog('$st');
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Lấy danh sách yêu cầu ra ngoài (cho Lãnh đạo) — 1 trạng thái.
  Future<void> layDsYeuCauRaNgoai({
    required DateTime ngay,
    required TrangThaiRaNgoai trangThai,
  }) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.raNgoaiCaNhan));
    try {
      final danhSach = await _repository.layDsYeuCauRaNgoai(
        ngay: ngay,
        trangThai: trangThai,
      );
      emit(TrucBanState.danhSachRaNgoaiLoaded(danhSach: danhSach));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Lấy DS yêu cầu ra ngoài: gọi song song CHO_DUYET | DA_DUYET | TU_CHOI/TUCHOI.
  Future<void> layDsYeuCauRaNgoaiTatCaTrangThai(DateTime ngay) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.raNgoaiCaNhan));
    try {
      final bundle = await _repository.layDsYeuCauRaNgoaiTatCaTrangThai(ngay);
      emit(TrucBanState.danhSachRaNgoaiLoaded(danhSach: bundle.items));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Duyệt yêu cầu ra ngoài + gửi thông báo cho NV
  Future<void> duyetYeuCau(String id, {YeuCauRaNgoai? yeuCau}) async {
    emit(const TrucBanState.loading());
    try {
      await _repository.duyetYeuCauRaNgoai(id);
      emit(const TrucBanState.success(message: 'Đã duyệt yêu cầu'));

      // Gửi thông báo cho NV
      final userId = yeuCau?.nhanVien?.id;
      if (userId != null && userId.isNotEmpty) {
        locator<TrucBanService>().guiThongBao(
          userId: userId,
          title: 'Yêu cầu ra ngoài',
          message: 'Yêu cầu ra ngoài của bạn đã được duyệt.',
        );
      }
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  /// Từ chối yêu cầu ra ngoài + gửi thông báo cho NV
  Future<void> tuChoiYeuCau(String id, {YeuCauRaNgoai? yeuCau}) async {
    emit(const TrucBanState.loading());
    try {
      await _repository.tuChoiYeuCauRaNgoai(id);
      emit(const TrucBanState.success(message: 'Đã từ chối yêu cầu'));

      // Gửi thông báo cho NV
      final userId = yeuCau?.nhanVien?.id;
      if (userId != null && userId.isNotEmpty) {
        locator<TrucBanService>().guiThongBao(
          userId: userId,
          title: 'Yêu cầu ra ngoài',
          message: 'Yêu cầu ra ngoài của bạn đã bị từ chối.',
        );
      }
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }

  // ======== MỞ CỬA ========

  /// Mở cửa
  Future<void> moCua(LoaiPhuongTien loaiPhuongTien) async {
    emit(const TrucBanState.loading());
    try {
      await _repository.moCua(loaiPhuongTien);
      emit(const TrucBanState.success(message: 'Mở cửa thành công'));
    } catch (e) {
      emit(TrucBanState.error(message: _cleanErrorMessage(e)));
    }
  }
}
