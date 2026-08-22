import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/screens/personal_info/widgets/profile_update_sheet.dart';
import 'package:attendancebyface/screens/personal_info/widgets/change_password_sheet.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with TickerProviderStateMixin {
  late UserModel _user;
  late TabController _tabController;
  bool _isUpdatingAvatar = false;
  bool _isLoading = false;
  bool _isFaceRegistered = false;
  AdaptiveThemeMode _themeMode = AdaptiveThemeMode.system;
  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = locator<AuthService>();

  static const List<AdaptiveThemeMode> _themeCycle = [
    AdaptiveThemeMode.system,
    AdaptiveThemeMode.light,
    AdaptiveThemeMode.dark,
  ];

  @override
  void initState() {
    super.initState();
    _user = context.read<UserCubit>().currentUser!;
    _isFaceRegistered = _user.isFaceRegistered;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeMode = AdaptiveTheme.of(context).mode;
    final currentUser = context.read<UserCubit>().currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _isFaceRegistered = currentUser.isFaceRegistered;
    }
  }

  void _cycleTheme() {
    final currentIndex = _themeCycle.indexOf(_themeMode);
    // Tìm mode tiếp theo khác với current
    AdaptiveThemeMode next = _themeMode;
    for (int i = 1; i <= _themeCycle.length; i++) {
      final candidate = _themeCycle[(currentIndex + i) % _themeCycle.length];
      if (candidate != _themeMode) {
        next = candidate;
        break;
      }
    }
    if (next == _themeMode) return;
    setState(() => _themeMode = next);
    switch (next) {
      case AdaptiveThemeMode.light:
        AdaptiveTheme.of(context).setLight();
      case AdaptiveThemeMode.dark:
        AdaptiveTheme.of(context).setDark();
      case AdaptiveThemeMode.system:
        AdaptiveTheme.of(context).setSystem();
    }
    if (!mounted) return;
    CustomSnackbar.show(
      context: context,
      message: 'Giao diện: ${_themeModeLabel()}',
      type: CustomSnackbarType.success,
    );
  }

  String _themeModeLabel() {
    return switch (_themeMode) {
      AdaptiveThemeMode.light => 'Sáng',
      AdaptiveThemeMode.dark => 'Tối',
      AdaptiveThemeMode.system => 'Hệ thống',
    };
  }

  IconData _themeModeIcon() {
    return switch (_themeMode) {
      AdaptiveThemeMode.light => Icons.light_mode_outlined,
      AdaptiveThemeMode.dark => Icons.dark_mode_outlined,
      AdaptiveThemeMode.system => Icons.brightness_auto_outlined,
    };
  }

  Future<void> _handleRegisterFace() async {
    if (_isFaceRegistered) {
      CustomSnackbar.show(
        context: context,
        message: 'Khuôn mặt đã được đăng ký!',
        type: CustomSnackbarType.info,
      );
      return;
    }
    AppRouter.goToRegisterFace(context, _user);
  }

  void _showChangePasswordSheet() {
    ChangePasswordSheet.show(
      context,
      onConfirm: _changePassword,
      onSuccess: _logout,
    );
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
    bool revokeOtherSessions,
  ) async {
    setState(() => _isLoading = true);
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      revokeOtherSessions: false,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      await SecureStorage.removeAuthToken();
      await NotificationService.instance.unregisterFcmToken();
      await _authService.logout();
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Đăng xuất thành công',
        type: CustomSnackbarType.success,
      );
      AppRouter.goToLogin(context);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Lỗi: ${e.toString()}',
        type: CustomSnackbarType.warning,
      );
      AppRouter.goToLogin(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isUpdatingAvatar = true);

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await _apiClient.post(
        '/api/updateAvatar',
        data: formData,
      );
      if (response.statusCode == 200) {
        String? newImageUrl;
        try {
          if (response.data is Map) {
            newImageUrl = response.data['url'];
          } else if (response.data is String) {
            final map =
                jsonDecode(response.data as String) as Map<String, dynamic>;
            newImageUrl = map['url'] as String?;
          }
        } catch (_) {}

        final String effectiveUrl = newImageUrl ?? _user.image;
        final String absoluteUrl = _toAbsoluteUrl(effectiveUrl);
        final String versionedUrl = absoluteUrl.isNotEmpty
            ? '$absoluteUrl?v=${DateTime.now().millisecondsSinceEpoch}'
            : effectiveUrl;

        final updated = _user.copyWith(image: versionedUrl);
        setState(() => _user = updated);

        if (mounted) {
          context.read<UserCubit>().updateUser(updated);
          CustomSnackbar.show(
            context: context,
            message: 'Cập nhật ảnh đại diện thành công!',
            type: CustomSnackbarType.success,
          );
        }
      } else {
        throw Exception('API trả về status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi cập nhật ảnh đại diện: $e',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingAvatar = false);
    }
  }

  String _toAbsoluteUrl(String value) {
    if (value.isEmpty) return value;
    if (value.startsWith('http')) return value;
    final base = ApiClient().dio.options.baseUrl;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  void _showUpdateProfileSheet() async {
    final result = await ProfileUpdateSheet.show(
      context,
      initialName: _user.name,
      initialPhone: _user.phone,
    );
    if (result != null) {
      await _updateUserProfile(result['name']!, result['phone']!);
    }
  }

  Future<void> _updateUserProfile(String newName, String newPhone) async {
    try {
      final updated = _user.copyWith(name: newName, phone: newPhone);
      setState(() => _user = updated);
      context.read<UserCubit>().updateUser(updated);
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Cập nhật thông tin thành công!',
          type: CustomSnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi khi cập nhật thông tin: $e',
          type: CustomSnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Đang xử lý...',
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(title: 'Thông tin cá nhân'),
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildAvatarSection(colorScheme),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user.name,
                                style: TextConstants.appTextBold.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user.email,
                                style: TextConstants.appTextRegular.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(child: _buildQuickActions()),
                  ],
                ),
              ),
            ),

            // Tab buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Center(
                child: SamcomTabBar(
                  controller: _tabController,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  tabs: const [
                    Tab(text: 'Cơ bản'),
                    Tab(text: 'Căn cước'),
                  ],
                ),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBasicInfoTab(colorScheme), _buildCitizenTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ColorScheme colorScheme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GradientAvatarRing(
          size: 108,
          outerPadding: 4,
          innerPadding: 3,
          child: CircleAvatar(
            radius: 46,
            backgroundImage:
                _user.image.isNotEmpty ? NetworkImage(_user.image) : null,
            child: _user.image.isEmpty
                ? Icon(
                    Icons.account_circle,
                    size: 52,
                    color: colorScheme.primary,
                  )
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomButton(
              text: '',
              icon: _isUpdatingAvatar ? Icons.hourglass_top : Icons.camera_alt,
              variant: CustomButtonVariant.iconButton,
              width: 36,
              onPressed: _isUpdatingAvatar ? null : _changeAvatar,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final colorScheme = Theme.of(context).colorScheme;
    final faceAccent = _isFaceRegistered
        ? colorScheme.primary
        : ColorConstants.errorColor;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildIconAction(
          colorScheme: colorScheme,
          label: 'Khuôn mặt',
          labelColor: faceAccent,
          child: CustomButton(
            svgPath: 'assets/icon/FaceID.svg',
            variant: CustomButtonVariant.iconButton,
            accentColor: faceAccent,
            onPressed: _handleRegisterFace,
          ),
        ),
        _buildIconAction(
          colorScheme: colorScheme,
          label: _themeModeLabel(),
          child: CustomButton(
            icon: _themeModeIcon(),
            variant: CustomButtonVariant.iconButton,
            onPressed: _cycleTheme,
          ),
        ),
        _buildIconAction(
          colorScheme: colorScheme,
          label: 'Mật khẩu',
          child: CustomButton(
            icon: Icons.lock_reset,
            variant: CustomButtonVariant.iconButton,
            onPressed: _showChangePasswordSheet,
          ),
        ),
        _buildIconAction(
          colorScheme: colorScheme,
          label: 'Đăng xuất',
          child: CustomButton(
            icon: Icons.logout,
            variant: CustomButtonVariant.iconButton,
            onPressed: _logout,
          ),
        ),
      ],
    );
  }

  Widget _buildIconAction({
    required ColorScheme colorScheme,
    required String label,
    required Widget child,
    Color? labelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextConstants.appTextRegular.copyWith(
            color: labelColor ??
                colorScheme.onSurface.withValues(alpha: 0.75),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBasicInfoTab(ColorScheme cs) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow(
            context,
            icon: Icons.business,
            label: 'Phòng ban',
            value: _user.department,
          ),
          _buildInfoRow(
            context,
            icon: Icons.work,
            label: 'Chức vụ',
            value: _user.position,
          ),
          _buildInfoRow(
            context,
            icon: Icons.phone,
            label: 'Số điện thoại',
            value: _user.phone ?? '',
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Cập nhật thông tin',
            icon: Icons.edit,
            onPressed: _showUpdateProfileSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildCitizenTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_user.citizenNumber?.isNotEmpty == true) ...[
            _buildInfoRow(
              context,
              icon: Icons.badge_outlined,
              label: 'Số căn cước',
              value: _user.citizenNumber!,
            ),
            _buildInfoRow(
              context,
              icon: Icons.credit_card_outlined,
              label: 'Số CMT cũ',
              value: _user.oldIdNumber ?? '',
            ),
            _buildInfoRow(
              context,
              icon: Icons.person_outline_rounded,
              label: 'Họ và tên',
              value: _user.fullNameOnCitizen!,
            ),
            _buildInfoRow(
              context,
              icon: Icons.cake_outlined,
              label: 'Ngày sinh',
              value: _user.dateOfBirth!,
            ),
            _buildInfoRow(
              context,
              icon: Icons.person_outline,
              label: 'Giới tính',
              value: _user.gender!,
            ),
            _buildInfoRow(
              context,
              icon: Icons.location_on_outlined,
              label: 'Địa chỉ',
              value: _user.address!,
            ),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'Ngày cấp',
              value: _user.issuedDate!,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Cập nhật Căn cước (QR)',
              icon: Icons.qr_code_scanner,
              onPressed: () => AppRouter.goToQRScanner(context),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: BaseEmptyState(),
            ),
            CustomButton(
              text: 'Thêm Căn cước (QR)',
              icon: Icons.qr_code_scanner,
              onPressed: () => AppRouter.goToQRScanner(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.isEmpty || value == 'null' || value == 'Chưa có') {
      return const SizedBox.shrink();
    }
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextConstants.appTextRegular.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: TextConstants.appTextRegular.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
