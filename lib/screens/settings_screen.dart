import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/storage/secure_storage.dart';
import 'package:attendancebyface/widgets/custom_password_dialog.dart';
import 'package:attendancebyface/widgets/change_password_dialog.dart';
// import 'package:attendancebyface/core/constants/color_constants.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:attendancebyface/widgets/theme_selection_dialog.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        // Cập nhật local state khi UserCubit thay đổi
        if (state is UserLoaded) {
          // Không cần làm gì vì _SettingsScreenContent sẽ tự động rebuild
        }
      },
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return state.when(
            initial: () => const LoadingOverlay(
              isLoading: true,
              child: Scaffold(body: Center(child: CircularProgressIndicator())),
            ),
            loading: () => const LoadingOverlay(
              isLoading: true,
              child: Scaffold(body: Center(child: CircularProgressIndicator())),
            ),
            loaded: (user) => _SettingsScreenContent(user: user),
            error: (message) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi khi tải dữ liệu'),
                    const SizedBox(height: 8),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<UserCubit>().refresh(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsScreenContent extends StatefulWidget {
  final UserModel user;

  const _SettingsScreenContent({required this.user});

  @override
  State<_SettingsScreenContent> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreenContent> {
  late UserModel _user;
  bool _isFaceRegistered = false;
  bool _isLoading = true;
  String _appVersion = 'Đang tải...';
  String _buildNumber = 'Đang tải...';
  // Đã chuyển xử lý căn cước sang PersonalInfoScreen
  final FaceService _faceService = FaceService();
  final AuthService _authService = AuthService(baseUrl: AppConfig.apiBaseUrl);
  // Removed avatar update concerns from Settings (moved to PersonalInfoScreen)
  AdaptiveThemeMode _themeMode = AdaptiveThemeMode.system;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _isFaceRegistered = widget.user.isFaceRegistered;
    // Đã chuyển xử lý căn cước sang PersonalInfoScreen
    _fetchUserData();
    _checkFaceRegisteredStatus();
    _checkCitizenRegistration();
    _loadAppVersion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật trạng thái khi quay lại từ màn hình khác
    _updateFromUserCubit();
    // Load theme mode sau khi dependencies đã sẵn sàng
    _loadThemeMode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadThemeMode() async {
    final currentThemeMode = AdaptiveTheme.of(context).mode;
    setState(() {
      _themeMode = currentThemeMode;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy thông tin version: $e');
      if (mounted) {
        setState(() {
          _appVersion = 'Không xác định';
          _buildNumber = 'Không xác định';
        });
      }
    }
  }

  Future<void> _changeThemeMode(AdaptiveThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });

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

    if (mounted) {
      CustomSnackbar.show(
        context: context,
        message: 'Đã thay đổi chế độ giao diện',
        type: CustomSnackbarType.success,
      );
    }
  }

  Future<void> _openStore() async {
    final platform = Theme.of(context).platform;
    final url = platform == TargetPlatform.iOS
        ? AppConfig.iosAppStoreUrl
        : AppConfig.androidPlayStoreUrl;
    final uri = Uri.parse(url);

    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Không thể mở cửa hàng ứng dụng',
          type: CustomSnackbarType.error,
        );
      }
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      CustomSnackbar.show(
        context: context,
        message: 'Không thể mở cửa hàng ứng dụng',
        type: CustomSnackbarType.error,
      );
    }
  }

  void _fetchUserData() {
    final userCubit = context.read<UserCubit>();
    final user = userCubit.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _isFaceRegistered = user.isFaceRegistered;
        // Đã chuyển xử lý căn cước sang PersonalInfoScreen
      });
    }
  }

  /// Cập nhật local state từ UserCubit
  void _updateFromUserCubit() {
    final userCubit = context.read<UserCubit>();
    final user = userCubit.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _isFaceRegistered = user.isFaceRegistered;
        // Đã chuyển xử lý căn cước sang PersonalInfoScreen
      });
    }
  }

  void _checkCitizenRegistration() {
    // Đã chuyển logic và hiển thị sang PersonalInfoScreen; ở đây chỉ cập nhật loading
    setState(() {
      _isLoading = false;
    });
  }

  void _checkFaceRegisteredStatus() {
    final userCubit = context.read<UserCubit>();
    final isFaceRegistered = userCubit.isFaceRegistered;

    setState(() {
      _isFaceRegistered = isFaceRegistered;
    });
  }

  // Đã bỏ hỏi mật khẩu khi bật biometric vì thông tin đã được lưu sau đăng nhập

  Future<void> _deleteFaceData() async {
    try {
      // Gọi API xóa khuôn mặt trên server
      await _faceService.deleteFace(_user.id);
      final isRegistered = await _faceService.checkRegistered(_user.id);

      if (mounted) {
        // Cập nhật local state
        setState(() {
          _isFaceRegistered = isRegistered;
        });

        // Cập nhật UserCubit
        context.read<UserCubit>().updateFaceRegistrationStatus(isRegistered);

        CustomSnackbar.show(
          context: context,
          message: 'Đã xóa dữ liệu khuôn mặt thành công!',
          type: CustomSnackbarType.success,
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa dữ liệu khuôn mặt: $e');
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi: ${e.toString()}',
          type: CustomSnackbarType.error,
        );
      }
    } finally {
      // Cleanup nếu cần
    }
  }

  // Phương thức đăng xuất mới, xóa thông tin đăng nhập đã lưu
  Future<void> _logout() async {
    try {
      // Hiển thị loading
      setState(() {
        _isLoading = true;
      });

      // 1. Xóa thông tin đăng nhập trong SecureStorage
      await SecureStorage.removeAuthToken();

      // 2. Hủy đăng ký FCM token
      await NotificationService.instance.unregisterFcmToken();

      // 3. KHÔNG xóa thông tin sinh trắc học để giữ lại khả năng đăng nhập bằng sinh trắc học
      // Chỉ xóa thông tin đăng nhập thông thường

      // 4. Gọi API đăng xuất
      final authService = AuthService(baseUrl: AppConfig.apiBaseUrl);
      await authService.logout();

      // 5. Hiển thị thông báo thành công
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Đăng xuất thành công',
          type: CustomSnackbarType.success,
        );
      }

      // 6. Chuyển về màn hình đăng nhập
      if (mounted) {
        AppRouter.goToLogin(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi đăng xuất: $e');
      // Xử lý trường hợp lỗi - vẫn xóa dữ liệu local và chuyển về màn hình đăng nhập
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Lỗi: ${e.toString()}',
          type: CustomSnackbarType.warning,
        );
        AppRouter.goToLogin(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getAvatarUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    // Dùng baseUrl hiện tại của app (đã chọn theo đơn vị)
    // Sử dụng baseUrl từ ApiClient nếu cần; ở Settings không còn dùng _apiClient nữa
    final base = ApiClient().dio.options.baseUrl;
    final hasTrailingSlash = base.endsWith('/');
    final hasLeadingSlash = image.startsWith('/');
    final normalizedBase = hasTrailingSlash
        ? base.substring(0, base.length - 1)
        : base;
    final normalizedPath = hasLeadingSlash ? image : '/$image';
    return '$normalizedBase$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          _updateFromUserCubit();
        }
      },
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Đang đăng xuất...',
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Cài đặt',
            automaticallyImplyLeading: false,
            onNotificationTap: () {
              AppRouter.goToNotification(context, widget.user);
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onLongPress: _isFaceRegistered
                      ? () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => CustomPasswordDialog(
                              title: 'Xóa khuôn mặt',
                              label: 'Nhập mật khẩu',
                              hint: 'Nhập mật khẩu để xác nhận',
                            ),
                          );
                          if (result == AppConfig.adminPassword) {
                            _deleteFaceData();
                          } else if (result != null &&
                              result.isNotEmpty &&
                              context.mounted) {
                            CustomSnackbar.show(
                              context: context,
                              message: 'Mật khẩu không đúng!',
                              type: CustomSnackbarType.error,
                            );
                          }
                        }
                      : null,
                  child: SettingsOptionTile(
                    icon: Icons.verified,
                    text: 'Đăng ký khuôn mặt',
                    subtitle: _isFaceRegistered ? "Đã đăng ký" : "Chưa đăng ký",
                    onTap: () {
                      if (!_isFaceRegistered) {
                        AppRouter.goToRegisterFace(context, _user);
                      }
                    },
                    showArrow: !_isFaceRegistered,
                  ),
                ),
                const SizedBox(height: 12),
                SettingsOptionTile(
                  icon: _getThemeIcon(),
                  text: 'Giao diện',
                  subtitle: _getThemeSubtitle(),
                  onTap: _showThemeDialog,
                  showArrow: true,
                ),
                const SizedBox(height: 12),
                SettingsOptionTile(
                  icon: Icons.lock_reset,
                  text: 'Đổi mật khẩu',
                  subtitle: 'Cập nhật mật khẩu tài khoản',
                  onTap: _showChangePasswordDialog,
                  showArrow: true,
                ),
                const SizedBox(height: 12),
                SettingsOptionTile(
                  icon: Icons.system_update_alt,
                  text: 'Cập nhật ứng dụng',
                  subtitle: 'Mở App Store hoặc Google Play',
                  onTap: _openStore,
                  showArrow: true,
                ),
                const SizedBox(height: 12),
                SettingsOptionTile(
                  icon: Icons.info_outline,
                  text: 'Phiên bản',
                  subtitle: '$_appVersion (Build $_buildNumber)',
                  showArrow: false,
                ),
                const SizedBox(height: 12),
                SettingsOptionTile(
                  icon: Icons.logout,
                  text: 'Đăng xuất',
                  onTap: _logout,
                  textColor: Theme.of(context).colorScheme.tertiary,
                  iconColor: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeSubtitle() {
    switch (_themeMode) {
      case AdaptiveThemeMode.light:
        return 'Chủ đề sáng';
      case AdaptiveThemeMode.dark:
        return 'Chủ đề tối';
      case AdaptiveThemeMode.system:
        return 'Chủ đề theo hệ thống';
    }
  }

  IconData _getThemeIcon() {
    switch (_themeMode) {
      case AdaptiveThemeMode.light:
        return Icons.light_mode;
      case AdaptiveThemeMode.dark:
        return Icons.dark_mode;
      case AdaptiveThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThemeSelectionDialog(
          currentThemeMode: _themeMode,
          onThemeChanged: _changeThemeMode,
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangePasswordDialog(
          onConfirm: _changePassword,
          onSuccess:
              _logout, // Thực hiện đăng xuất sau khi đổi mật khẩu thành công
        );
      },
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

    if (mounted) {
      // Không hiển thị thông báo thành công vì sẽ tự động đăng xuất
      // Callback onSuccess sẽ được gọi để thực hiện đăng xuất
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// Widget chung cho các option trong Settings
class SettingsOptionTile extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String text;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? textColor;
  final Color? iconColor;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const SettingsOptionTile({
    super.key,
    this.icon,
    this.svgPath,
    required this.text,
    this.subtitle,
    this.onTap,
    this.showArrow = false,
    this.textColor,
    this.iconColor,
    this.switchValue,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedTextColor =
        textColor ??
        Theme.of(context).textTheme.bodyLarge?.color ??
        Colors.black;
    final Color resolvedIconColor =
        iconColor ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: resolvedIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath!,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        resolvedIconColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(icon, color: resolvedIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: resolvedTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: resolvedTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            if (onSwitchChanged != null && switchValue != null)
              Switch(
                value: switchValue!,
                onChanged: onSwitchChanged,
                activeThumbColor: Theme.of(context).colorScheme.primary,
              )
            else if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: resolvedTextColor.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
