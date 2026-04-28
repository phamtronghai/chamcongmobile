import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';

class ErrorInterceptor extends Interceptor {
  // GlobalKey giúp Interceptor tiếp cận được BuildContext mới nhất từ MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String displayErrorMessage;
    
    // Parse lỗi chi tiết từ server
    final errorResponse = ResponseParser.parseDioException(err);
    displayErrorMessage = errorResponse['message'] ?? 'Lỗi kết nối hoặc hệ thống.';

    // Hiển thị CustomSnackbar tự động toàn cục
    final currentContext = navigatorKey.currentState?.context;
    if (currentContext != null) {
      CustomSnackbar.show(
        context: currentContext,
        message: displayErrorMessage,
        type: CustomSnackbarType.error,
      );
    }
    
    super.onError(err, handler);
  }
}
