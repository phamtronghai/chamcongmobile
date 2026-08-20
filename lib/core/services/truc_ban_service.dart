import 'package:attendancebyface/core/utils/debug_log.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';

/// Service xử lý các API liên quan đến chức năng trực ban
class TrucBanService {
  final ApiClient _apiClient = ApiClient();

  // ======== API XÁC ĐỊNH NHÓM NGƯỜI DÙNG ========

  /// Lấy thông tin phân quyền của người dùng hiện tại
  ///
  /// Gọi API: GET /api/smartgate/role/me
  /// Response: {"success": true, "role": "TRUC_BAN"}
  Future<PhanQuyen> xacDinhNhomNguoiDung() async {
    try {
      final response = await _apiClient.get('/api/smartgate/role/me');
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('API trả về lỗi khi lấy role');
      }

      final roleStr = data['role'] as String? ?? 'BINH_THUONG';
      final nhomQuyen = NhomQuyen.fromValue(roleStr);

      debugLog('🔐 Role user: ${nhomQuyen.moTa} ($roleStr)');

      return PhanQuyen(nhomQuyen: nhomQuyen, moTaQuyen: nhomQuyen.moTa);
    } catch (e) {
      debugLog('❌ Lỗi lấy role: $e');
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
      final response = await _apiClient.get(
        '/api/smartgate/truc-ban/from-to',
        queryParameters: {'from': ngay, 'to': ngay},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final danhSach = data
          .map((item) => TrucBan.fromJson(item as Map<String, dynamic>))
          .toList();

      debugLog('📋 Danh sách trực ban ($ngay): ${danhSach.length} người');

      return danhSach;
    } catch (e) {
      debugLog('❌ Lỗi lấy danh sách trực ban: $e');
      rethrow;
    }
  }

  /// Lấy thông tin trực chỉ huy theo ngày
  ///
  /// Gọi API: GET /api/smartgate/truc-chi-huy/from-to?from={ngay}&to={ngay}
  /// Response: [{ id, ngayTruc, userId, hoTen, sdt, donVi, donViCap }]
  Future<TrucChiHuy?> layTrucChiHuy(String ngay) async {
    try {
      final response = await _apiClient.get(
        '/api/smartgate/truc-chi-huy/from-to',
        queryParameters: {'from': ngay, 'to': ngay},
      );

      final data = response.data;
      if (data is! List || data.isEmpty) {
        debugLog('⚠️ API không có người trực chỉ huy');
        return null; // Không có chỉ huy trực cũng hợp lệ
      }

      final first = data.first;
      if (first is! Map<String, dynamic>) {
        debugLog('⚠️ API trực chỉ huy trả dữ liệu không hợp lệ');
        return null;
      }
      return TrucChiHuy.fromJson(first);
    } catch (e) {
      debugLog('❌ Lỗi lấy trực chỉ huy (bỏ qua): $e');
      return null; // Không throw để tránh lỗi cả màn hình danh sách
    }
  }

  /// Đăng ký khách
  ///
  /// Gọi API: POST /api/smartgate/khach/dang-ky
  /// Body: { tenKhach, cccd, bienSo, loaiXe, mucDich, sdt, ngayDangKy }
  Future<bool> dangKyKhach(Khach khach) async {
    try {
      final response = await _apiClient.post(
        '/api/smartgate/khach/dang-ky',
        data: khach.toJson(),
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi đăng ký khách');
      }

      debugLog('✅ Đăng ký khách thành công: ${responseData['data']}');
      return true;
    } catch (e) {
      debugLog('❌ Lỗi đăng ký khách: $e');
      rethrow;
    }
  }

  /// Xem lịch sử khách cá nhân
  ///
  /// Gọi API: GET /api/smartgate/khach/ca-nhan?ngay={ngay}
  /// Response: { success, data: [{ id, ten_khach, sdt_khach, can_cuoc_khach, loai_xe, bien_so_xe, muc_dich, trang_thai }] }
  Future<List<Khach>> xemLichSuKhachCaNhan(String ngay) async {
    try {
      final response = await _apiClient.get(
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

      debugLog('📋 Lịch sử khách cá nhân ($ngay): ${danhSach.length} khách');
      return danhSach;
    } catch (e) {
      debugLog('❌ Lỗi lấy lịch sử khách: $e');
      rethrow;
    }
  }

  /// Đăng ký ra ngoài
  ///
  /// Gọi API: POST /api/smartgate/ra-ngoai/dang-ky
  /// Body: { thoiGianRa, thoiGianVao, lyDo }
  Future<bool> dangKyRaNgoai(YeuCauRaNgoai yeuCau) async {
    try {
      final response = await _apiClient.post(
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

      debugLog('✅ Đăng ký ra ngoài thành công: ${responseData['data']}');
      return true;
    } catch (e) {
      debugLog('❌ Lỗi đăng ký ra ngoài: $e');
      rethrow;
    }
  }

  /// Xem lịch sử ra ngoài cá nhân
  ///
  /// Gọi API: GET /api/smartgate/ra-ngoai/ca-nhan?ngay={ngay}
  /// Response: { success, data: [{ id, userId, ly_do, trang_thai, bat_dau, ket_thuc, nguoi_duyet_id }] }
  Future<List<YeuCauRaNgoai>> lichSuRaNgoaiCaNhan(String ngay) async {
    try {
      final response = await _apiClient.get(
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

      debugLog('📋 Lịch sử ra ngoài ($ngay): ${danhSach.length} yêu cầu');
      return danhSach;
    } catch (e) {
      debugLog('❌ Lỗi lấy lịch sử ra ngoài: $e');
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
      final response = await _apiClient.post(
        '/api/smartgate/mo-cua',
        data: {'loaiPhuongTien': loaiPhuongTien.value},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        final errorMsg =
            responseData['message'] as String? ??
            responseData['error'] as String? ??
            'Lỗi không xác định khi mở cửa';
        debugLog('❌ Mở cửa thất bại: $responseData');
        throw Exception(errorMsg);
      }

      final data = responseData['data'] as Map<String, dynamic>?;
      final message = data?['message'] as String? ?? 'Mở cửa thành công';
      debugLog('🚪 Mở cửa: $message');
      return true;
    } catch (e) {
      debugLog('❌ Lỗi mở cửa: $e');
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
      final response = await _apiClient.get(
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

      debugLog('👥 Khách toàn đơn vị ($ngay): ${danhSach.length} khách');

      return danhSach;
    } catch (e) {
      debugLog('❌ Lỗi lấy danh sách khách toàn đơn vị: $e');
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
      final queryParams = <String, dynamic>{'ngay': ngay};
      if (trangThai != null) {
        queryParams['trangThai'] = trangThai;
      }

      final response = await _apiClient.get(
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

      debugLog(
        '📋 DS yêu cầu ra ngoài ($ngay, $trangThai): ${danhSach.length}',
      );
      for (final yc in danhSach) {
        debugLog(
          '  → [${yc.id}] ${yc.nhanVien?.hoTen ?? "?"} (userId: ${yc.nhanVien?.id ?? "N/A"}) | ${yc.trangThai.moTa} | Ra: ${yc.thoiGianRa} | Vào: ${yc.thoiGianVao} | Lý do: ${yc.lyDo}',
        );
      }
      return danhSach;
    } catch (e) {
      debugLog('❌ Lỗi lấy DS yêu cầu ra ngoài: $e');
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
      final response = await _apiClient.put(
        '/api/smartgate/ra-ngoai/$id/duyet',
        data: {'hanhDong': hanhDong},
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception('API trả về lỗi khi duyệt yêu cầu ra ngoài');
      }

      debugLog(
        '✅ ${hanhDong == 'DUYET' ? 'Duyệt' : 'Từ chối'} yêu cầu $id thành công',
      );
      return true;
    } catch (e) {
      debugLog('❌ Lỗi duyệt yêu cầu ra ngoài: $e');
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
      await _apiClient.post(
        '/send-notification',
        data: {'userId': userId, 'title': title, 'message': message},
      );
      debugLog('📨 Thông báo đã gửi đến: $userId');
    } catch (e) {
      debugLog('❌ Lỗi gửi thông báo (bỏ qua): $e');
      // Không throw để không ảnh hưởng flow chính
    }
  }
}
