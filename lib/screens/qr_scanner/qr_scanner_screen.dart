import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:attendancebyface/screens/qr_scanner/widgets/citizen_id_form_dialog.dart';
import 'package:attendancebyface/models/citizen_id_data.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isUpdate;

  const QRScannerScreen({super.key, this.isUpdate = false});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(torchEnabled: false, autoZoom: true);
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      await controller.start();
    } catch (e) {
      if (mounted) _showCameraError('Không thể khởi động camera.');
    }
  }

  void _showCameraError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
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
              DialogHeader(
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
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CitizenIDFormDialog(
          citizenData: citizenData,
          isUpdate: widget.isUpdate,
          onClose: () => Navigator.of(context).maybePop(),
          onConfirm: () => Navigator.of(context).maybePop(),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: 'Quét QR Căn cước'),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCameraError('Không thể khởi động camera.');
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
