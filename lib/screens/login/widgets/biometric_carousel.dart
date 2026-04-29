import 'package:flutter/material.dart';
import 'package:attendancebyface/models/biometric_account.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/utils/biometric_helper.dart';
import 'package:local_auth/local_auth.dart';

class BiometricCarousel extends StatelessWidget {
  final List<BiometricAccount> accounts;
  final BiometricAccount? selectedAccount;
  final PageController? pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<BiometricAccount> onDeleteAccount;
  final VoidCallback onAuthenticate;
  final VoidCallback onSwitchToTraditional;
  final bool isLoading;

  const BiometricCarousel({
    super.key,
    required this.accounts,
    required this.selectedAccount,
    required this.pageController,
    required this.onPageChanged,
    required this.onDeleteAccount,
    required this.onAuthenticate,
    required this.onSwitchToTraditional,
    required this.isLoading,
  });

  Widget _buildAccountCard(BuildContext context, BiometricAccount account) {
    // Xử lý avatar URL
    String? processedAvatarUrl;
    if (account.avatar.isNotEmpty) {
      if (account.avatar.startsWith('http')) {
        processedAvatarUrl = account.avatar;
      } else if (account.baseUrl.isNotEmpty) {
        final normalizedBaseUrl = account.baseUrl.endsWith('/')
            ? account.baseUrl
            : '${account.baseUrl}/';
        final normalizedAvatarPath = account.avatar.startsWith('/')
            ? account.avatar.substring(1)
            : account.avatar;
        processedAvatarUrl = '$normalizedBaseUrl$normalizedAvatarPath';
      } else {
        processedAvatarUrl = account.avatar;
      }
    }

    return Column(
      children: [
        // Avatar với nút xóa
        Stack(
          children: [
            GradientAvatarRing(
              size: 120,
              outerPadding: 3,
              innerPadding: 1,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage:
                    (processedAvatarUrl != null && processedAvatarUrl.isNotEmpty)
                        ? NetworkImage(processedAvatarUrl)
                        : null,
                child: (processedAvatarUrl == null || processedAvatarUrl.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
            ),
            // Nút xóa ở góc dưới bên phải
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => onDeleteAccount(account),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tên user
        Text(
          account.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Đơn vị
        if (account.organizationName.isNotEmpty)
          Text(
            'Đơn vị: ${account.organizationName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Carousel danh sách tài khoản
        SizedBox(
          height: 250,
          child: pageController != null
              ? PageView.builder(
                  controller: pageController,
                  itemCount: accounts.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildAccountCard(context, account),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),

        // Page indicator (nếu có nhiều hơn 1 tài khoản)
        if (accounts.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              accounts.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedAccount?.id == accounts[index].id
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Nút đăng nhập sinh trắc học
        FutureBuilder<BiometricType?>(
          future: BiometricHelper.getPrimaryBiometricType(),
          builder: (context, snapshot) {
            IconData? iconData;
            String? svgPath;

            if (snapshot.hasData && snapshot.data != null) {
              final biometricType = snapshot.data!;
              final info = BiometricHelper.getBiometricInfo(biometricType);
              iconData = info['icon'] as IconData?;
              svgPath = info['svgPath'] as String?;
            } else {
              iconData = Icons.fingerprint; // Default icon
            }

            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: CustomButton(
                  text: 'Đăng nhập',
                  onPressed: isLoading ? null : onAuthenticate,
                  textColor: Colors.white,
                  icon: iconData,
                  svgPath: svgPath,
                  isLoading: isLoading,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Nút "Tài khoản khác"
        CustomButton(
          text: 'Tài khoản khác',
          onPressed: onSwitchToTraditional,
          variant: CustomButtonVariant.iconCircle,
          icon: Icons.arrow_forward,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          tooltip: 'Chuyển sang đăng nhập thông thường',
        ),
      ],
    );
  }
}
