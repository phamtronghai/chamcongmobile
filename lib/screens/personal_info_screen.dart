import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:attendancebyface/core/network/api_client.dart';
import 'package:attendancebyface/widgets/profile_update_dialog.dart';
import 'package:attendancebyface/core/app_router.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late UserModel _user;
  bool _isUpdatingAvatar = false;
  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient();

  // State cho việc thu gọn/mở rộng sections
  bool _isBasicInfoExpanded = true;
  bool _isCitizenInfoExpanded = false;

  @override
  void initState() {
    super.initState();
    _user = context.read<UserCubit>().currentUser!;
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

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thông tin cá nhân',
        showAvatar: false,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppRouter.goBack(context),
        ),
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
                    isExpanded: _isBasicInfoExpanded,
                    onToggle: () {
                      setState(() {
                        _isBasicInfoExpanded = !_isBasicInfoExpanded;
                      });
                    },
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
                    title: 'Thông tin căn cước công dân',
                    icon: Icons.credit_card,
                    isExpanded: _isCitizenInfoExpanded,
                    onToggle: () {
                      setState(() {
                        _isCitizenInfoExpanded = !_isCitizenInfoExpanded;
                      });
                    },
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
                              color: colorScheme.outline.withValues(alpha: 0.2),
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title header với background khác và nút mũi tên
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - chỉ hiện khi expanded
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w300,
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
