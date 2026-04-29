import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/cubits/login_cubit.dart';
import 'package:attendancebyface/core/cubits/login_state.dart';
import 'package:attendancebyface/screens/login/widgets/traditional_login_form.dart';
import 'package:attendancebyface/screens/login/widgets/biometric_carousel.dart';
import 'package:attendancebyface/gen/assets.gen.dart';

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
  final _pageController = PageController();

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
    _pageController.dispose();
    super.dispose();
  }

  void _clearErrorOnInput() {
    final cubit = context.read<LoginCubit>();
    if (cubit.state.errorMessage != null) {
      cubit.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginCubit, LoginState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage,
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
          listenWhen: (previous, current) =>
              previous.selectedBiometricAccount !=
              current.selectedBiometricAccount,
          listener: (context, state) {
            if (state.biometricAccounts.isNotEmpty &&
                state.selectedBiometricAccount != null) {
              final index = state.biometricAccounts.indexWhere(
                (a) => a.id == state.selectedBiometricAccount!.id,
              );
              if (index != -1 && _pageController.hasClients) {
                // Only jump if it's not already there
                if (_pageController.page?.round() != index) {
                  _pageController.jumpToPage(index);
                }
              }
            }
          },
        ),
      ],
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state.status == LoginStatus.loading;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.icon.logoAppChamCongBoTron.image(
                                height: 100,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'CHẤM CÔNG',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          if (state.biometricEnabled &&
                              !state.showAlternativeLogin) ...[
                            BiometricCarousel(
                              accounts: state.biometricAccounts,
                              selectedAccount: state.selectedBiometricAccount,
                              pageController: _pageController,
                              isLoading: isLoading,
                              onPageChanged: (index) {
                                context
                                    .read<LoginCubit>()
                                    .selectBiometricAccount(
                                      state.biometricAccounts[index],
                                    );
                              },
                              onDeleteAccount: (account) {
                                context
                                    .read<LoginCubit>()
                                    .deleteBiometricAccount(account);
                              },
                              onAuthenticate: () {
                                context
                                    .read<LoginCubit>()
                                    .authenticateWithBiometric();
                              },
                              onSwitchToTraditional: () {
                                context
                                    .read<LoginCubit>()
                                    .toggleAlternativeLogin(true);
                              },
                            ),
                          ] else ...[
                            TraditionalLoginForm(
                              units: state.units,
                              selectedUnit: state.selectedUnit,
                              onUnitChanged: (u) {
                                if (u != null) {
                                  context.read<LoginCubit>().selectUnit(u);
                                }
                              },
                              usernameController: _usernameController,
                              passwordController: _passwordController,
                              rememberAccount: state.rememberAccount,
                              onRememberAccountChanged: (value) {
                                context
                                    .read<LoginCubit>()
                                    .toggleRememberAccount(value ?? false);
                              },
                              errorMessage: state.errorMessage,
                              onLoginPressed: () {
                                context.read<LoginCubit>().login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                              },
                              biometricEnabled: state.biometricEnabled,
                              onSwitchToBiometric: () {
                                context
                                    .read<LoginCubit>()
                                    .toggleAlternativeLogin(false);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // bottomNavigationBar: const Column(
              //   mainAxisSize: MainAxisSize.min,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [CustomFooter(), SizedBox(height: 32)],
              // ),
            ),
          );
        },
      ),
    );
  }
}
