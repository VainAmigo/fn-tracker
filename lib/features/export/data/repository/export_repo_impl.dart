import 'package:fn_tracker/features/export/export.dart';

abstract class ExportRepoImpl {
  Future<List<ExportItem>> getTransactionsForExport({
    required String startDayKey,
    required String endDayKey,
  });
}
