import 'package:dio/dio.dart';

enum ApiErrorKind { network, auth, client, server, unknown }

/// Exception chuẩn hóa cho tầng network
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorKind kind;
  final String? requestId;
  final DioException? dioException;

  const ApiException({
    required this.message,
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
    this.requestId,
    this.dioException,
  });

  bool get isAuth => kind == ApiErrorKind.auth;
  bool get isNetwork => kind == ApiErrorKind.network;

  factory ApiException.fromDio(DioException err) {
    final int? code = err.response?.statusCode;
    final String reqId =
        err.response?.headers['x-request-id']?.firstOrNull ?? '';

    // message extraction
    String msg = err.message ?? '';
    try {
      final data = err.response?.data;
      if (data is Map) {
        msg =
            (data['message'] ??
                    data['error'] ??
                    data['error_message'] ??
                    data['error_description'] ??
                    data['detail'] ??
                    msg ??
                    '')
                .toString();
      } else if (data != null) {
        msg = data.toString();
      }
    } catch (_) {}
    msg = msg.trim();

    // kind mapping
    ApiErrorKind kind = ApiErrorKind.unknown;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      kind = ApiErrorKind.network;
      msg = msg.isEmpty ? 'Lỗi kết nối mạng' : msg;
    } else if (code == 401 || code == 403) {
      kind = ApiErrorKind.auth;
      if (code == 401 && msg.isEmpty) {
        msg = 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
      }
      if (code == 403 && msg.isEmpty) {
        msg = 'Bạn không có quyền truy cập tài nguyên này';
      }
    } else if (code != null && code >= 400 && code < 500) {
      kind = ApiErrorKind.client;
      if (msg.isEmpty) msg = 'Dữ liệu không hợp lệ';
    } else if (code != null && code >= 500) {
      kind = ApiErrorKind.server;
      if (msg.isEmpty) msg = 'Lỗi hệ thống, vui lòng thử lại sau';
    }

    return ApiException(
      message: msg.isEmpty ? (err.message ?? 'Đã xảy ra lỗi') : msg,
      statusCode: code,
      kind: kind,
      requestId: reqId.isEmpty ? null : reqId,
      dioException: err,
    );
  }

  @override
  String toString() =>
      'ApiException[$kind]: $message (Status Code: $statusCode)';
}
