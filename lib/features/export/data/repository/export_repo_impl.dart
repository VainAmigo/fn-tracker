import 'package:fn_tracker/features/export/data/models/export_item.dart';

abstract class ExportRepoImpl {
  Future<List<ExportItem>> getTransactionsForExport({
    required String startDayKey,
    required String endDayKey,
  });
}
