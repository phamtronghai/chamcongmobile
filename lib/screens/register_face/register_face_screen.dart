import 'dart:io';
import 'dart:math' as math;

import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/gradient_ring.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';
import 'package:attendancebyface/gen/assets.gen.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _FaceStep {
  final String shortLabel;
  final String chipLabel;
  final String hint;

  const _FaceStep({
    required this.shortLabel,
    required this.chipLabel,
    required this.hint,
  });
}

class RegisterFaceScreen extends StatefulWidget {
  final UserModel user;

  const RegisterFaceScreen({super.key, required this.user});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen>
    with SingleTickerProviderStateMixin {
  static const int _slotCount = 3;
  static const List<_FaceStep> _steps = [
    _FaceStep(
      shortLabel: 'Chính diện',
      chipLabel: '1. Chính diện',
      hint: 'Nhìn thẳng vào màn hình, giữ biểu cảm tự nhiên',
    ),
    _FaceStep(
      shortLabel: 'Nghiêng trái',
      chipLabel: '2. Nghiêng trái',
      hint: 'Nghiêng nhẹ mặt sang trái (~30°), nhìn vào camera',
    ),
    _FaceStep(
      shortLabel: 'Nghiêng phải',
      chipLabel: '3. Nghiêng phải',
      hint: 'Nghiêng nhẹ mặt sang phải (~30°), nhìn vào camera',
    ),
  ];

  final List<File?> _slots = List<File?>.filled(_slotCount, null);
  final FaceService _faceService = locator<FaceService>();

  late final TabController _tabController;
  bool _isLoading = false;

  int get _currentPage => _tabController.index;

  int get _filledCount => _slots.whereType<File>().length;

  bool get _allFilled => _filledCount == _slotCount;

  bool get _currentHasImage => _slots[_currentPage] != null;

  _FaceStep get _currentStep => _steps[_currentPage];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _slotCount, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _faceService.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    CustomSnackbar.show(
      context: context,
      message: message,
      type: error ? CustomSnackbarType.error : CustomSnackbarType.success,
    );
  }

  Future<void> _goToPage(int index) async {
    if (index < 0 || index >= _slotCount || index == _currentPage) return;
    _tabController.animateTo(index);
  }

  Future<File?> _captureFaceImage() async {
    final livenessResult = await _faceService.detectLivenessWithCamera(context);
    // Hủy / lỗi camera (đã snackbar ở CameraScreen) — không toast thêm.
    if (livenessResult.imageBytes == null) {
      return null;
    }
    if (!livenessResult.isReal) {
      _toast(
        'Không thể xác minh khuôn mặt thật. Vui lòng thử lại!',
        error: true,
      );
      return null;
    }
    final imageBytes = _faceService.getLastCapturedImage();
    if (imageBytes == null) return null;
    final imageFile = File(
      '${Directory.systemTemp.path}/face_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }

  Future<void> _takePictureForCurrentSlot() async {
    if (!mounted || _isLoading) return;

    final slotIndex = _currentPage;
    setState(() => _isLoading = true);

    try {
      final imageFile = await _captureFaceImage();
      if (!mounted) return;

      if (imageFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _slots[slotIndex] = imageFile;
        _isLoading = false;
      });
      _toast('Đã chụp ${_steps[slotIndex].shortLabel.toLowerCase()}!');

      if (slotIndex < _slotCount - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        await _goToPage(slotIndex + 1);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast('Lỗi chụp ảnh khuôn mặt: $e', error: true);
    }
  }

  Future<void> _submitForm() async {
    if (!_allFilled) {
      _toast('Bạn phải chụp đủ 3 ảnh khuôn mặt để đăng ký.', error: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final images = _slots.whereType<File>().toList();
      await _faceService.registerFace(images: images);
      if (!mounted) return;

      context.read<UserCubit>().updateFaceRegistrationStatus(true);
      _toast('Đã đăng ký khuôn mặt thành công!');

      if (mounted) {
        AppRouter.goToHome(context, widget.user);
      }
    } catch (_) {
      if (!mounted) return;
      _toast('Đăng ký thất bại! Liên hệ admin để trợ giúp.', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStepTabs() {
    return SamcomTabBar(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextConstants.appTextBold.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      unselectedLabelStyle: TextConstants.appTextBold.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tabs: [
        for (var i = 0; i < _slotCount; i++)
          Tab(
            text: _slots[i] != null
                ? '✓ ${_steps[i].shortLabel}'
                : _steps[i].chipLabel,
          ),
      ],
    );
  }

  Widget _buildFaceFrame(double size, int index) {
    final file = _slots[index];
    final hasImage = file != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GradientAvatarRing(
              size: size,
              outerPadding: 4,
              innerPadding: 3,
              child: ClipOval(
                child: hasImage
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                      )
                    : ColoredBox(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                        child: CustomPaint(
                          painter: _ViewfinderPainter(
                            color: colorScheme.primary.withValues(alpha: 0.55),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: 0.5,
                              child: Assets.icon.faceID.svg(
                                width: size * 0.26,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (!hasImage)
              IgnorePointer(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _DashedCirclePainter(
                    color: colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidance() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          _currentStep.hint,
          textAlign: TextAlign.center,
          style: TextConstants.appTextSemiBold.copyWith(
            color: colorScheme.onSurface,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Giữ khuôn mặt trong khung hình, nơi đủ sáng, tháo kính râm/khẩu trang',
          textAlign: TextAlign.center,
          style: TextConstants.appTextRegular.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(
            ColorConstants.defaultBorderRadius,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 16),
            Text('Đang xử lý...', style: TextConstants.appTextMedium),
          ],
        ),
      );
    }

    if (_allFilled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_currentHasImage) ...[
            CustomButton(
              text: 'Chụp lại · ${_currentStep.shortLabel}',
              icon: Icons.refresh,
              variant: CustomButtonVariant.normalButton,
              onPressed: _takePictureForCurrentSlot,
            ),
            const SizedBox(height: 12),
          ],
          CustomButton(
            text: 'Hoàn tất đăng ký',
            icon: Icons.check,
            onPressed: _submitForm,
          ),
        ],
      );
    }

    if (_currentHasImage) {
      return CustomButton(
        text: 'Chụp lại · ${_currentStep.shortLabel}',
        icon: Icons.refresh,
        variant: CustomButtonVariant.normalButton,
        onPressed: _takePictureForCurrentSlot,
      );
    }

    return CustomButton(
      text: 'Chụp ảnh · ${_currentStep.shortLabel}',
      icon: Icons.camera_alt,
      onPressed: _takePictureForCurrentSlot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final frameSize = screenWidth * 0.68;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Đăng ký khuôn mặt'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepTabs(),
                    const SizedBox(height: 16),
                    Text(
                      'Đã chụp: $_filledCount/$_slotCount',
                      textAlign: TextAlign.center,
                      style: TextConstants.appTextMedium.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: frameSize,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          for (var i = 0; i < _slotCount; i++)
                            _buildFaceFrame(frameSize, i),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGuidance(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _buildBottomActions(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Viền nét đứt quanh placeholder.
class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 6;
    const dashLength = 8.0;
    const gapLength = 6.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final sweep = (2 * math.pi) / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * (dashLength / (dashLength + gapLength)),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 4 góc khung ngắm (viewfinder).
class _ViewfinderPainter extends CustomPainter {
  final Color color;

  _ViewfinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final inset = size.width * 0.18;
    final arm = size.width * 0.12;
    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    // Top-left
    canvas.drawLine(Offset(left, top), Offset(left + arm, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + arm), paint);
    // Top-right
    canvas.drawLine(Offset(right, top), Offset(right - arm, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(left, bottom), Offset(left + arm, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - arm), paint);
    // Bottom-right
    canvas.drawLine(Offset(right, bottom), Offset(right - arm, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - arm), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
