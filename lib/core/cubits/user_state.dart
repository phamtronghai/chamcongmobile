import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:attendancebyface/models/user_model.dart';

part 'user_state.freezed.dart';

/// User state classes sử dụng freezed để quản lý trạng thái user
@freezed
class UserState with _$UserState {
  /// Trạng thái ban đầu
  const factory UserState.initial() = UserInitial;

  /// Đang tải dữ liệu user
  const factory UserState.loading() = UserLoading;

  /// Đã tải thành công dữ liệu user
  const factory UserState.loaded({required UserModel user}) = UserLoaded;

  /// Lỗi khi tải dữ liệu user
  const factory UserState.error({required String message}) = UserError;
}
