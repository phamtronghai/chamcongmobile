import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:attendancebyface/core/app_config.dart';

class FileUtils {
  static Future<File> saveImageToAppDirectory(
    Uint8List imageBytes, {
    String? customFileName,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        customFileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${appDir.path}/${AppConfig.attendanceImagesPath}';

    final directory = Directory(filePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('$filePath/$fileName');
    await file.writeAsBytes(imageBytes);
    return file;
  }
}
