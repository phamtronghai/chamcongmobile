import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/citizen_service.dart';
import 'user_state.dart';
import 'dart:convert';
import 'package:attendancebyface/core/network/api_client.dart';
// removed ApiClient dependency since we no longer normalize image URLs

/// Cubit để quản lý trạng thái user và các thông tin liên quan
class UserCubit extends Cubit<UserState> {
  final AuthService _authService;
  final FaceService _faceService;
  final CitizenService _citizenService;

  UserCubit({
    required AuthService authService,
    required FaceService faceService,
    required CitizenService citizenService,
  }) : _authService = authService,
       _faceService = faceService,
       _citizenService = citizenService,
       super(const UserState.initial());

  /// Load tất cả thông tin user (bao gồm face và citizen registration)
  Future<void> loadUserData() async {
    emit(const UserState.loading());

    try {
      debugPrint('🔧 UserCubit: Bắt đầu load user data...');

      // 1. Lấy thông tin user cơ bản từ session
      final user = await _authService.getCurrentUser();
      if (user == null) {
        emit(const UserState.error(message: 'Không thể lấy thông tin user'));
        return;
      }

      debugPrint('🔧 UserCubit: Đã lấy thông tin user cơ bản: ${user.name}');

      // 2. Kiểm tra đăng ký khuôn mặt và căn cước song song
      final results = await Future.wait([
        _faceService.checkRegistered(user.id),
        _citizenService.checkCitizenRegistration(),
        _citizenService.fetchCitizenInfo(),
      ]);

      final bool isFaceRegistered = results[0] as bool;
      final bool isCitizenRegistered = results[1] as bool;
      final Map<String, dynamic>? citizenInfo =
          results[2] as Map<String, dynamic>?;

      debugPrint(
        '🔧 UserCubit: Face registered: $isFaceRegistered, Citizen registered: $isCitizenRegistered',
      );

      // 3. Tạo UserModel mới với thông tin đầy đủ
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        image: _resolveAbsoluteUrl(user.image),
        role: user.role,
        banned: user.banned,
        username: user.username,
        position: user.position,
        phone: user.phone,
        department: user.department,
        departmentSlug: user.departmentSlug,
        canApprove: user.canApprove,
        isFaceRegistered: isFaceRegistered,
        isCitizenRegistered: isCitizenRegistered,
        citizenNumber: citizenInfo?['citizenNumber'] as String?,
        oldIdNumber: citizenInfo?['oldIdNumber'] as String?,
        fullNameOnCitizen: citizenInfo?['fullName'] as String?,
        dateOfBirth: citizenInfo?['dateOfBirth'] as String?,
        gender: citizenInfo?['gender'] as String?,
        address: citizenInfo?['address'] as String?,
        issuedDate: citizenInfo?['issuedDate'] as String?,
      );

      emit(UserState.loaded(user: updatedUser));
      debugPrint(
        '🔧 UserCubit: Đã load thành công user data với đầy đủ thông tin',
      );
      _debugLogUser(updatedUser);
    } catch (e) {
      debugPrint('🔧 UserCubit: Lỗi khi load user data: $e');
      emit(UserState.error(message: 'Lỗi khi tải dữ liệu: ${e.toString()}'));
    }
  }

  /// Load user data từ UserModel có sẵn (dùng khi đã có user từ login)
  Future<void> loadUserDataFromUser(UserModel user) async {
    emit(const UserState.loading());

    try {
      debugPrint(
        '🔧 UserCubit: Bắt đầu load user data từ UserModel có sẵn: ${user.name}',
      );

      // Kiểm tra đăng ký khuôn mặt và căn cước song song
      final results = await Future.wait([
        _faceService.checkRegistered(user.id),
        _citizenService.checkCitizenRegistration(),
        _citizenService.fetchCitizenInfo(),
      ]);

      final bool isFaceRegistered = results[0] as bool;
      final bool isCitizenRegistered = results[1] as bool;
      final Map<String, dynamic>? citizenInfo =
          results[2] as Map<String, dynamic>?;

      debugPrint(
        '🔧 UserCubit: Face registered: $isFaceRegistered, Citizen registered: $isCitizenRegistered',
      );

      // Tạo UserModel mới với thông tin đầy đủ
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        image: _resolveAbsoluteUrl(user.image),
        role: user.role,
        banned: user.banned,
        username: user.username,
        position: user.position,
        phone: user.phone,
        department: user.department,
        departmentSlug: user.departmentSlug,
        canApprove: user.canApprove,
        isFaceRegistered: isFaceRegistered,
        isCitizenRegistered: isCitizenRegistered,
        citizenNumber: citizenInfo?['citizenNumber'] as String?,
        oldIdNumber: citizenInfo?['oldIdNumber'] as String?,
        fullNameOnCitizen: citizenInfo?['fullName'] as String?,
        dateOfBirth: citizenInfo?['dateOfBirth'] as String?,
        gender: citizenInfo?['gender'] as String?,
        address: citizenInfo?['address'] as String?,
        issuedDate: citizenInfo?['issuedDate'] as String?,
      );

      emit(UserState.loaded(user: updatedUser));
      debugPrint(
        '🔧 UserCubit: Đã load thành công user data từ UserModel có sẵn',
      );
      _debugLogUser(updatedUser);
    } catch (e) {
      debugPrint('🔧 UserCubit: Lỗi khi load user data từ UserModel: $e');
      emit(UserState.error(message: 'Lỗi khi tải dữ liệu: ${e.toString()}'));
    }
  }

  /// Cập nhật thông tin user (khi có thay đổi)
  Future<void> updateUser(UserModel user) async {
    if (state is UserLoaded) {
      debugPrint('🔧 UserCubit: Cập nhật thông tin user: ${user.name}');
      emit(UserState.loaded(user: user));
    }
  }

  /// Refresh user data (load lại từ API)
  Future<void> refresh() async {
    debugPrint('🔧 UserCubit: Refresh user data...');
    await loadUserData();
  }

  /// Cập nhật trạng thái đăng ký khuôn mặt
  Future<void> updateFaceRegistrationStatus(bool isRegistered) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final updatedUser = currentState.user.copyWith(
        isFaceRegistered: isRegistered,
      );
      emit(UserState.loaded(user: updatedUser));
      debugPrint(
        '🔧 UserCubit: Đã cập nhật trạng thái đăng ký khuôn mặt: $isRegistered',
      );
    }
  }

  /// Cập nhật trạng thái đăng ký căn cước
  Future<void> updateCitizenRegistrationStatus(bool isRegistered) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final updatedUser = currentState.user.copyWith(
        isCitizenRegistered: isRegistered,
      );
      emit(UserState.loaded(user: updatedUser));
      debugPrint(
        '🔧 UserCubit: Đã cập nhật trạng thái đăng ký căn cước: $isRegistered',
      );
    }
  }

  /// Clear user data (khi logout)
  void clearUserData() {
    debugPrint('🔧 UserCubit: Xóa dữ liệu user');
    emit(const UserState.initial());
  }

  /// Lấy user hiện tại (nếu có)
  UserModel? get currentUser {
    final state = this.state;
    if (state is UserLoaded) {
      return state.user;
    }
    return null;
  }

  /// Kiểm tra xem user có đăng ký khuôn mặt không
  bool get isFaceRegistered {
    final state = this.state;
    if (state is UserLoaded) {
      return state.user.isFaceRegistered;
    }
    return false;
  }

  /// Kiểm tra xem user có đăng ký căn cước không
  bool get isCitizenRegistered {
    final state = this.state;
    if (state is UserLoaded) {
      return state.user.isCitizenRegistered;
    }
    return false;
  }
}

void _debugLogUser(UserModel u) {
  try {
    final map = u.toJson();
    debugPrint('🔧 User snapshot: ${jsonEncode(map)}');
  } catch (_) {
    debugPrint(
      '🔧 User snapshot: id=${u.id}, name=${u.name}, email=${u.email}, role=${u.role}, department=${u.department}, position=${u.position}, image=${u.image}, isFaceRegistered=${u.isFaceRegistered}, isCitizenRegistered=${u.isCitizenRegistered}, citizenNumber=${u.citizenNumber}, oldIdNumber=${u.oldIdNumber}',
    );
  }
}

String _resolveAbsoluteUrl(String value) {
  if (value.isEmpty) return value;
  if (value.startsWith('http')) return value;
  try {
    final base = ApiClient().dio.options.baseUrl;
    final hasTrailing = base.endsWith('/');
    final hasLeading = value.startsWith('/');
    final normalizedBase = hasTrailing
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = hasLeading ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  } catch (_) {
    return value;
  }
}
