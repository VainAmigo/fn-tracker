abstract final class AiExpenseNoteUtils {
  static String clampToWordCount(String input, int maxWords) {
    final words = input
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length <= maxWords) {
      return words.join(' ');
    }
    return words.take(maxWords).join(' ');
  }
}
