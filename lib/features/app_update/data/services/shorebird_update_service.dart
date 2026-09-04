import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:terminate_restart/terminate_restart.dart';

/// Обёртка над Shorebird updater и полным перезапуском процесса.
class ShorebirdUpdateService {
  ShorebirdUpdateService({ShorebirdUpdater? updater})
    : _updater = updater ?? ShorebirdUpdater();

  final ShorebirdUpdater _updater;

  bool get isAvailable => _updater.isAvailable;

  Future<UpdateStatus> checkForUpdate() => _updater.checkForUpdate();

  Future<void> downloadUpdate() => _updater.update();

  Future<int?> readCurrentPatchNumber() async {
    final patch = await _updater.readCurrentPatch();
    return patch?.number;
  }

  static void initializeRestart() {
    if (kIsWeb) return;
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return;
    }
    try {
      TerminateRestart.instance.initialize();
    } catch (_) {
      // Плагин недоступен в debug без нативной пересборки.
    }
  }

  Future<bool> restartApp() async {
    if (kIsWeb) return false;
    try {
      return await TerminateRestart.instance.restartApp(
        options: const TerminateRestartOptions(terminate: true),
      );
    } catch (_) {
      return false;
    }
  }
}
