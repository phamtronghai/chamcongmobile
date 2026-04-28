import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/truc_ban_repository.dart';
import 'package:attendancebyface/core/services/truc_ban_service.dart';
import 'package:attendancebyface/core/services/approver_service.dart';
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
      emit(TrucBanState.error(message: e.toString()));
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
      emit(TrucBanState.error(message: e.toString()));
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
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  /// Lấy lịch sử khách cá nhân
  Future<void> layLichSuKhachCaNhan(DateTime ngay) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.dangKyKhach));
    try {
      final danhSach = await _repository.layLichSuKhachCaNhan(ngay);
      emit(TrucBanState.danhSachKhachLoaded(danhSach: danhSach));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
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
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  // ======== ĐĂNG KÝ RA NGOÀI ========

  /// Đăng ký ra ngoài + gửi thông báo cho trưởng/phó phòng
  Future<void> dangKyRaNgoai({
    required DateTime thoiGianRa,
    required DateTime thoiGianVao,
    required String lyDo,
    String? tenNguoiDangKy,
  }) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.general));
    try {
      await _repository.dangKyRaNgoai(
        thoiGianRa: thoiGianRa,
        thoiGianVao: thoiGianVao,
        lyDo: lyDo,
      );
      emit(const TrucBanState.success(message: 'Đăng ký ra ngoài thành công'));

      // Gửi thông báo cho trưởng/phó phòng (không block UI)
      _guiThongBaoDangKyRaNgoai(
        tenNguoiDangKy: tenNguoiDangKy ?? '',
        thoiGianRa: thoiGianRa,
        thoiGianVao: thoiGianVao,
        lyDo: lyDo,
      );
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
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
      final approverService = ApproverService();
      final managers = await approverService.getDepartmentManagers();
      final service = TrucBanService();

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
      debugPrint('❌ Lỗi gửi thông báo đăng ký ra ngoài: $e');
    }
  }

  /// Lấy lịch sử ra ngoài cá nhân
  Future<void> layLichSuRaNgoaiCaNhan(DateTime ngay) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.raNgoaiCaNhan));
    try {
      final danhSach = await _repository.layLichSuRaNgoaiCaNhan(ngay);
      emit(TrucBanState.danhSachRaNgoaiLoaded(danhSach: danhSach));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  /// Lấy danh sách yêu cầu ra ngoài (cho Lãnh đạo)
  Future<void> layDsYeuCauRaNgoai({
    required DateTime ngay,
    TrangThaiRaNgoai? trangThai,
  }) async {
    emit(const TrucBanState.loading(target: TrucBanLoadTarget.raNgoaiCaNhan));
    try {
      final danhSach = await _repository.layDsYeuCauRaNgoai(
        ngay: ngay,
        trangThai: trangThai,
      );
      emit(TrucBanState.danhSachRaNgoaiLoaded(danhSach: danhSach));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
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
        TrucBanService().guiThongBao(
          userId: userId,
          title: 'Yêu cầu ra ngoài',
          message: 'Yêu cầu ra ngoài của bạn đã được duyệt.',
        );
      }
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
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
        TrucBanService().guiThongBao(
          userId: userId,
          title: 'Yêu cầu ra ngoài',
          message: 'Yêu cầu ra ngoài của bạn đã bị từ chối.',
        );
      }
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
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
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  // ======== TRẠNG THÁI KHÓA ========

  /// Lấy trạng thái khóa
  Future<void> layTrangThaiKhoa() async {
    emit(const TrucBanState.loading());
    try {
      final trangThai = await _repository.layTrangThaiKhoa();
      emit(TrucBanState.trangThaiKhoaLoaded(trangThai: trangThai));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  /// Khóa hệ thống
  Future<void> khoaHeThong() async {
    emit(const TrucBanState.loading());
    try {
      await _repository.khoaHeThong();
      emit(const TrucBanState.success(message: 'Đã khóa hệ thống'));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
    }
  }

  /// Mở khóa hệ thống
  Future<void> moKhoaHeThong() async {
    emit(const TrucBanState.loading());
    try {
      await _repository.moKhoaHeThong();
      emit(const TrucBanState.success(message: 'Đã mở khóa hệ thống'));
    } catch (e) {
      emit(TrucBanState.error(message: e.toString()));
    }
  }
}
