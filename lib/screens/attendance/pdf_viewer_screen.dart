import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    this.title = 'Báo cáo quân số',
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  late PdfViewerController _pdfViewController;

  @override
  void initState() {
    super.initState();
    _pdfViewController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        SfPdfViewer.file(
          File(widget.filePath),
          controller: _pdfViewController,
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            setState(() {
              _totalPages = details.document.pages.count;
              _isLoading = false;
            });
          },
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Lỗi khi tải PDF: ${details.error}';
              _isLoading = false;
            });
          },
          onPageChanged: (PdfPageChangedDetails details) {
            setState(() {
              _currentPage =
                  details.newPageNumber - 1; // Syncfusion uses 1-based indexing
            });
          },
        ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: ColorConstants.errorColor),
            const SizedBox(height: 16),
            Text(
              'Không thể hiển thị PDF',
              style: TextConstants.appTextBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextConstants.appTextRegular,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Quay lại',
              icon: Icons.arrow_back,
              width: 150,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_hasError || _isLoading || _totalPages == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.backgroundDark.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút trang trước
          CustomButton(
            text: 'Trang trước',
            icon: Icons.chevron_left,
            tooltip: 'Trang trước',
            variant: CustomButtonVariant.iconButton,
            width: 40,
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
          ),

          // Thông tin trang hiện tại
          Text(
            '${_currentPage + 1} / $_totalPages',
            style: TextConstants.appTextBold,
          ),

          // Nút trang sau
          CustomButton(
            text: 'Trang sau',
            icon: Icons.chevron_right,
            tooltip: 'Trang sau',
            variant: CustomButtonVariant.iconButton,
            width: 40,
            onPressed: _currentPage < _totalPages - 1 ? _goToNextPage : null,
          ),
        ],
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pdfViewController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      _pdfViewController.nextPage();
    }
  }
}
