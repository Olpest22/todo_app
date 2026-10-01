/// Форматирует дату в вид «01.10.2026, 14:05» без сторонних пакетов.
String formatDateTime(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}, '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
