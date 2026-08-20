import 'dart:convert';
import 'package:dio/dio.dart';

/// Helper class để parse API responses
/// Loại bỏ code lặp lại trong response parsing
class ResponseParser {
  /// Parse face check response
  static Map<String, dynamic> parseFaceCheckResponse(Response response) {
    if (response.data is Map) {
      final responseData = response.data as Map;
      if (responseData['report'] == 'Chấm công thành công') {
        return {
          'success': true,
          'message': 'Chấm công thành công',
          'status': responseData['status'] ?? response.statusCode,
          'time': responseData['time'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'success': false,
          'message': responseData['report'] ?? 'Chấm công thất bại',
          'status': responseData['status'] ?? response.statusCode,
          'time': responseData['time'] ?? DateTime.now().toIso8601String(),
        };
      }
    }
    return {
      'success': false,
      'message': 'Chấm công thất bại',
      'status': response.statusCode,
      'time': DateTime.now().toIso8601String(),
    };
  }

  /// Parse liveness response
  static Map<String, dynamic> parseLivenessResponse(Response response) {
    try {
      final jsonResult = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      return {
        'isReal': jsonResult['status'] == 'ok',
        'confidence': jsonResult['confidence'] ?? 0.0,
        'message': jsonResult['message'] ?? '',
      };
    } catch (e) {
      return {'isReal': false, 'confidence': 0.0, 'message': 'Lỗi parse: $e'};
    }
  }

  // Đã loại bỏ parseLoginResponse và parseServerTimeResponse không còn sử dụng

  /// Parse server datetime response với định dạng Vietnam
  static Map<String, dynamic> parseServerDateTimeResponse(Response response) {
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      return {
        'vietnam': data['vietnam'] ?? '',
        'parsedDateTime': _parseVietnamTime(data['vietnam'] ?? ''),
      };
    }
    return {'vietnam': '', 'parsedDateTime': null};
  }

  /// Parse thời gian định dạng Vietnam "08:45:43 10/7/2025"
  static DateTime? _parseVietnamTime(String vietnamTime) {
    try {
      // Định dạng: "08:45:43 10/7/2025"
      final parts = vietnamTime.trim().split(' ');
      if (parts.length != 2) {
        return null;
      }

      final timeParts = parts[0].split(':');
      final dateParts = parts[1].split('/');

      if (timeParts.length != 3 || dateParts.length != 3) {
        return null;
      }

      return DateTime(
        int.parse(dateParts[2]), // năm
        int.parse(dateParts[1]), // tháng
        int.parse(dateParts[0]), // ngày
        int.parse(timeParts[0]), // giờ
        int.parse(timeParts[1]), // phút
        int.parse(timeParts[2]), // giây
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse check registered response với error handling phức tạp
  static bool parseCheckRegisteredResponse(Response response) {
    if (response.statusCode == 200) {
      final data = response.data;
      return data['registered'] == true;
    }
    return false;
  }

  /// Parse check registered response từ DioException
  static bool parseCheckRegisteredFromError(DioException error) {
    if (error.response != null && error.response!.data != null) {
      var responseData = error.response!.data;

      // Chuyển đổi response data thành Map nếu là String
      Map<String, dynamic> jsonData;
      if (responseData is String) {
        try {
          jsonData = jsonDecode(responseData);
        } catch (_) {
          return false;
        }
      } else if (responseData is Map) {
        jsonData = Map<String, dynamic>.from(responseData);
      } else {
        return false;
      }

      // Kiểm tra registered trong response data
      if (jsonData.containsKey('registered')) {
        return jsonData['registered'] == true;
      }
    }
    return false;
  }

  /// Parse delete face response với error handling phức tạp
  static bool parseDeleteFaceResponse(Response response) {
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  /// Parse delete face response từ DioException
  static bool parseDeleteFaceFromError(DioException error) {
    if (error.response != null && error.response!.data != null) {
      var responseData = error.response!.data;

      // Chuyển đổi response data thành Map nếu là String
      Map<String, dynamic>? jsonData;
      if (responseData is String) {
        try {
          jsonData = jsonDecode(responseData);
        } catch (_) {
          return false;
        }
      } else if (responseData is Map) {
        jsonData = Map<String, dynamic>.from(responseData);
      } else {
        return false;
      }

      // Kiểm tra success trong response data nếu có
      if (jsonData != null && jsonData.containsKey('success')) {
        return jsonData['success'] == true;
      }
    }
    return false;
  }

  /// Parse face registration response
  static Map<String, dynamic> parseFaceRegistrationResponse(Response response) {
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Đăng ký khuôn mặt thành công'};
    } else {
      return {'success': false, 'message': 'Đăng ký khuôn mặt thất bại'};
    }
  }

  /// Parse attendance history response
  static List<dynamic> parseAttendanceHistoryResponse(Response response) {
    if (response.statusCode == 200) {
      final responseData = response.data is List ? response.data : [];
      return responseData;
    }
    return [];
  }

  /// Parse attendance history response từ DioException
  static List<dynamic> parseAttendanceHistoryFromError(DioException error) {
    if (error.response != null && error.response!.data != null) {
      var responseData = error.response!.data;

      // Chuyển đổi response data thành List nếu là String
      List<dynamic>? jsonData;
      if (responseData is String) {
        try {
          final decoded = jsonDecode(responseData);
          if (decoded is List) {
            jsonData = decoded;
          } else if (decoded is Map &&
              decoded.containsKey('data') &&
              decoded['data'] is List) {
            // Trường hợp API trả về dạng { "data": [...] }
            jsonData = decoded['data'];
          }
        } catch (_) {
          return [];
        }
      } else if (responseData is List) {
        jsonData = responseData;
      } else if (responseData is Map &&
          responseData.containsKey('data') &&
          responseData['data'] is List) {
        // Trường hợp API trả về dạng { "data": [...] }
        jsonData = responseData['data'];
      }

      return jsonData ?? [];
    }
    return [];
  }

  /// Parse DioException để trích xuất thông báo lỗi từ response body
  static Map<String, dynamic> parseDioException(DioException error) {
    // Kiểm tra nếu có response data
    if (error.response != null && error.response!.data != null) {
      var responseData = error.response!.data;

      // Chuyển đổi response data thành Map nếu là String
      Map<String, dynamic>? jsonData;
      if (responseData is String) {
        try {
          jsonData = jsonDecode(responseData);
        } catch (_) {
          // Nếu không parse được JSON, trả về thông báo lỗi mặc định
          return {
            'success': false,
            'message': 'Lỗi kết nối hoặc server',
            'status': error.response?.statusCode ?? 0,
          };
        }
      } else if (responseData is Map) {
        jsonData = Map<String, dynamic>.from(responseData);
      }

      // Trích xuất thông báo từ response body
      if (jsonData != null) {
        return {
          'success': jsonData['success'] ?? false,
          'message':
              jsonData['report'] ??
              jsonData['message'] ??
              'Lỗi kết nối hoặc server',
          'status': jsonData['status'] ?? error.response?.statusCode ?? 0,
        };
      }
    }

    // Fallback: trả về thông báo lỗi mặc định
    return {
      'success': false,
      'message': 'Lỗi kết nối hoặc server',
      'status': error.response?.statusCode ?? 0,
    };
  }
}
