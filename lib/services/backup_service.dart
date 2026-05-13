import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

class BackupResult {
  const BackupResult({required this.ok, this.message});
  final bool ok;
  final String? message;
}

class BackupService {
  /// Copies the live SQLite file to a user-chosen .wexcom path.
  static Future<BackupResult> exportBackup() async {
    try {
      final dbFile = await _findDbFile();
      if (dbFile == null) {
        return const BackupResult(ok: false, message: 'Database file not found');
      }

      final location = await getSaveLocation(
        suggestedName:
            'wexcom_backup_${_yyyymmddhhss(DateTime.now())}.wexcom',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Wexcom Backup', extensions: ['wexcom']),
        ],
      );
      if (location == null) {
        return const BackupResult(ok: false, message: 'Cancelled');
      }

      await dbFile.copy(location.path);
      return BackupResult(ok: true, message: location.path);
    } catch (e) {
      return BackupResult(ok: false, message: e.toString());
    }
  }

  /// Prompts the user to pick a .wexcom file and stages it for restore on
  /// next app launch (same mechanism as cloud restore).
  static Future<BackupResult> importBackup() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'Wexcom Backup',
        extensions: ['wexcom'],
      );
      final result = await openFile(acceptedTypeGroups: [typeGroup]);
      if (result == null) {
        return const BackupResult(ok: false, message: 'Cancelled');
      }

      final dir = await getApplicationSupportDirectory();
      final staging = File('${dir.path}/debt_ledger_restore.sqlite');
      await File(result.path).copy(staging.path);

      return const BackupResult(ok: true);
    } catch (e) {
      return BackupResult(ok: false, message: e.toString());
    }
  }

  static Future<File?> _findDbFile() async {
    final dir = await getApplicationSupportDirectory();
    for (final name in ['debt_ledger.sqlite', 'debt_ledger']) {
      final f = File('${dir.path}/$name');
      if (await f.exists()) return f;
    }
    return null;
  }

  static String _yyyymmddhhss(DateTime d) {
    String p(int v, [int w = 2]) => v.toString().padLeft(w, '0');
    return '${d.year}${p(d.month)}${p(d.day)}_${p(d.hour)}${p(d.minute)}${p(d.second)}';
  }
}
