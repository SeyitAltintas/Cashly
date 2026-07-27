import 'dart:convert';

/// Delta JSON'dan Türkçe küçük harfli düz metin çıkarır.
/// Not kaydedilirken bir kez çalışır; arama sırasında JSON parse gerekmez.
String extractSearchableText(String deltaJson) {
  if (deltaJson.isEmpty || deltaJson == '[]') return '';
  try {
    final List<dynamic> ops = jsonDecode(deltaJson);
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    // _toTurkishLowerCase ile aynı sıra: önce replaceAll, sonra toLowerCase
    return buffer
        .toString()
        .trim()
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .toLowerCase();
  } catch (_) {
    return '';
  }
}

/// Delta JSON'dan liste ekranında gösterilecek kısa özet (snippet) çıkarır.
String extractSnippet(String deltaJson) {
  if (deltaJson.isEmpty || deltaJson == '[]') return '';
  try {
    final List<dynamic> ops = jsonDecode(deltaJson);
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    final text = buffer.toString().trim();
    if (text.length > 200) return '${text.substring(0, 200)}...';
    return text;
  } catch (_) {
    return '';
  }
}
