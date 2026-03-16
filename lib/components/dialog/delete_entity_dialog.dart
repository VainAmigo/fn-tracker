import 'package:flutter/material.dart';
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
  return showDialog<DeleteEntityResult>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(
          '${message != null ? '$message\n\n' : ''}'
          'Удалить частично — удалить цель/кошелёк, транзакции сохранятся.\n\n'
          'Удалить полностью — удалить вместе со всеми связанными транзакциями.',
          style: AppTextStyles.text14w400(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(DeleteEntityResult.cancel),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteEntityResult.deletePartial),
            child: const Text('Удалить частично'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(DeleteEntityResult.deleteFull),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Удалить полностью'),
          ),
        ],
      );
    },
  );
}
