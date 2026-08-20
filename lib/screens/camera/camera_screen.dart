import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_header.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Màn hình camera đơn giản để chụp ảnh khuôn mặt
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  /// Khởi tạo camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        _showError('Không thể khởi động camera.');
      }
    }
  }

  /// Chụp ảnh
  Future<void> _capturePhoto() async {
    if (_isCapturing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    _isCapturing = true;

    try {
      final image = await _cameraController!.takePicture();

      if (mounted) {
        Navigator.of(context).pop(File(image.path));
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        _showError('Không thể chụp ảnh, thử lại nhé!');
      }
    } finally {
      _isCapturing = false;
    }
  }

  /// Hiển thị lỗi và quay lại màn hình trước
  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.backgroundDark.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SamcomHeader(
                icon: Icons.error_rounded,
                title: 'Lỗi',
                subtitle: message,
                primaryColor: ColorConstants.errorColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: CustomButton(
                  text: 'OK',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Đóng dialog
                    Navigator.of(context).pop(); // Quay lại màn hình trước
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dispose camera
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      try {
        await _cameraController!.dispose();
      } catch (e) {
        debugPrint('Error disposing camera: $e');
      }
      _cameraController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Chụp ảnh'),
      body: Stack(
        children: [
          // Camera preview - full màn hình
          if (_isCameraInitialized && _cameraController != null)
            CameraPreview(_cameraController!)
          else
            Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),

          // Nút chụp ảnh ở giữa dưới màn hình
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: GestureDetector(
                    onTap: _isCapturing ? null : _capturePhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing
                            ? colorScheme.onSurface.withValues(alpha: 0.38)
                            : ColorConstants.backgroundLight,
                        border: Border.all(color: colorScheme.primary, width: 4),
                      ),
                      child: _isCapturing
                          ? Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                                strokeWidth: 3,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
