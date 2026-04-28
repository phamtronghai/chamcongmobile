import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';

/// Service xử lý các API liên quan đến chức năng trực ban
class TrucBanService {
  /// Base URL cố định cho API smartgate
  static const String _smartgateBaseUrl = 'https://auth.samcom.com.vn';

  /// Tạo Dio instance riêng cho API smartgate (baseURL cố định)
  Dio _createSmartgateDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _smartgateBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.requestTimeout),
        receiveTimeout: Duration(seconds: AppConfig.requestTimeout),
        headers: AppConfig.defaultHeaders,
      ),
    );
    // Dùng chung cookie jar từ ApiClient để gửi cookie xác thực
    dio.interceptors.add(CookieManager(ApiClient().cookieJar));
    return dio;
  }

  // ======== API XÁC ĐỊNH NHÓM NGƯỜI DÙNG ========

  /// Lấy thông tin phân quyền của người dùng hiện tại
  ///
  /// Gọi API: GET /api/smartgate/role/me
  /// Response: {"success": true, "role": "TRUC_BAN"}
  Future<PhanQuyen> xacDinhNhomNguoiDung() async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get('/api/smartgate/role/me');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('API trả về lỗi khi lấy role');
      }

      final roleStr = data['role'] as String? ?? 'BINH_THUONG';
      final nhomQuyen = NhomQuyen.fromValue(roleStr);

      debugPrint('🔐 Role user: ${nhomQuyen.moTa} ($roleStr)');

      return PhanQuyen(nhomQuyen: nhomQuyen, moTaQuyen: nhomQuyen.moTa);
    } catch (e) {
      debugPrint('❌ Lỗi lấy role: $e');
      // Fallback về quyền bình thường nếu API lỗi
      return PhanQuyen(
        nhomQuyen: NhomQuyen.binhThuong,
        moTaQuyen: NhomQuyen.binhThuong.moTa,
      );
    }
  }

  // ======== API CHỨC NĂNG CHUNG ========

  /// Lấy danh sách trực ban theo ngày
  ///
  /// Gọi API: GET /api/smartgate/truc-ban/from-to?from={ngay}&to={ngay}
  /// Response: [{ id, ngayTruc, caTruc, batDau, ketThuc, userId, hoTen, sdt, donVi, donViCap }]
  Future<List<TrucBan>> layDanhSachTrucBan(String ngay) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get(
        '/api/smartgate/truc-ban/from-to',
        queryParameters: {'from': ngay, 'to': ngay},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final danhSach = data
          .map((item) => TrucBan.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('📋 Danh sách trực ban ($ngay): ${danhSach.length} người');

      return danhSach;
    } catch (e) {
      debugPrint('❌ Lỗi lấy danh sách trực ban: $e');
      rethrow;
    }
  }

  /// Lấy thông tin trực chỉ huy theo ngày
  ///
  /// Gọi API: GET /api/smartgate/truc-chi-huy?ngay={ngay}
  /// Response: { success, data: { hoTen, capBac, ... } }
  Future<TrucChiHuy?> layTrucChiHuy(String ngay) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get(
        '/api/smartgate/truc-chi-huy',
        queryParameters: {'ngay': ngay},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        debugPrint('⚠️ API không có người trực chỉ huy');
        return null; // Không có chỉ huy trực cũng hợp lệ
      }

      final data = responseData['data'];
      if (data == null) return null;

      return TrucChiHuy.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Lỗi lấy trực chỉ huy (bỏ qua): $e');
      return null; // Không throw để tránh lỗi cả màn hình danh sách
    }
  }

  /// Đăng ký khách
  ///
  /// Gọi API: POST /api/smartgate/khach/dang-ky
  /// Body: { tenKhach, cccd, bienSo, loaiXe, mucDich, sdt, ngayDangKy }
  Future<bool> dangKyKhach(Khach khach) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.post(
        '/api/smartgate/khach/dang-ky',
        data: khach.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi đăng ký khách');
      }

      debugPrint('✅ Đăng ký khách thành công: ${responseData['data']}');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi đăng ký khách: $e');
      rethrow;
    }
  }

  /// Xem lịch sử khách cá nhân
  ///
  /// Gọi API: GET /api/smartgate/khach/ca-nhan?ngay={ngay}
  /// Response: { success, data: [{ id, ten_khach, sdt_khach, can_cuoc_khach, loai_xe, bien_so_xe, muc_dich, trang_thai }] }
  Future<List<Khach>> xemLichSuKhachCaNhan(String ngay) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get(
        '/api/smartgate/khach/ca-nhan',
        queryParameters: {'ngay': ngay},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi lấy lịch sử khách');
      }

      final List<dynamic> data = responseData['data'] as List<dynamic>;
      final danhSach = data
          .map((item) => Khach.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('📋 Lịch sử khách cá nhân ($ngay): ${danhSach.length} khách');
      return danhSach;
    } catch (e) {
      debugPrint('❌ Lỗi lấy lịch sử khách: $e');
      rethrow;
    }
  }

  /// Đăng ký ra ngoài
  ///
  /// Gọi API: POST /api/smartgate/ra-ngoai/dang-ky
  /// Body: { thoiGianRa, thoiGianVao, lyDo }
  Future<bool> dangKyRaNgoai(YeuCauRaNgoai yeuCau) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.post(
        '/api/smartgate/ra-ngoai/dang-ky',
        data: {
          'thoiGianRa': yeuCau.thoiGianRa.toUtc().toIso8601String(),
          'thoiGianVao': yeuCau.thoiGianVao.toUtc().toIso8601String(),
          'lyDo': yeuCau.lyDo,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi đăng ký ra ngoài');
      }

      debugPrint('✅ Đăng ký ra ngoài thành công: ${responseData['data']}');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi đăng ký ra ngoài: $e');
      rethrow;
    }
  }

  /// Xem lịch sử ra ngoài cá nhân
  ///
  /// Gọi API: GET /api/smartgate/ra-ngoai/ca-nhan?ngay={ngay}
  /// Response: { success, data: [{ id, userId, ly_do, trang_thai, bat_dau, ket_thuc, nguoi_duyet_id }] }
  Future<List<YeuCauRaNgoai>> lichSuRaNgoaiCaNhan(String ngay) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get(
        '/api/smartgate/ra-ngoai/ca-nhan',
        queryParameters: {'ngay': ngay},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi lấy lịch sử ra ngoài');
      }

      final List<dynamic> data = responseData['data'] as List<dynamic>;
      final danhSach = data
          .map((item) => YeuCauRaNgoai.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('📋 Lịch sử ra ngoài ($ngay): ${danhSach.length} yêu cầu');
      return danhSach;
    } catch (e) {
      debugPrint('❌ Lỗi lấy lịch sử ra ngoài: $e');
      rethrow;
    }
  }

  /// Mở cửa
  ///
  /// Gọi API: POST /api/smartgate/mo-cua
  /// Body: { "loaiPhuongTien": "OTO" | "KHAC" }
  /// Response: { success, data: { message, remainingSec, trangThai } }
  Future<bool> moCua(LoaiPhuongTien loaiPhuongTien) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.post(
        '/api/smartgate/mo-cua',
        data: {'loaiPhuongTien': loaiPhuongTien.value},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        final errorMsg =
            responseData['message'] as String? ??
            responseData['error'] as String? ??
            'Lỗi không xác định khi mở cửa';
        debugPrint('❌ Mở cửa thất bại: $responseData');
        throw Exception(errorMsg);
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      final message = data?['message'] as String? ?? 'Mở cửa thành công';
      debugPrint('🚪 Mở cửa: $message');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi mở cửa: $e');
      rethrow;
    }
  }

  // ======== API CHO TRỰC BAN & LÃNH ĐẠO ========

  /// Xem danh sách khách toàn đơn vị
  ///
  /// Gọi API: GET /api/smartgate/khach/toan-don-vi?ngay={ngay}
  /// Response: {"success": true, "data": [{ id, tenKhach, bienSo, trangThai, thoiGianDen, nguoiDangKy, donVi }]}
  Future<List<Khach>> dsKhachToanDonVi(String ngay) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get(
        '/api/smartgate/khach/toan-don-vi',
        queryParameters: {'ngay': ngay},
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi lấy danh sách khách');
      }

      final List<dynamic> data = responseData['data'] as List<dynamic>;
      final danhSach = data
          .map((item) => Khach.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('👥 Khách toàn đơn vị ($ngay): ${danhSach.length} khách');

      return danhSach;
    } catch (e) {
      debugPrint('❌ Lỗi lấy danh sách khách toàn đơn vị: $e');
      rethrow;
    }
  }

  // ======== API CHO TRỰC BAN ========

  /// Lấy trạng thái khóa hệ thống
  ///
  /// Gọi API: GET /api/smartgate/he-thong/trang-thai-khoa
  /// Response: { success, data: { trangThai: "KHONG_KHOA" | "KHOA" } }
  Future<TrangThaiKhoa> layTrangThaiKhoa() async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.get('/api/smartgate/he-thong/trang-thai-khoa');

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi lấy trạng thái khóa');
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final trangThaiStr = data['trangThai'] as String? ?? 'KHONG_KHOA';
      final trangThai = TrangThaiKhoa.fromValue(trangThaiStr);

      debugPrint('🔒 Trạng thái khóa: ${trangThai.moTa} ($trangThaiStr)');
      return trangThai;
    } catch (e) {
      debugPrint('❌ Lỗi lấy trạng thái khóa: $e');
      rethrow;
    }
  }

  /// Thay đổi trạng thái khóa hệ thống
  ///
  /// Gọi API: PUT /api/smartgate/he-thong/thay-doi-trang-thai-khoa
  /// Payload: { "trangThai": "KHOA" } hoặc { "trangThai": "KHONG_KHOA" }
  Future<bool> thayDoiTrangThaiKhoa(TrangThaiKhoa trangThai) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.put(
        '/api/smartgate/he-thong/thay-doi-trang-thai-khoa',
        data: {'trangThai': trangThai.value},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi thay đổi trạng thái khóa');
      }

      debugPrint('✅ Thay đổi trạng thái khóa thành công: ${trangThai.value}');
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi thay đổi trạng thái khóa: $e');
      rethrow;
    }
  }

  // ======== API CHO LÃNH ĐẠO ========

  /// Lấy danh sách yêu cầu ra ngoài
  ///
  /// Gọi API: GET /api/smartgate/ra-ngoai/danh-sach-yeu-cau?ngay={ngay}&trangThai={trangThai}
  /// Response: { success, data: [{ id, lyDo, batDau, ketThuc, trangThai, hoTen, donVi }] }
  Future<List<YeuCauRaNgoai>> danhSachYeuCauRaNgoai({
    required String ngay,
    String? trangThai,
  }) async {
    try {
      final dio = _createSmartgateDio();
      final queryParams = <String, dynamic>{'ngay': ngay};
      if (trangThai != null) {
        queryParams['trangThai'] = trangThai;
      }

      final response = await dio.get(
        '/api/smartgate/ra-ngoai/danh-sach-yeu-cau',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi lấy danh sách yêu cầu ra ngoài');
      }

      final List<dynamic> data = responseData['data'] as List<dynamic>;
      final danhSach = data
          .map((item) => YeuCauRaNgoai.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint(
        '📋 DS yêu cầu ra ngoài ($ngay, $trangThai): ${danhSach.length}',
      );
      for (final yc in danhSach) {
        debugPrint(
          '  → [${yc.id}] ${yc.nhanVien?.hoTen ?? "?"} (userId: ${yc.nhanVien?.id ?? "N/A"}) | ${yc.trangThai.moTa} | Ra: ${yc.thoiGianRa} | Vào: ${yc.thoiGianVao} | Lý do: ${yc.lyDo}',
        );
      }
      return danhSach;
    } catch (e) {
      debugPrint('❌ Lỗi lấy DS yêu cầu ra ngoài: $e');
      rethrow;
    }
  }

  /// Duyệt hoặc từ chối yêu cầu ra ngoài
  ///
  /// Gọi API: PUT /api/smartgate/ra-ngoai/{id}/duyet
  /// Body: { "hanhDong": "DUYET" | "TU_CHOI" }
  Future<bool> duyetYeuCauRaNgoai({
    required String id,
    required String hanhDong, // 'DUYET' hoặc 'TU_CHOI'
  }) async {
    try {
      final dio = _createSmartgateDio();
      final response = await dio.put(
        '/api/smartgate/ra-ngoai/$id/duyet',
        data: {'hanhDong': hanhDong},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi duyệt yêu cầu ra ngoài');
      }

      debugPrint(
        '✅ ${hanhDong == 'DUYET' ? 'Duyệt' : 'Từ chối'} yêu cầu $id thành công',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Lỗi duyệt yêu cầu ra ngoài: $e');
      rethrow;
    }
  }
  // ======== THÔNG BÁO ========

  /// Gửi thông báo qua API
  ///
  /// Gọi API: POST /send-notification
  /// Body: { userId, title, message }
  Future<void> guiThongBao({
    required String userId,
    required String title,
    required String message,
  }) async {
    if (userId.isEmpty) return;
    try {
      final dio = _createSmartgateDio();
      await dio.post(
        '/send-notification',
        data: {'userId': userId, 'title': title, 'message': message},
      );
      debugPrint('📨 Thông báo đã gửi đến: $userId');
    } catch (e) {
      debugPrint('❌ Lỗi gửi thông báo (bỏ qua): $e');
      // Không throw để không ảnh hưởng flow chính
    }
  }
}
