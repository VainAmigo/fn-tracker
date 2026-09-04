import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fn_tracker/features/app_update/app_update.dart';

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  AppUpdateCubit({required this.appUpdateRepository})
    : super(const AppUpdateIdle());

  final AppUpdateRepository appUpdateRepository;
  var _checkId = 0;

  Future<void> checkForUpdate({bool userInitiated = false}) async {
    if (state is AppUpdateDownloading) return;
    if (!userInitiated && state is AppUpdateAvailable) return;
    if (!userInitiated && state is AppUpdateChecking) return;

    if (!appUpdateRepository.isAvailable) {
      emit(AppUpdateUnavailable(userInitiated: userInitiated));
      return;
    }

    final checkId = ++_checkId;
    emit(AppUpdateChecking(userInitiated: userInitiated));
    try {
      final info = await appUpdateRepository.checkForUpdate();
      if (isClosed || checkId != _checkId) return;
      emit(switch (info.result) {
        AppUpdateCheckResult.outdated => AppUpdateAvailable(
          userInitiated: userInitiated,
          currentPatchNumber: info.currentPatchNumber,
        ),
        AppUpdateCheckResult.restartRequired => AppUpdateReadyToRestart(
          userInitiated: userInitiated,
          currentPatchNumber: info.currentPatchNumber,
        ),
        AppUpdateCheckResult.upToDate => AppUpdateUpToDate(
          userInitiated: userInitiated,
          currentPatchNumber: info.currentPatchNumber,
        ),
        AppUpdateCheckResult.unavailable => AppUpdateUnavailable(
          userInitiated: userInitiated,
        ),
      });
    } catch (_) {
      if (isClosed || checkId != _checkId) return;
      emit(
        AppUpdateError(
          userInitiated: userInitiated,
          fromDownload: false,
        ),
      );
    }
  }

  Future<void> downloadUpdate() async {
    if (state is AppUpdateDownloading) return;
    _checkId++;
    final patchNumber = state.currentPatchNumber;
    emit(AppUpdateDownloading(currentPatchNumber: patchNumber));
    try {
      await appUpdateRepository.downloadUpdate();
      if (isClosed) return;
      emit(AppUpdateReadyToRestart(currentPatchNumber: patchNumber));
    } on AppUpdateDownloadException {
      if (isClosed) return;
      emit(
        AppUpdateError(
          fromDownload: true,
          currentPatchNumber: patchNumber,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        AppUpdateError(
          fromDownload: true,
          currentPatchNumber: patchNumber,
        ),
      );
    }
  }

  Future<void> restartApp() async {
    final current = state;
    if (current is! AppUpdateReadyToRestart) return;
    final restarted = await appUpdateRepository.restartApp();
    if (restarted || isClosed) return;
    emit(
      AppUpdateReadyToRestart(
        currentPatchNumber: current.currentPatchNumber,
        restartFailed: true,
      ),
    );
  }
}
