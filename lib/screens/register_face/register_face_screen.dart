import 'dart:io';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/gen/assets.gen.dart';

class RegisterFaceScreen extends StatefulWidget {
  final UserModel user;

  const RegisterFaceScreen({super.key, required this.user});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen>
    with SingleTickerProviderStateMixin {
  final List<File> _imageFiles = [];
  final PageController _pageController = PageController();
  bool _isLoading = false;
  final FaceService _faceService = locator<FaceService>();
  String _bannerMessage = 'Bạn cần đăng ký khuôn mặt để sử dụng dịch vụ!';
  bool _bannerIsError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _faceService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<File?> _captureFaceImage() async {
    // Sử dụng liveness detection để chụp ảnh khuôn mặt thật
    final livenessResult = await _faceService.detectLivenessWithCamera(context);
    if (!livenessResult.isReal) {
      if (mounted) {
        setState(() {
          _bannerMessage =
              'Không thể xác minh khuôn mặt thật. Vui lòng thử lại!';
          _bannerIsError = true;
          _isLoading = false;
        });
      }
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

  Future<void> _takePicture() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imageFile = await _captureFaceImage();
      if (!mounted) return;

      if (imageFile == null) {
        setState(() {
          _bannerMessage = 'Vui lòng thử lại!';
          _bannerIsError = true;
          _isLoading = false;
        });
        return;
      }

      // Batch update state để tránh multiple setState calls
      setState(() {
        _imageFiles.add(imageFile);
        _isLoading = false;
        _bannerMessage = 'Đã chụp ảnh khuôn mặt thành công!';
        _bannerIsError = false;
      });

      // Tự động chuyển carousel đến ảnh vừa chụp
      await Future.delayed(const Duration(milliseconds: 100));
      _pageController.animateToPage(
        _imageFiles.length - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _bannerMessage = 'Lỗi chụp ảnh khuôn mặt: ${e.toString()}';
        _bannerIsError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_imageFiles.length != 3) {
      setState(() {
        _bannerMessage = 'Bạn phải chụp đủ 3 ảnh khuôn mặt để đăng ký.';
        _bannerIsError = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _faceService.registerFace(images: _imageFiles);
      if (!mounted) return;

      // Cập nhật UserCubit
      context.read<UserCubit>().updateFaceRegistrationStatus(true);

      setState(() {
        _bannerMessage = 'Đã đăng ký khuôn mặt thành công!';
        _bannerIsError = false;
      });

      // Chuyển về màn hình home sau khi đăng ký thành công
      if (mounted) {
        AppRouter.goToHome(context, widget.user);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bannerMessage = 'Đăng ký thất bại! Liên hệ admin để trợ giúp.';
        _bannerIsError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã chụp: ${_imageFiles.length}/3',
              style: TextConstants.appTextBold,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
          child: LinearProgressIndicator(
            value: _imageFiles.length / 3,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Đăng ký khuôn mặt'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner thông báo/lỗi
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bannerIsError
                        ? ColorConstants.errorColor
                        : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _bannerIsError
                            ? Icons.error_outline
                            : Icons.info_outline,
                        color: ColorConstants.backgroundLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _bannerMessage,
                          style: const TextStyle(
                            color: ColorConstants.backgroundLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Progress indicator
                _buildProgressIndicator(),
                const SizedBox(height: 24),
                // Hiển thị 3 ảnh đã chụp dạng carousel
                Builder(
                  builder: (context) {
                    final double size = MediaQuery.of(context).size.width - 50;
                    return SizedBox(
                      height: size,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 3,
                        onPageChanged: (index) {
                          setState(() {
                            // Đã xóa _currentPage vì không dùng
                          });
                        },
                        itemBuilder: (context, index) {
                          // Sử dụng FaceAvatarWidget nếu đã có ảnh
                          if (index < _imageFiles.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Stack(
                                children: [
                                  // Hiển thị ảnh khuôn mặt đơn giản
                                  Container(
                                    width: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.file(
                                        _imageFiles[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),

                                  // Vị trí ảnh
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                                      ),
                                      child: Text(
                                        '${index + 1}/3',
                                        style: const TextStyle(
                                          color: ColorConstants.backgroundLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Placeholder cho ảnh chưa chụp
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: Opacity(
                                        opacity: 0.45,
                                        child: Assets.icon.faceID.svg(
                                          width: size * 0.3,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Vị trí ảnh
                                  Positioned(
                                    top: 0,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                                        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                                      ),
                                      child: Text(
                                        '${index + 1}/3',
                                        style: const TextStyle(
                                          color: ColorConstants.backgroundLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Theme.of(context).primaryColor,
                      dotColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!_isLoading)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
                      ),
                      child: Column(
                        children: [
                          if (_imageFiles.length < 3)
                            CustomButton(
                              text: 'Chụp ảnh ${_imageFiles.length + 1}',
                              icon: Icons.camera_alt,
                              onPressed: _takePicture,
                            ),

                          if (_imageFiles.isNotEmpty && _imageFiles.length < 3)
                            const SizedBox(height: 12),
                          if (_imageFiles.length == 3)
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Xóa tất cả',
                                    onPressed: () {
                                      setState(() {
                                        _imageFiles.clear();
                                      });
                                    },
                                    icon: Icons.delete_outline,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Xác nhận',
                                    onPressed: _submitForm,
                                    icon: Icons.check,
                                  ),
                                ),
                              ],
                            ),

                          if (_imageFiles.length < 3 && _imageFiles.isNotEmpty)
                            CustomButton(
                              text: 'Xóa tất cả ảnh',
                              onPressed: () {
                                setState(() {
                                  _imageFiles.clear();
                                });
                              },
                              icon: Icons.delete_outline,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
