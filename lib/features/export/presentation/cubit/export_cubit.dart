import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/export/data/data.dart';

enum ExportRunStatus {
  success,
  successWithoutShare,
  noData,
  missingPeriod,
  failed,
}

class ExportState {
  const ExportState({
    required this.settings,
    required this.hasConfiguredExport,
    this.isExporting = false,
    this.lastError,
  });

  final ExportSettings settings;
  final bool hasConfiguredExport;
  final bool isExporting;
  final String? lastError;

  ExportState copyWith({
    ExportSettings? settings,
    bool? hasConfiguredExport,
    bool? isExporting,
    String? lastError,
    bool clearError = false,
  }) {
    return ExportState(
      settings: settings ?? this.settings,
      hasConfiguredExport: hasConfiguredExport ?? this.hasConfiguredExport,
      isExporting: isExporting ?? this.isExporting,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
    'settings': settings.toJson(),
    'hasConfiguredExport': hasConfiguredExport,
    'lastError': lastError,
  };

  factory ExportState.fromJson(Map<String, dynamic> json) {
    final settingsJson = json['settings'];
    return ExportState(
      settings: settingsJson is Map<String, dynamic>
          ? ExportSettings.fromJson(settingsJson)
          : ExportSettings.defaults(),
      hasConfiguredExport: json['hasConfiguredExport'] as bool? ?? false,
      lastError: json['lastError'] as String?,
    );
  }
}

class ExportCubit extends HydratedCubit<ExportState> {
  ExportCubit({required this.exportRepo, required this.excelService})
    : super(
        ExportState(
          settings: ExportSettings.defaults(),
          hasConfiguredExport: false,
        ),
      );

  final ExportRepoImpl exportRepo;
  final ExportExcelService excelService;

  @override
  String get storagePrefix => 'ExportCubit';

  @override
  ExportState? fromJson(Map<String, dynamic> json) =>
      ExportState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ExportState state) => state.toJson();

  void setPeriodPreset(ExportPeriodPreset preset) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          periodPreset: preset,
          clearCustomRange: preset != ExportPeriodPreset.custom,
        ),
      ),
    );
  }

  void setCustomRange(DateTime start, DateTime end) {
    emit(
      state.copyWith(
        settings: state.settings.copyWith(
          periodPreset: ExportPeriodPreset.custom,
          customStart: DateTime(start.year, start.month, start.day),
          customEnd: DateTime(end.year, end.month, end.day, 23, 59, 59),
        ),
      ),
    );
  }

  void toggleColumn(ExportColumn column) {
    final current = List<ExportColumn>.from(state.settings.columnsOrder);
    if (current.contains(column)) {
      if (current.length == 1) return;
      current.remove(column);
    } else {
      current.add(column);
    }
    emit(
      state.copyWith(settings: state.settings.copyWith(columnsOrder: current)),
    );
  }

  void reorderColumns(int oldIndex, int newIndex) {
    final current = List<ExportColumn>.from(state.settings.columnsOrder);
    if (newIndex > oldIndex) newIndex--;
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    emit(
      state.copyWith(settings: state.settings.copyWith(columnsOrder: current)),
    );
  }

  void saveSettings() => emit(state.copyWith(hasConfiguredExport: true));

  Future<ExportRunStatus> runExportWithSavedSettings() async {
    return runExportWithSavedSettingsForLocale(localeLanguageCode: 'en');
  }

  Future<ExportRunStatus> runExportWithSavedSettingsForLocale({
    required String localeLanguageCode,
  }) async {
    final range = state.settings.dateRange;
    if (range == null) return ExportRunStatus.missingPeriod;

    try {
      emit(state.copyWith(isExporting: true, clearError: true));
      final data = await exportRepo.getTransactionsForExport(
        startDayKey: range.start.dayKey,
        endDayKey: range.end.dayKey,
      );
      if (data.isEmpty) {
        emit(state.copyWith(isExporting: false));
        return ExportRunStatus.noData;
      }
      final file = await excelService.buildExcelFile(
        rows: data,
        columns: state.settings.columnsOrder,
        localeLanguageCode: localeLanguageCode,
      );
      final isShared = await excelService.shareFile(file);
      emit(state.copyWith(isExporting: false));
      return isShared
          ? ExportRunStatus.success
          : ExportRunStatus.successWithoutShare;
    } catch (e) {
      emit(state.copyWith(isExporting: false, lastError: e.toString()));
      return ExportRunStatus.failed;
    }
  }
}
