extension DateKeys on DateTime {
  String get periodKey {
    final m = month.toString().padLeft(2, '0');
    return '$year-$m';
  }

  String get dayKey {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }
}