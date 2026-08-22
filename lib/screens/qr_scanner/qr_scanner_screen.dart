import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:attendancebyface/screens/qr_scanner/widgets/citizen_id_form_sheet.dart';
import 'package:attendancebyface/models/citizen_id_data.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isUpdate;

  const QRScannerScreen({super.key, this.isUpdate = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late final MobileScannerController controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // autoStart: MobileScanner widget tự start — không gọi start() lần nữa
    // (gây lỗi "already started" trên máy thật dù preview vẫn chạy).
    controller = MobileScannerController(
      torchEnabled: false,
      autoStart: true,
      autoZoom: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _isScanning = false;
        _showQRResult(code);
      }
    }
  }

  void _showQRResult(String qrData) {
    try {
      final citizenData = CitizenIDData.fromQRData(qrData);
      CustomSnackbar.show(
        context: context,
        message: 'Quét QR thành công!',
        type: CustomSnackbarType.success,
      );
      CitizenIDFormSheet.show(
        context,
        citizenData: citizenData,
        isUpdate: widget.isUpdate,
        onClose: () => Navigator.of(context).maybePop(),
        onConfirm: () => Navigator.of(context).maybePop(),
      ).then((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Dữ liệu QR không hợp lệ: ${e.toString()}',
        type: CustomSnackbarType.error,
      );
      setState(() => _isScanning = true);
    }
  }

  String _describeCameraError(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Chưa được cấp quyền camera. Vào Cài đặt để cho phép.';
      case MobileScannerErrorCode.controllerAlreadyInitialized:
      case MobileScannerErrorCode.controllerInitializing:
        return '';
      default:
        final text = error.errorDetails?.message ?? error.toString();
        if (text.contains('inference context')) {
          return 'Thiết bị không khởi tạo được bộ quét mã. Thử đóng app và mở lại.';
        }
        return text;
    }
  }

  Future<void> _retryStart() async {
    try {
      await controller.start();
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context: context,
        message: 'Không thể khởi động camera.',
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundDark,
      appBar: const CustomAppBar(title: 'Quét QR Căn cước'),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          final detail = _describeCameraError(error);
          // Lỗi tạm (đã start / đang init) — không chặn preview.
          if (detail.isEmpty) {
            return const SizedBox.shrink();
          }
          return ColoredBox(
            color: ColorConstants.backgroundDark,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_off_outlined,
                      size: 48,
                      color: ColorConstants.backgroundLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể khởi động camera.',
                      textAlign: TextAlign.center,
                      style: TextConstants.appTextBold.copyWith(
                        color: ColorConstants.backgroundLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: TextConstants.appTextRegular.copyWith(
                        color: ColorConstants.backgroundLight.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Thử lại',
                      icon: Icons.refresh,
                      onPressed: _retryStart,
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
