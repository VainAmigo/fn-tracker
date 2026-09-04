import 'package:fn_tracker/features/app_update/app_update.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class AppUpdateRepository {
  AppUpdateRepository({ShorebirdUpdateService? service})
    : _service = service ?? ShorebirdUpdateService();

  final ShorebirdUpdateService _service;

  bool get isAvailable => _service.isAvailable;

  Future<AppUpdateInfo> checkForUpdate() async {
    if (!_service.isAvailable) {
      return const AppUpdateInfo(result: AppUpdateCheckResult.unavailable);
    }

    final status = await _service.checkForUpdate();
    final patchNumber = await _service.readCurrentPatchNumber();
    return AppUpdateInfo(
      result: switch (status) {
        UpdateStatus.upToDate => AppUpdateCheckResult.upToDate,
        UpdateStatus.outdated => AppUpdateCheckResult.outdated,
        UpdateStatus.restartRequired => AppUpdateCheckResult.restartRequired,
        UpdateStatus.unavailable => AppUpdateCheckResult.unavailable,
      },
      currentPatchNumber: patchNumber,
    );
  }

  Future<void> downloadUpdate() async {
    try {
      await _service.downloadUpdate();
    } on UpdateException catch (error) {
      throw AppUpdateDownloadException(error.message);
    }
  }

  Future<bool> restartApp() => _service.restartApp();
}
