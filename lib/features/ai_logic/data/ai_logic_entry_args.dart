enum AiLogicEntryMode {
  /// Старт с голосового ввода / распознавания речи.
  voice,

  /// Старт с выбора фото или PDF.
  attachment,
}

/// Аргумент маршрута [AppRouter.aiLogic].
final class AiLogicEntryArgs {
  const AiLogicEntryArgs({required this.mode});

  final AiLogicEntryMode mode;
}
