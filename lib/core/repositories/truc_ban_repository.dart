import 'package:attendancebyface/core/services/truc_ban_service.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';

/// Repository xử lý logic nghiệp vụ cho chức năng trực ban
class TrucBanRepository {
  final TrucBanService _service;

  TrucBanRepository({TrucBanService? service})
    : _service = service ?? TrucBanService();

  // ======== PHÂN QUYỀN ========

  /// Lấy thông tin phân quyền
  Future<PhanQuyen> layPhanQuyen() => _service.xacDinhNhomNguoiDung();

  // ======== TRỰC BAN ========

  /// Lấy danh sách trực ban theo ngày
  Future<List<TrucBan>> layDanhSachTrucBan(DateTime ngay) {
    final ngayStr = _formatDate(ngay);
    return _service.layDanhSachTrucBan(ngayStr);
  }

  /// Lấy thông tin trực chỉ huy theo ngày
  Future<TrucChiHuy?> layTrucChiHuy(DateTime ngay) {
    final ngayStr = _formatDate(ngay);
    return _service.layTrucChiHuy(ngayStr);
  }

  // ======== ĐĂNG KÝ KHÁCH ========

  /// Đăng ký khách mới
  Future<bool> dangKyKhach({
    required String hoTenKhach,
    required String soCanCuoc,
    required String bienSoXe,
    required LoaiPhuongTien loaiPhuongTien,
    required DateTime ngayDangKy,
    String mucDich = '',
    String sdtKhach = '',
  }) {
    final khach = Khach(
      hoTenKhach: hoTenKhach,
      soCanCuoc: soCanCuoc,
      bienSoXe: bienSoXe,
      loaiPhuongTien: loaiPhuongTien,
      ngayDangKy: _formatDate(ngayDangKy),
      mucDich: mucDich,
      sdtKhach: sdtKhach,
    );
    return _service.dangKyKhach(khach);
  }

  /// Lấy lịch sử khách cá nhân
  Future<List<Khach>> layLichSuKhachCaNhan(DateTime ngay) {
    final ngayStr = _formatDate(ngay);
    return _service.xemLichSuKhachCaNhan(ngayStr);
  }

  /// Lấy danh sách khách toàn đơn vị (cho Trực ban & Lãnh đạo)
  Future<List<Khach>> layDsKhachToanDonVi(DateTime ngay) {
    final ngayStr = _formatDate(ngay);
    return _service.dsKhachToanDonVi(ngayStr);
  }

  // ======== ĐĂNG KÝ RA NGOÀI ========

  /// Đăng ký ra ngoài
  Future<bool> dangKyRaNgoai({
    required DateTime thoiGianRa,
    required DateTime thoiGianVao,
    required String lyDo,
  }) {
    final yeuCau = YeuCauRaNgoai(
      thoiGianRa: thoiGianRa,
      thoiGianVao: thoiGianVao,
      lyDo: lyDo,
    );
    return _service.dangKyRaNgoai(yeuCau);
  }

  /// Lấy lịch sử ra ngoài cá nhân
  Future<List<YeuCauRaNgoai>> layLichSuRaNgoaiCaNhan(DateTime ngay) {
    final ngayStr = _formatDate(ngay);
    return _service.lichSuRaNgoaiCaNhan(ngayStr);
  }

  /// Lấy danh sách yêu cầu ra ngoài (cho Lãnh đạo)
  Future<List<YeuCauRaNgoai>> layDsYeuCauRaNgoai({
    required DateTime ngay,
    TrangThaiRaNgoai? trangThai,
  }) {
    final ngayStr = _formatDate(ngay);
    return _service.danhSachYeuCauRaNgoai(
      ngay: ngayStr,
      trangThai: trangThai?.value,
    );
  }

  /// Duyệt yêu cầu ra ngoài
  Future<bool> duyetYeuCauRaNgoai(String id) {
    return _service.duyetYeuCauRaNgoai(id: id, hanhDong: 'DUYET');
  }

  /// Từ chối yêu cầu ra ngoài
  Future<bool> tuChoiYeuCauRaNgoai(String id) {
    return _service.duyetYeuCauRaNgoai(id: id, hanhDong: 'TU_CHOI');
  }

  // ======== MỞ CỬA ========

  /// Mở cửa
  Future<bool> moCua(LoaiPhuongTien loaiPhuongTien) {
    return _service.moCua(loaiPhuongTien);
  }

  // ======== TRẠNG THÁI KHÓA ========

  /// Lấy trạng thái khóa hệ thống
  Future<TrangThaiKhoa> layTrangThaiKhoa() => _service.layTrangThaiKhoa();

  /// Khóa hệ thống
  Future<bool> khoaHeThong() {
    return _service.thayDoiTrangThaiKhoa(TrangThaiKhoa.khoa);
  }

  /// Mở khóa hệ thống
  Future<bool> moKhoaHeThong() {
    return _service.thayDoiTrangThaiKhoa(TrangThaiKhoa.khongKhoa);
  }

  // ======== HELPER ========

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
