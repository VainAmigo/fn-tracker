enum AppUpdateCheckResult {
  upToDate,
  outdated,
  restartRequired,
  unavailable,
}

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.result,
    this.currentPatchNumber,
  });

  final AppUpdateCheckResult result;
  final int? currentPatchNumber;
}

class AppUpdateDownloadException implements Exception {
  const AppUpdateDownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
