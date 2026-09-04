part of 'app_update_cubit.dart';

sealed class AppUpdateState {
  const AppUpdateState({
    this.userInitiated = false,
    this.currentPatchNumber,
  });

  final bool userInitiated;
  final int? currentPatchNumber;
}

final class AppUpdateIdle extends AppUpdateState {
  const AppUpdateIdle();
}

final class AppUpdateChecking extends AppUpdateState {
  const AppUpdateChecking({super.userInitiated});
}

final class AppUpdateAvailable extends AppUpdateState {
  const AppUpdateAvailable({
    super.userInitiated,
    super.currentPatchNumber,
  });
}

final class AppUpdateDownloading extends AppUpdateState {
  const AppUpdateDownloading({super.currentPatchNumber});
}

final class AppUpdateReadyToRestart extends AppUpdateState {
  const AppUpdateReadyToRestart({
    super.userInitiated,
    super.currentPatchNumber,
    this.restartFailed = false,
  });

  final bool restartFailed;
}

final class AppUpdateUpToDate extends AppUpdateState {
  const AppUpdateUpToDate({
    super.userInitiated,
    super.currentPatchNumber,
  });
}

final class AppUpdateUnavailable extends AppUpdateState {
  const AppUpdateUnavailable({super.userInitiated});
}

final class AppUpdateError extends AppUpdateState {
  const AppUpdateError({
    super.userInitiated,
    super.currentPatchNumber,
    this.fromDownload = false,
  });

  final bool fromDownload;
}
