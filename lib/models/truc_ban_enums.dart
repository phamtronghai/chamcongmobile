/// Enum định nghĩa các nhóm quyền trong hệ thống
enum NhomQuyen {
  binhThuong('BINH_THUONG', 'Bình thường'),
  trucBan('TRUC_BAN', 'Trực ban'),
  lanhDaoPhong('LANH_DAO_PHONG', 'Lãnh đạo phòng'),
  lanhDao('LANH_DAO', 'Lãnh đạo');

  final String value;
  final String moTa;

  const NhomQuyen(this.value, this.moTa);

  /// Parse từ string value
  static NhomQuyen fromValue(String value) {
    return NhomQuyen.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NhomQuyen.binhThuong,
    );
  }
}

/// Enum loại phương tiện
enum LoaiPhuongTien {
  oto('OTO', 'Ô tô'),
  khac('KHAC', 'Xe khác');

  final String value;
  final String moTa;

  const LoaiPhuongTien(this.value, this.moTa);

  static LoaiPhuongTien fromValue(String value) {
    return LoaiPhuongTien.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LoaiPhuongTien.khac,
    );
  }
}

/// Enum trạng thái yêu cầu ra ngoài
enum TrangThaiRaNgoai {
  choDuyet('CHO_DUYET', 'Chờ duyệt'),
  daDuyet('DA_DUYET', 'Đã duyệt'),
  tuChoi('TU_CHOI', 'Từ chối');

  final String value;
  final String moTa;

  const TrangThaiRaNgoai(this.value, this.moTa);

  static TrangThaiRaNgoai fromValue(String value) {
    return TrangThaiRaNgoai.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrangThaiRaNgoai.choDuyet,
    );
  }
}

/// Enum xác định mục tiêu loading
enum TrucBanLoadTarget {
  general,
  raNgoaiCaNhan,
  dangKyKhach,
  dsTrucBan,
  dsKhachToanDonVi,
}
