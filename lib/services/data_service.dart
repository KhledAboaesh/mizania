import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'json_storage_service.dart';

class DataService {
  static Future<void> exportData() async {
    final transactions = await JsonStorageService.loadData('transactions');
    final debts = await JsonStorageService.loadData('debts');

    final exportMap = {
      'transactions': transactions,
      'debts': debts,
      'exportDate': DateTime.now().toIso8601String(),
    };

    final jsonString = jsonEncode(exportMap);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/mizania_backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Mizania Backup - نسخة احتياطية ميزانية');
  }

  static Future<bool> importData(String jsonContent) async {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded.containsKey('transactions')) {
        await JsonStorageService.saveData(
            'transactions', decoded['transactions']);
      }
      if (decoded.containsKey('debts')) {
        await JsonStorageService.saveData('debts', decoded['debts']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
