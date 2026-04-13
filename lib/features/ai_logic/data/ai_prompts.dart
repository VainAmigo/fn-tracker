import 'dart:convert';

/// Системные инструкции и JSON Schema для Gemini.
abstract final class AiPrompts {
  static const String systemInstruction = '''
Ты помощник учёта личных финансов. Пользователь описывает операции голосом или приложил чек (изображение/PDF).

Верни массив transactions: все различные операции, которые удалось выделить (одна или несколько). Если в тексте одна покупка — массив из одного элемента.

Правила для каждого элемента:
1) type: EXPENSE (расход) или INCOME (доход) — обязательно.
2) categoryId и walletId — только из списков пользователя. Если не уверен или нечего подобрать — верни пустую строку "" для этого поля (не выдумывай id).
3) amount — число в валюте пользователя; если сумму нельзя определить — верни 0 или опусти поле.
4) date — если для этой операции явно указана дата (в тексте или на чеке), верни YYYY-MM-DD. Если нет — опусти поле или "" (клиент подставит сегодня для этой позиции).
5) note — кратко, не больше 5 слов; можно пустая строка.
6) Только валидный JSON по схеме, без markdown.
''';

  static Map<String, Object?> get _transactionItemSchema => {
    'type': 'object',
    'properties': {
      'type': {
        'type': 'string',
        'enum': ['EXPENSE', 'INCOME'],
      },
      'categoryId': {'type': 'string'},
      'walletId': {'type': 'string'},
      'date': {'type': 'string'},
      'amount': {'type': 'number'},
      'note': {'type': 'string'},
    },
    'required': ['type'],
  };

  /// Schema: массив транзакций (одна или больше), поля кроме type могут быть пустыми.
  static Map<String, Object?> get responseJsonSchema => {
    'type': 'object',
    'properties': {
      'transactions': {
        'type': 'array',
        'items': _transactionItemSchema,
        'minItems': 1,
      },
    },
    'required': ['transactions'],
  };

  static String userContextSection({
    required List<Map<String, String>> categories,
    required List<Map<String, String>> wallets,
    required String userContentDescription,
  }) {
    return '''
Категории (JSON, поля categoryId и name): ${jsonEncode(categories)}
Кошельки (JSON, поля id и name): ${jsonEncode(wallets)}

$userContentDescription
''';
  }
}
