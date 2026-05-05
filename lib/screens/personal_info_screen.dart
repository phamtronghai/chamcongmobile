import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/screens/personal_info/widgets/profile_update_dialog.dart';
import 'package:attendancebyface/screens/personal_info/widgets/change_password_dialog.dart';
import 'package:attendancebyface/screens/personal_info/widgets/custom_password_dialog.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/gen/assets.gen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late UserModel _user;
  bool _isUpdatingAvatar = false;
  bool _isLoading = false;
  bool _isFaceRegistered = false;
  AdaptiveThemeMode _themeMode = AdaptiveThemeMode.system;
  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  final FaceService _faceService = FaceService();
  final AuthService _authService = AuthService(baseUrl: AppConfig.apiBaseUrl);

  @override
  void initState() {
    super.initState();
    _user = context.read<UserCubit>().currentUser!;
    _isFaceRegistered = _user.isFaceRegistered;
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

  Future<void> _changeThemeMode(AdaptiveThemeMode mode) async {
    setState(() => _themeMode = mode);
    switch (mode) {
      case AdaptiveThemeMode.light:
        AdaptiveTheme.of(context).setLight();
        break;
      case AdaptiveThemeMode.dark:
        AdaptiveTheme.of(context).setDark();
        break;
      case AdaptiveThemeMode.system:
        AdaptiveTheme.of(context).setSystem();
        break;
    }
    if (!mounted) return;
    CustomSnackbar.show(
      context: context,
      message: 'Đã thay đổi chế độ giao diện',
      type: CustomSnackbarType.success,
    );
  }

  Future<void> _toggleThemeMode() async {
    final nextMode = switch (_themeMode) {
      AdaptiveThemeMode.light => AdaptiveThemeMode.dark,
      AdaptiveThemeMode.dark => AdaptiveThemeMode.system,
      AdaptiveThemeMode.system => AdaptiveThemeMode.light,
    };
    await _changeThemeMode(nextMode);
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

  Color _themeModeColor(ColorScheme colorScheme) {
    return switch (_themeMode) {
      AdaptiveThemeMode.light => Colors.amber.shade700,
      AdaptiveThemeMode.dark => Colors.indigo.shade300,
      AdaptiveThemeMode.system => colorScheme.primary,
    };
  }

  Future<void> _handleRegisterFace() async {
    if (_isFaceRegistered) {
      CustomSnackbar.show(
        context: context,
        message: 'Khuôn mặt đã được đăng ký. Nhấn giữ để xóa đăng ký.',
        type: CustomSnackbarType.info,
      );
      return;
    }
    AppRouter.goToRegisterFace(context, _user);
  }

  Future<void> _handleDeleteFaceByLongPress() async {
    if (!_isFaceRegistered) return;
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CustomPasswordDialog(
        title: 'Xóa khuôn mặt',
        label: 'Nhập mật khẩu',
        hint: 'Nhập mật khẩu để xác nhận',
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    if (result != AppConfig.adminPassword) {
      CustomSnackbar.show(
        context: context,
        message: 'Mật khẩu không đúng!',
        type: CustomSnackbarType.error,
      );
      return;
    }
    await _deleteFaceData();
  }

  Future<void> _deleteFaceData() async {
    try {
      setState(() => _isLoading = true);
      await _faceService.deleteFace(_user.id);
      final isRegistered = await _faceService.checkRegistered(_user.id);
      if (!mounted) return;
      setState(() => _isFaceRegistered = isRegistered);
      context.read<UserCubit>().updateFaceRegistrationStatus(isRegistered);
      CustomSnackbar.show(
        context: context,
        message: 'Đã xóa dữ liệu khuôn mặt thành công!',
        type: CustomSnackbarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Lỗi: ${e.toString()}',
        type: CustomSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          ChangePasswordDialog(onConfirm: _changePassword, onSuccess: _logout),
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color? color,
    String? logoAssetPath,
    /// Nền tròn đặc (vd. đăng xuất); null thì dùng [color] mờ như cũ.
    Color? circleBackgroundColor,
    /// Màu icon; null thì trùng [color]/primary.
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final Color actionColor = color ?? theme.colorScheme.primary;
    final Color circleFill =
        circleBackgroundColor ?? actionColor.withValues(alpha: 0.12);
    final Color resolvedIconColor = iconColor ?? actionColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: circleFill,
                  shape: BoxShape.circle,
                ),
                child: logoAssetPath != null
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: logoAssetPath.toLowerCase().endsWith('.svg')
                            ? SvgPicture.asset(
                                logoAssetPath,
                                fit: BoxFit.contain,
                              )
                            : Image.asset(logoAssetPath, fit: BoxFit.contain),
                      )
                    : Icon(icon, color: resolvedIconColor, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: actionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            final parsed = response.data as String;
            final map = jsonDecode(parsed) as Map<String, dynamic>;
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
    final hasTrailing = base.endsWith('/');
    final hasLeading = value.startsWith('/');
    final normalizedBase = hasTrailing
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = hasLeading ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  void _showUpdateProfileDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => ProfileUpdateDialog(
        initialName: _user.name,
        initialPhone: _user.phone,
      ),
    );

    if (result != null) {
      await _updateUserProfile(result['name']!, result['phone']!);
    }
  }

  Future<void> _updateUserProfile(String newName, String newPhone) async {
    try {
      // Cập nhật local state
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Đang xử lý...',
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Thông tin cá nhân',
          automaticallyImplyLeading: false,
          onNotificationTap: () => AppRouter.goToNotification(context, _user),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section với gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Avatar Section
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GradientAvatarRing(
                            size: 120,
                            outerPadding: 4,
                            innerPadding: 3,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: colorScheme.surface,
                              backgroundImage: _user.image.isNotEmpty
                                  ? NetworkImage(_user.image)
                                  : null,
                              child: _user.image.isEmpty
                                  ? Icon(
                                      Icons.account_circle,
                                      size: 60,
                                      color: colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                          // Camera button
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _isUpdatingAvatar ? null : _changeAvatar,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary,
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isUpdatingAvatar
                                    ? const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // User Info
                      Text(
                        _user.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user.email,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            _buildQuickAction(
                              icon: Icons.verified_user_outlined,
                              logoAssetPath: Assets.icon.faceID.path,
                              label: _isFaceRegistered
                                  ? 'Đã đăng ký'
                                  : 'Chưa đăng ký',
                              onTap: _handleRegisterFace,
                              onLongPress: _handleDeleteFaceByLongPress,
                              color: _isFaceRegistered
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            _buildQuickAction(
                              icon: _themeModeIcon(),
                              label: _themeModeLabel(),
                              onTap: _toggleThemeMode,
                              color: _themeModeColor(colorScheme),
                            ),
                            _buildQuickAction(
                              icon: Icons.lock_reset,
                              label: 'Mật khẩu',
                              onTap: _showChangePasswordDialog,
                            ),
                            _buildQuickAction(
                              icon: Icons.logout,
                              label: 'Đăng xuất',
                              onTap: _logout,
                              color: ColorConstants.errorColor,
                              circleBackgroundColor: ColorConstants.errorColor,
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin cơ bản
                    _buildSectionCard(
                      context: context,
                      title: 'Thông tin cơ bản',
                      icon: Icons.person_outline,
                      initiallyExpanded: true,
                      children: [
                        _buildInfoCard(
                          context,
                          icon: Icons.business,
                          label: 'Phòng ban',
                          value: _user.department,
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.work,
                          label: 'Chức vụ',
                          value: _user.position,
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.phone,
                          label: 'Số điện thoại',
                          value: _user.phone ?? '',
                        ),
                        const SizedBox(height: 16),
                        // Nút cập nhật thông tin
                        CustomButton(
                          text: 'Cập nhật thông tin',
                          backgroundColor: colorScheme.primary,
                          onPressed: () {
                            _showUpdateProfileDialog();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Thông tin căn cước
                    _buildSectionCard(
                      context: context,
                      title: 'Thông tin căn cước',
                      icon: Icons.credit_card,
                      initiallyExpanded: false,
                      children: [
                        if (_user.citizenNumber?.isNotEmpty == true) ...[
                          _buildInfoCard(
                            context,
                            icon: Icons.badge_outlined,
                            label: 'Số căn cước',
                            value: _user.citizenNumber!,
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.credit_card_outlined,
                            label: 'Số CMT cũ',
                            value: _user.oldIdNumber ?? '',
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.person_outline_rounded,
                            label: 'Họ và tên',
                            value: _user.fullNameOnCitizen!,
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.cake_outlined,
                            label: 'Ngày sinh',
                            value: _user.dateOfBirth!,
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.person_outline,
                            label: 'Giới tính',
                            value: _user.gender!,
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.location_on_outlined,
                            label: 'Địa chỉ',
                            value: _user.address!,
                          ),
                          _buildInfoCard(
                            context,
                            icon: Icons.calendar_today_outlined,
                            label: 'Ngày cấp',
                            value: _user.issuedDate!,
                          ),
                          const SizedBox(height: 16),
                          // Action Button
                          CustomButton(
                            text: 'Cập nhật Căn cước (QR)',
                            backgroundColor: colorScheme.primary,
                            onPressed: () {
                              AppRouter.goToQRScanner(context);
                            },
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Chưa có thông tin căn cước công dân',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action Button
                          CustomButton(
                            text: 'Thêm Căn cước (QR)',
                            backgroundColor: colorScheme.primary,
                            onPressed: () {
                              AppRouter.goToQRScanner(context);
                            },
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: initiallyExpanded,
          iconColor: colorScheme.onSurface,
          collapsedIconColor: colorScheme.onSurface,
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: colorScheme.surface,
          collapsedBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    // Chỉ hiển thị khi có thông tin
    if (value.isEmpty || value == 'null' || value == 'Chưa có') {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(36),
          ),
          child: Icon(icon, size: 22, color: colorScheme.primary),
        ),
        title: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        subtitle: Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
