import 'package:flutter/material.dart';
import 'package:fn_tracker/l10n/generated/app_localizations.dart';
import 'package:fn_tracker/theme/themes.dart';

/// Результат выбора в диалоге удаления сущности (цель, кошелёк).
enum DeleteEntityResult {
  cancel,
  deleteFull,
  deletePartial,
}

/// Диалог подтверждения удаления с выбором режима.
///
/// - [cancel] — отмена
/// - [deleteFull] — удалить полностью (вместе с транзакциями)
/// - [deletePartial] — удалить частично (сохранить данные о транзакциях)
Future<DeleteEntityResult?> showDeleteEntityDialog(
  BuildContext context, {
  required String title,
  String? message,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<DeleteEntityResult>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final content = '${message != null ? '$message\n\n' : ''}'
          '${l10n.deleteEntityPartialHint}\n\n'
          '${l10n.deleteEntityFullHint}';
      return AlertDialog(
        title: Text(title),
        content: Text(
          content,
          style: AppTextStyles.text14w400(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(DeleteEntityResult.cancel),
            child: Text(l10n.deleteEntityCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteEntityResult.deletePartial),
            child: Text(l10n.deleteEntityPartial),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteEntityResult.deleteFull),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: Text(l10n.deleteEntityFull),
          ),
        ],
      );
    },
  );
}
