import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class JsonStorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }

  static Future<void> saveData(String fileName, List<dynamic> data) async {
    final file = await _getFile(fileName);
    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);
  }

  static Future<List<dynamic>> loadData(String fileName) async {
    try {
      final file = await _getFile(fileName);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
