import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:attendancebyface/widgets/citizen_id_form_dialog.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/app_router.dart';

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CitizenIDFormDialog(
          citizenData: citizenData,
          isUpdate: widget.isUpdate,
          onClose: () {
            // Quay về settings screen
            AppRouter.goBack(context);
          },
          onConfirm: () {
            // Quay về settings screen
            AppRouter.goBack(context);
          },
        ),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi bằng CustomSnackbar
      CustomSnackbar.show(
        context: context,
        message: 'Dữ liệu QR không hợp lệ: ${e.toString()}',
        type: CustomSnackbarType.error,
      );
      setState(() {
        _isScanning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(title: 'Quét QR Căn cước'),
      body: MobileScanner(controller: controller, onDetect: _onDetect),
    );
  }
}
