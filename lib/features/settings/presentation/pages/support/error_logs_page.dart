import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cashly/core/services/error_logger_service.dart';

class ErrorLogsPage extends StatefulWidget {
  const ErrorLogsPage({super.key});

  @override
  State<ErrorLogsPage> createState() => _ErrorLogsPageState();
}

class _ErrorLogsPageState extends State<ErrorLogsPage> {
  List<Map<String, String>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      // Local Hive always needs init if not initialized
      await ErrorLoggerService.init();
      final rawLogs = ErrorLoggerService.getAllLogs();

      // Parse strings: [$timestamp] $message\nStack: $stackTrace
      final parsedLogs = <Map<String, String>>[];
      for (final log in rawLogs) {
        String timestamp = '';
        String message = log;
        String stackTrace = '';

        final timeMatch = RegExp(r'^\[(.*?)\] ').firstMatch(log);
        if (timeMatch != null) {
          timestamp = timeMatch.group(1) ?? '';
          message = log.substring(timeMatch.end);
        }

        final stackSplit = message.split('\nStack: ');
        if (stackSplit.length == 2) {
          message = stackSplit[0];
          stackTrace = stackSplit[1];
        }

        parsedLogs.add({
          'timestamp': timestamp,
          'error': message,
          'stackTrace': stackTrace,
          'raw': log,
        });
      }

      setState(() {
        _logs = parsedLogs.reversed.toList(); // En yeni en üstte
      });
    } catch (e) {
      debugPrint('ErrorLogsPage load error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyLog(Map<String, String> logData) {
    Clipboard.setData(ClipboardData(text: logData['raw'] ?? ''));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hata kaydı kopyalandı. Geliştiriciye iletebilirsiniz.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıtları Temizle'),
        content: const Text(
          'Tüm yerel hata kayıtları silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ErrorLoggerService.clearLogs();
              _loadLogs();
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Hata Kayıtları'),
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearLogs,
              tooltip: 'Kayıtları Temizle',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(
              child: Text(
                'Harika! Hiç hata kaydı yok.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _logs.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final log = _logs[index];
                final dateStr = log['timestamp'] ?? '';
                DateTime? date;
                if (dateStr.isNotEmpty) {
                  date = DateTime.tryParse(dateStr);
                }

                final formattedDate = date != null
                    ? DateFormat('dd.MM.yyyy HH:mm:ss').format(date)
                    : 'Bilinmeyen Zaman';

                final isDark = Theme.of(context).brightness == Brightness.dark;

                // StackTrace'i ekranda 10 satırla sınırla
                String displayStack = '';
                if (log['stackTrace'] != null &&
                    log['stackTrace']!.isNotEmpty) {
                  final lines = log['stackTrace']!.split('\n');
                  if (lines.length > 10) {
                    displayStack =
                        '${lines.take(10).join('\n')}\n\n... (Tüm metni görmek için kopyalayın)';
                  } else {
                    displayStack = log['stackTrace']!;
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.3)
                          : Colors.red.shade100,
                    ),
                  ),
                  child: ExpansionTile(
                    leading: const Icon(Icons.bug_report, color: Colors.red),
                    title: Text(
                      log['error'] ?? 'Bilinmeyen Hata',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(formattedDate),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: isDark ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12) : Colors.grey.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detaylar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText('Error: ${log['error']}'),
                            const SizedBox(height: 8),
                            if (log['stackTrace'] != null &&
                                log['stackTrace']!.isNotEmpty &&
                                log['stackTrace'] != 'Belirtilmedi') ...[
                              const Text(
                                'StackTrace:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  displayStack,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _copyLog(log),
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Kopyala'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
