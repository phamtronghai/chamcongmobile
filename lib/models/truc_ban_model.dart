import 'truc_ban_enums.dart';

/// Model thông tin trực ban
class TrucBan {
  final String id;
  final String hoTen;
  final String soDienThoai;
  final String donVi;
  final int caTruc;
  final String thoiGianBatDau;
  final String thoiGianKetThuc;

  // Fields bổ sung từ API
  final String? ngayTruc;
  final String? userId;
  final String? donViCap;

  const TrucBan({
    required this.id,
    required this.hoTen,
    required this.soDienThoai,
    required this.donVi,
    required this.caTruc,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    this.ngayTruc,
    this.userId,
    this.donViCap,
  });

  /// Parse từ API response
  /// API fields: id(int), ngayTruc, caTruc, batDau(ISO), ketThuc(ISO),
  ///             userId, hoTen, sdt, donVi, donViCap
  factory TrucBan.fromJson(Map<String, dynamic> json) {
    return TrucBan(
      id: json['id']?.toString() ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      soDienThoai: (json['sdt'] ?? json['soDienThoai']) as String? ?? '',
      donVi: json['donVi'] as String? ?? '',
      caTruc: json['caTruc'] as int? ?? 1,
      thoiGianBatDau: _parseTimeFromJson(
        json['batDau'] ?? json['thoiGianBatDau'],
      ),
      thoiGianKetThuc: _parseTimeFromJson(
        json['ketThuc'] ?? json['thoiGianKetThuc'],
      ),
      ngayTruc: json['ngayTruc'] as String?,
      userId: json['userId'] as String?,
      donViCap: json['donViCap'] as String?,
    );
  }

  /// Convert thời gian từ API (ISO 8601) hoặc mock (HH:mm) → HH:mm
  static String _parseTimeFromJson(dynamic value) {
    if (value == null) return '';
    final str = value as String;
    if (str.isEmpty) return '';

    // Nếu đã là dạng HH:mm thì giữ nguyên
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(str)) return str;

    // Parse ISO 8601 → lấy giờ:phút (UTC+7)
    try {
      final dt = DateTime.parse(str).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return str;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hoTen': hoTen,
    'soDienThoai': soDienThoai,
    'donVi': donVi,
    'caTruc': caTruc,
    'thoiGianBatDau': thoiGianBatDau,
    'thoiGianKetThuc': thoiGianKetThuc,
    'ngayTruc': ngayTruc,
    'userId': userId,
    'donViCap': donViCap,
  };
}

/// Model thông tin trực chỉ huy
class TrucChiHuy {
  final String? id;
  final String hoTen;
  final String? capBac;
  final String? chucVu;
  final String? donVi;
  final String? soDienThoai;
  final String? thoiGianBatDau;
  final String? thoiGianKetThuc;

  const TrucChiHuy({
    this.id,
    required this.hoTen,
    this.capBac,
    this.chucVu,
    this.donVi,
    this.soDienThoai,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
  });

  factory TrucChiHuy.fromJson(Map<String, dynamic> json) {
    return TrucChiHuy(
      id: json['id']?.toString(),
      hoTen: json['hoTen'] as String? ?? 'Chưa cập nhật',
      capBac: json['capBac'] as String?,
      chucVu: json['chucVu'] as String?,
      donVi: json['donVi'] as String?,
      soDienThoai: json['soDienThoai'] as String?,
      thoiGianBatDau: json['thoiGianBatDau'] as String?,
      thoiGianKetThuc: json['thoiGianKetThuc'] as String?,
    );
  }
}

/// Model đăng ký khách
class Khach {
  final String? id;
  final String hoTenKhach;
  final String soCanCuoc;
  final String bienSoXe;
  final LoaiPhuongTien loaiPhuongTien;
  final String ngayDangKy;
  final String? trangThai;
  final DateTime? thoiGianTao;
  final NguoiDangKy? nguoiDangKy;
  final String mucDich;
  final String sdtKhach;

  const Khach({
    this.id,
    required this.hoTenKhach,
    this.soCanCuoc = '',
    this.bienSoXe = '',
    this.loaiPhuongTien = LoaiPhuongTien.khac,
    this.ngayDangKy = '',
    this.trangThai,
    this.thoiGianTao,
    this.nguoiDangKy,
    this.mucDich = '',
    this.sdtKhach = '',
  });

  /// Parse từ API response
  /// Hỗ trợ 3 format:
  /// - snake_case (GET /khach/ca-nhan): ten_khach, can_cuoc_khach, loai_xe, bien_so_xe, muc_dich, sdt_khach
  /// - camelCase (GET /khach/toan-don-vi): tenKhach, bienSo, nguoiDangKy(String), donVi
  /// - mock data: hoTenKhach, soCanCuoc, bienSoXe, loaiPhuongTien
  factory Khach.fromJson(Map<String, dynamic> json) {
    // Xử lý nguoiDangKy: API toan-don-vi trả String, mock trả Map
    NguoiDangKy? nguoiDangKy;
    final rawNguoiDangKy = json['nguoiDangKy'];
    if (rawNguoiDangKy is Map<String, dynamic>) {
      nguoiDangKy = NguoiDangKy.fromJson(rawNguoiDangKy);
    } else if (rawNguoiDangKy is String && rawNguoiDangKy.isNotEmpty) {
      nguoiDangKy = NguoiDangKy(
        id: '',
        hoTen: rawNguoiDangKy,
        donVi: json['donVi'] as String? ?? '',
      );
    }

    return Khach(
      id: json['id']?.toString(),
      hoTenKhach:
          (json['ten_khach'] ?? json['tenKhach'] ?? json['hoTenKhach'])
              as String? ??
          '',
      soCanCuoc: (json['can_cuoc_khach'] ?? json['soCanCuoc']) as String? ?? '',
      bienSoXe:
          (json['bien_so_xe'] ?? json['bienSo'] ?? json['bienSoXe'])
              as String? ??
          '',
      loaiPhuongTien: LoaiPhuongTien.fromValue(
        (json['loai_xe'] ?? json['loaiPhuongTien']) as String? ?? 'KHAC',
      ),
      ngayDangKy: json['ngayDangKy'] as String? ?? '',
      trangThai: (json['trang_thai'] ?? json['trangThai']) as String?,
      thoiGianTao: _parseDateTimeFromJson(
        json['bat_dau'] ?? json['thoiGianDen'] ?? json['thoiGianTao'],
      ),
      nguoiDangKy: nguoiDangKy,
      mucDich: (json['muc_dich'] ?? json['mucDich']) as String? ?? '',
      sdtKhach:
          (json['sdt_khach'] ?? json['sdtKhach'] ?? json['sdt']) as String? ??
          '',
    );
  }

  /// Parse DateTime từ ISO 8601 string
  static DateTime? _parseDateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Format cho POST API body
  Map<String, dynamic> toJson() => {
    'tenKhach': hoTenKhach,
    'cccd': soCanCuoc,
    'bienSo': bienSoXe,
    'loaiXe': loaiPhuongTien.value,
    'mucDich': mucDich,
    'sdt': sdtKhach,
    'ngayDangKy': ngayDangKy,
  };
}

/// Model người đăng ký (cho danh sách khách toàn đơn vị)
class NguoiDangKy {
  final String id;
  final String hoTen;
  final String donVi;

  const NguoiDangKy({
    required this.id,
    required this.hoTen,
    required this.donVi,
  });

  factory NguoiDangKy.fromJson(Map<String, dynamic> json) {
    return NguoiDangKy(
      id: json['id'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      donVi: json['donVi'] as String? ?? '',
    );
  }
}

/// Model yêu cầu ra ngoài
class YeuCauRaNgoai {
  final String? id;
  final DateTime thoiGianRa;
  final DateTime thoiGianVao;
  final String lyDo;
  final TrangThaiRaNgoai trangThai;
  final String? nguoiDuyet;
  final DateTime? thoiGianDuyet;
  final DateTime? thoiGianTao;
  final NhanVien? nhanVien;

  const YeuCauRaNgoai({
    this.id,
    required this.thoiGianRa,
    required this.thoiGianVao,
    required this.lyDo,
    this.trangThai = TrangThaiRaNgoai.choDuyet,
    this.nguoiDuyet,
    this.thoiGianDuyet,
    this.thoiGianTao,
    this.nhanVien,
  });

  /// Parse từ API response
  /// Hỗ trợ 3 format:
  /// - snake_case (GET /ra-ngoai/ca-nhan): bat_dau, ket_thuc, ly_do, trang_thai
  /// - camelCase (GET /ra-ngoai/danh-sach): batDau, ketThuc, lyDo, trangThai, hoTen, donVi
  /// - mock: thoiGianRa, thoiGianVao, lyDo, trangThai, nhanVien(Map)
  factory YeuCauRaNgoai.fromJson(Map<String, dynamic> json) {
    // Xử lý nhanVien: API danh-sach trả hoTen/donVi/user_id ở cấp ngoài
    NhanVien? nhanVien;
    if (json['nhanVien'] != null) {
      nhanVien = NhanVien.fromJson(json['nhanVien'] as Map<String, dynamic>);
    } else if (json['hoTen'] != null) {
      nhanVien = NhanVien(
        id: (json['user_id'] ?? json['userId'])?.toString() ?? '',
        hoTen: json['hoTen'] as String? ?? '',
        donVi: json['donVi'] as String? ?? '',
      );
    }

    final rawBatDau = json['bat_dau'] ?? json['batDau'] ?? json['thoiGianRa'];
    final rawKetThuc =
        json['ket_thuc'] ?? json['ketThuc'] ?? json['thoiGianVao'];

    return YeuCauRaNgoai(
      id: json['id']?.toString(),
      thoiGianRa: rawBatDau != null
          ? DateTime.parse(rawBatDau as String)
          : DateTime.now(),
      thoiGianVao: rawKetThuc != null
          ? DateTime.parse(rawKetThuc as String)
          : DateTime.now(),
      lyDo: (json['ly_do'] ?? json['lyDo']) as String? ?? '',
      trangThai: TrangThaiRaNgoai.fromValue(
        (json['trang_thai'] ?? json['trangThai']) as String? ?? 'CHO_DUYET',
      ),
      nguoiDuyet:
          json['nguoi_duyet_id']?.toString() ?? json['nguoiDuyet']?.toString(),
      thoiGianDuyet: json['thoiGianDuyet'] != null
          ? DateTime.tryParse(json['thoiGianDuyet'] as String)
          : null,
      thoiGianTao: json['thoiGianTao'] != null
          ? DateTime.tryParse(json['thoiGianTao'] as String)
          : null,
      nhanVien: nhanVien,
    );
  }

  Map<String, dynamic> toJson() => {
    'thoiGianRa': thoiGianRa.toIso8601String(),
    'thoiGianVao': thoiGianVao.toIso8601String(),
    'lyDo': lyDo,
  };
}

/// Model nhân viên (cho danh sách yêu cầu ra ngoài)
class NhanVien {
  final String id;
  final String hoTen;
  final String donVi;

  const NhanVien({required this.id, required this.hoTen, required this.donVi});

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      id: json['id'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      donVi: json['donVi'] as String? ?? '',
    );
  }
}

/// Model phân quyền người dùng
class PhanQuyen {
  final NhomQuyen nhomQuyen;
  final String moTaQuyen;

  const PhanQuyen({required this.nhomQuyen, required this.moTaQuyen});

  factory PhanQuyen.fromJson(Map<String, dynamic> json) {
    return PhanQuyen(
      nhomQuyen: NhomQuyen.fromValue(
        json['nhomQuyen'] as String? ?? 'BINH_THUONG',
      ),
      moTaQuyen: json['moTaQuyen'] as String? ?? '',
    );
  }

  /// Kiểm tra có quyền xem khách toàn đơn vị không
  bool get canViewDonVi =>
      nhomQuyen == NhomQuyen.trucBan || nhomQuyen == NhomQuyen.lanhDao;

  /// Kiểm tra có quyền khóa/mở khóa hệ thống không
  bool get canLockSystem => nhomQuyen == NhomQuyen.trucBan;

  /// Kiểm tra có quyền duyệt yêu cầu ra ngoài không
  bool get canApproveRaNgoai => nhomQuyen == NhomQuyen.lanhDaoPhong;

  /// Kiểm tra có quyền mở cửa khi bị khóa không
  bool get canOpenWhenLocked =>
      nhomQuyen == NhomQuyen.trucBan || nhomQuyen == NhomQuyen.lanhDao;

  /// Kiểm tra có quyền xem camera không
  bool get canViewCamera =>
      nhomQuyen == NhomQuyen.trucBan || nhomQuyen == NhomQuyen.lanhDao;
}
