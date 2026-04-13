import 'package:fn_tracker/core/core.dart';
import 'package:fn_tracker/features/export/export.dart';

enum ExportPeriodPreset { week, month, threeMonths, sixMonths, custom }

class ExportSettings {
  const ExportSettings({
    required this.columnsOrder,
    required this.periodPreset,
    this.customStart,
    this.customEnd,
  });

  final List<ExportColumn> columnsOrder;
  final ExportPeriodPreset periodPreset;
  final DateTime? customStart;
  final DateTime? customEnd;

  ({DateTime start, DateTime end})? get dateRange {
    return switch (periodPreset) {
      ExportPeriodPreset.week => MonthRangeUtils.lastWeek(),
      ExportPeriodPreset.month => MonthRangeUtils.currentMonth(),
      ExportPeriodPreset.threeMonths => MonthRangeUtils.lastMonths(3),
      ExportPeriodPreset.sixMonths => MonthRangeUtils.lastMonths(6),
      ExportPeriodPreset.custom =>
        (customStart != null && customEnd != null)
            ? (start: customStart!, end: customEnd!)
            : null,
    };
  }

  ExportSettings copyWith({
    List<ExportColumn>? columnsOrder,
    ExportPeriodPreset? periodPreset,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustomRange = false,
  }) {
    return ExportSettings(
      columnsOrder: columnsOrder ?? this.columnsOrder,
      periodPreset: periodPreset ?? this.periodPreset,
      customStart: clearCustomRange ? null : customStart ?? this.customStart,
      customEnd: clearCustomRange ? null : customEnd ?? this.customEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'columnsOrder': columnsOrder.map((e) => e.name).toList(),
      'periodPreset': periodPreset.name,
      'customStart': customStart?.millisecondsSinceEpoch,
      'customEnd': customEnd?.millisecondsSinceEpoch,
    };
  }

  factory ExportSettings.fromJson(Map<String, dynamic> json) {
    final names =
        (json['columnsOrder'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const <String>[];
    final parsedColumns = names
        .map((name) => ExportColumn.values.where((e) => e.name == name))
        .where((list) => list.isNotEmpty)
        .map((list) => list.first)
        .toList();
    final presetName = json['periodPreset'] as String?;
    final preset = ExportPeriodPreset.values
        .where((e) => e.name == presetName)
        .firstOrNull;
    final startMs = json['customStart'] as int?;
    final endMs = json['customEnd'] as int?;

    return ExportSettings(
      columnsOrder: parsedColumns.isEmpty
          ? ExportColumn.defaultOrder
          : parsedColumns,
      periodPreset: preset ?? ExportPeriodPreset.month,
      customStart: startMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startMs),
      customEnd: endMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(endMs),
    );
  }

  static ExportSettings defaults() {
    return ExportSettings(
      columnsOrder: ExportColumn.defaultOrder,
      periodPreset: ExportPeriodPreset.month,
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
