import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendancebyface/core/app_config.dart';

class FileUtils {
  // Save image to app directory
  static Future<File> saveImageToAppDirectory(
    Uint8List imageBytes, {
    String? customFileName,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        customFileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${appDir.path}/${AppConfig.attendanceImagesPath}';

    // Create directory if not exists
    final directory = Directory(filePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Save file
    final file = File('$filePath/$fileName');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  // Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  // Delete file
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Clean up old files
  static Future<void> cleanupOldFiles(
    String directory, {
    int olderThanDays = 30,
  }) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return;

    final now = DateTime.now();
    await for (final entity in dir.list()) {
      if (entity is File) {
        final fileStat = await entity.stat();
        final fileAge = now.difference(fileStat.modified).inDays;

        if (fileAge > olderThanDays) {
          await entity.delete();
        }
      }
    }
  }

  /// Cleanup temporary files trong temp directory
  static Future<void> cleanupTempFiles({int olderThanHours = 1}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();

      await for (final entity in tempDir.list()) {
        if (entity is File && entity.path.contains('face_capture_')) {
          final fileStat = await entity.stat();
          final fileAge = now.difference(fileStat.modified).inHours;

          if (fileAge > olderThanHours) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi cleanup temp files: $e');
    }
  }

  /// Cleanup attendance images cũ
  static Future<void> cleanupAttendanceImages({int olderThanDays = 7}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attendanceDir = Directory(
        '${appDir.path}/${AppConfig.attendanceImagesPath}',
      );

      if (!await attendanceDir.exists()) return;

      final now = DateTime.now();
      await for (final entity in attendanceDir.list()) {
        if (entity is File) {
          final fileStat = await entity.stat();
          final fileAge = now.difference(fileStat.modified).inDays;

          if (fileAge > olderThanDays) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi cleanup attendance images: $e');
    }
  }
}
