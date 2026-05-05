import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/utils/response_parser.dart';

class ErrorInterceptor extends Interceptor {
  // GlobalKey giúp Interceptor tiếp cận được BuildContext mới nhất từ MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// API kiểm tra CCCD: 401 "Chưa đăng ký" là trạng thái bình thường, không cần snackbar.
  static bool _isCitizenCheckEndpoint(DioException err) {
    final p = err.requestOptions.path;
    final full = err.requestOptions.uri.toString();
    return p.contains('check_dk_cancuoc') || full.contains('check_dk_cancuoc');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final currentContext = navigatorKey.currentState?.context;

    if (!_isCitizenCheckEndpoint(err) && currentContext != null) {
      final errorResponse = ResponseParser.parseDioException(err);
      final displayErrorMessage =
          errorResponse['message'] ?? 'Lỗi kết nối hoặc hệ thống.';
      CustomSnackbar.show(
        context: currentContext,
        message: displayErrorMessage,
        type: CustomSnackbarType.error,
      );
    }

    super.onError(err, handler);
  }
}
