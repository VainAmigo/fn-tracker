import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:fn_tracker/features/features.dart';
import 'package:fn_tracker/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class ExportExcelService {
  Future<File> buildExcelFile({
    required List<ExportItem> rows,
    required List<ExportColumn> columns,
    required String localeLanguageCode,
  }) async {
    final l10n = lookupAppLocalizations(Locale(localeLanguageCode));
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Export';

    for (var i = 0; i < columns.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(columns[i].title(l10n));
    }

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      for (var colIndex = 0; colIndex < columns.length; colIndex++) {
        sheet
            .getRangeByIndex(rowIndex + 2, colIndex + 1)
            .setText(columns[colIndex].valueFrom(row));
      }
    }
    _applyColumnWidths(sheet: sheet, rows: rows, columns: columns, l10n: l10n);

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/fn_tracker_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
    return file;
  }

  Future<bool> shareFile(File file) async {
    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyColumnWidths({
    required xlsio.Worksheet sheet,
    required List<ExportItem> rows,
    required List<ExportColumn> columns,
    required AppLocalizations l10n,
  }) {
    for (var colIndex = 0; colIndex < columns.length; colIndex++) {
      final column = columns[colIndex];
      var maxLen = column.title(l10n).length;

      for (final row in rows) {
        final valueLen = column.valueFrom(row).length;
        if (valueLen > maxLen) maxLen = valueLen;
      }

      final width = _estimateColumnWidth(maxLen: maxLen, column: column);
      sheet.getRangeByIndex(1, colIndex + 1).columnWidth = width;
    }
  }

  double _estimateColumnWidth({
    required int maxLen,
    required ExportColumn column,
  }) {
    final padded = (maxLen + 2).toDouble();
    final width = switch (column) {
      ExportColumn.note => padded * 0.95,
      ExportColumn.transactionId => padded * 1.15,
      ExportColumn.amount => padded * 0.9,
      _ => padded * 0.92,
    };
    return width.clamp(10.0, 48.0);
  }
}
