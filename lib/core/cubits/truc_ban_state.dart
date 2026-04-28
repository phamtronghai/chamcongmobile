import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:attendancebyface/models/truc_ban_model.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';

part 'truc_ban_state.freezed.dart';

@freezed
class TrucBanState with _$TrucBanState {
  const factory TrucBanState.initial() = TrucBanStateInitial;

  /// Đang tải dữ liệu, có thể chỉ định target cụ thể
  const factory TrucBanState.loading({TrucBanLoadTarget? target}) =
      TrucBanStateLoading;

  /// Đã tải xong thông tin phân quyền
  const factory TrucBanState.phanQuyenLoaded({required PhanQuyen phanQuyen}) =
      TrucBanStatePhanQuyenLoaded;

  /// Đã tải xong danh sách trực ban
  const factory TrucBanState.danhSachTrucBanLoaded({
    required List<TrucBan> danhSach,
    TrucChiHuy? trucChiHuy,
  }) = TrucBanStateDanhSachTrucBanLoaded;

  /// Đã tải xong danh sách khách
  const factory TrucBanState.danhSachKhachLoaded({
    required List<Khach> danhSach,
  }) = TrucBanStateDanhSachKhachLoaded;

  /// Đã tải xong danh sách yêu cầu ra ngoài
  const factory TrucBanState.danhSachRaNgoaiLoaded({
    required List<YeuCauRaNgoai> danhSach,
  }) = TrucBanStateDanhSachRaNgoaiLoaded;

  /// Đã tải xong trạng thái khóa
  const factory TrucBanState.trangThaiKhoaLoaded({
    required TrangThaiKhoa trangThai,
  }) = TrucBanStateTrangThaiKhoaLoaded;

  /// Thao tác thành công (đăng ký, duyệt, mở cửa, v.v.)
  const factory TrucBanState.success({required String message}) =
      TrucBanStateSuccess;

  /// Có lỗi xảy ra
  const factory TrucBanState.error({required String message}) =
      TrucBanStateError;
}
