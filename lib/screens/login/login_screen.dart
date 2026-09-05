import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/custom_text_field.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';
import 'package:attendancebyface/core/app_config.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/services/organization_service.dart';
import 'package:attendancebyface/core/cubits/login_cubit.dart';
import 'package:attendancebyface/core/cubits/login_state.dart';
import 'package:attendancebyface/core/widgets/custom_footer.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/models/biometric_account.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit()..init(context),
      child: const _LoginScreenView(),
    );
  }
}

class _LoginScreenView extends StatefulWidget {
  const _LoginScreenView();

  @override
  State<_LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearErrorOnInput);
    _passwordController.addListener(_clearErrorOnInput);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearErrorOnInput);
    _passwordController.removeListener(_clearErrorOnInput);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearErrorOnInput() {
    final cubit = context.read<LoginCubit>();
    if (cubit.state.errorMessage != null) cubit.clearError();
  }

  void _applyPrefillUsername(LoginState state) {
    if (state.prefillUsername.isNotEmpty &&
        _usernameController.text != state.prefillUsername) {
      _usernameController.text = state.prefillUsername;
    }
  }

  Future<void> _prepareTrialAndLogin() async {
    final cubit = context.read<LoginCubit>();
    final target = OrganizationService.normalizeBaseUrl(
      AppConfig.defaultBaseUrl,
    );
    OrganizationUnit? match;
    for (final u in cubit.state.units) {
      if (OrganizationService.normalizeBaseUrl(u.url) == target) {
        match = u;
        break;
      }
    }
    if (match != null) {
      await cubit.selectUnit(match);
    } else {
      await OrganizationService.applyBaseUrl(AppConfig.defaultBaseUrl);
    }
    if (!mounted) return;
    _usernameController.text = AppConfig.trialLoginUsername;
    _passwordController.text = AppConfig.trialLoginPassword;
    cubit.login(AppConfig.trialLoginUsername, AppConfig.trialLoginPassword);
  }

  void _showForgotPasswordSheet() {
    SamcomSheet.show<void>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return SamcomSheet(
          icon: Icons.lock_reset_outlined,
          title: 'Thông báo',
          subtitle: 'Liên hệ với admin để khôi phục mật khẩu.',
          primaryColor: colorScheme.primary,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              8,
              24,
              24 + MediaQuery.paddingOf(ctx).bottom,
            ),
            child: CustomButton(
              text: 'Đã hiểu',
              icon: Icons.check,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
    );
  }

  /// Xác thực sinh trắc học rồi đăng nhập bằng tài khoản đã lưu.
  Future<void> _loginWithSavedAccount(BiometricAccount account) async {
    try {
      final canCheck =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (canCheck) {
        final ok = await _localAuth.authenticate(
          localizedReason: 'Xác thực để đăng nhập',
        );
        if (!ok) return;
      }
    } catch (_) {
      // Thiết bị không hỗ trợ → tiếp tục không cần sinh trắc học
    }
    if (!mounted) return;
    await context.read<LoginCubit>().authenticateWithBiometric(account);
  }

  String? _resolveAvatarUrl(BiometricAccount account) {
    if (account.avatar.isEmpty) return null;
    if (account.avatar.startsWith('http')) return account.avatar;
    if (account.baseUrl.isEmpty) return null;
    final base = account.baseUrl.endsWith('/')
        ? account.baseUrl
        : '${account.baseUrl}/';
    final path = account.avatar.startsWith('/')
        ? account.avatar.substring(1)
        : account.avatar;
    return '$base$path';
  }

  /// Avatar tài khoản đã lưu đặt bên trái nút Đăng nhập.
  /// Nhấn vào → xác thực sinh trắc học → đăng nhập.
  Widget _buildAvatarLoginButton(BiometricAccount account, bool isLoading) {
    final avatarUrl = _resolveAvatarUrl(account);
    final size = ButtonConstants.heightButton;

    return Tooltip(
      message:
          'Đăng nhập: ${account.name.isNotEmpty ? account.name : account.username}',
      child: InkWell(
        onTap: isLoading ? null : () => _loginWithSavedAccount(account),
        borderRadius: BorderRadius.circular(size / 2),
        child: ClipOval(
          child: SizedBox(
            width: size,
            height: size,
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _avatarFallback(size, account),
                  )
                : _avatarFallback(size, account),
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback(double size, BiometricAccount account) {
    final primary = Theme.of(context).colorScheme.primary;
    final initial = (account.name.isNotEmpty ? account.name : account.username)
        .characters
        .first
        .toUpperCase();
    return Container(
      width: size,
      height: size,
      color: primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: primary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (prev, cur) =>
              prev.status != cur.status ||
              prev.errorMessage != cur.errorMessage,
          listener: (context, state) {
            if (state.status == LoginStatus.success && state.user != null) {
              if (state.showSuccessMessage) {
                CustomSnackbar.show(
                  context: context,
                  message: 'Đăng nhập thành công',
                  type: CustomSnackbarType.success,
                );
              }
              AppRouter.goToHome(context, state.user!);
            }
          },
        ),
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (prev, cur) =>
              prev.prefillUsername != cur.prefillUsername,
          listener: (context, state) => _applyPrefillUsername(state),
        ),
      ],
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state.status == LoginStatus.loading;
          final cubit = context.read<LoginCubit>();
          // Chỉ lấy tài khoản duy nhất đã lưu (nếu có)
          final savedAccount = state.biometricAccounts.isNotEmpty
              ? state.biometricAccounts.first
              : null;

          return LoadingOverlay(
            isLoading: isLoading,
            child: Scaffold(
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.asset(
                                  AppConfig.logoApp,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chấm công'.toUpperCase(),
                            style: TextConstants.appTextBold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Công ty TNHH MTV Trắc địa Bản đồ - Cục Tác chiến',
                            style: TextConstants.appTextRegular.copyWith(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          if (state.units.isNotEmpty) ...[
                            CustomDropdown<OrganizationUnit>(
                              labelText: 'Chọn đơn vị',
                              value: state.selectedUnit,
                              items: state.units
                                  .map(
                                    (u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (u) {
                                if (u != null) cubit.selectUnit(u);
                              },
                              validator: (v) =>
                                  v == null ? 'Vui lòng chọn đơn vị' : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          CustomTextField(
                            label: 'Tên đăng nhập',
                            hint: 'Nhập tên đăng nhập của bạn',
                            prefixIcon: Icons.person_outline,
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên đăng nhập';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu của bạn',
                            prefixIcon: Icons.lock_outline,
                            fieldType: CustomTextFieldType.password,
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomButton(
                              text: 'Quên mật khẩu',
                              variant: CustomButtonVariant.textButton,
                              onPressed: _showForgotPasswordSheet,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorConstants.errorColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  ColorConstants.defaultBorderRadius,
                                ),
                                border: Border.all(
                                  color: ColorConstants.errorColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                state.errorMessage!,
                                style: TextConstants.appTextBold.copyWith(
                                  color: ColorConstants.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Hàng: Avatar (sinh trắc học) + nút Đăng nhập
                          Row(
                            children: [
                              if (savedAccount != null) ...[
                                _buildAvatarLoginButton(
                                  savedAccount,
                                  isLoading,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: CustomButton(
                                  text: 'Đăng nhập',
                                  icon: Icons.login,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            cubit.login(
                                              _usernameController.text,
                                              _passwordController.text,
                                            );
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Trải nghiệm ứng dụng? ',
                                style: TextConstants.appTextRegular.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              CustomButton(
                                text: 'Thử ngay!',
                                variant: CustomButtonVariant.textButton,
                                onPressed: _prepareTrialAndLogin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [CustomFooter(), SizedBox(height: 8)],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
