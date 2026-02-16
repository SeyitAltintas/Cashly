import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/domain/notification_types.dart';
import '../../../../../core/repositories/notification_settings_repository.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/notification_scheduler.dart';
import '../../../../../core/widgets/month_year_picker.dart';

/// Bildirim ayarları sayfası
/// Her bildirim senaryosu için ayrı toggle switch'ler içerir
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = getIt<NotificationService>();
  final NotificationSettingsRepository _settingsRepo =
      getIt<NotificationSettingsRepository>();
  final NotificationScheduler _scheduler = getIt<NotificationScheduler>();

  late NotificationSettings _settings;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kullanıcı sistem ayarlarından döndüğünde izni kontrol et
    if (state == AppLifecycleState.resumed) {
      _refreshPermission();
    }
  }

  Future<void> _refreshPermission() async {
    final hasPermission = await _notificationService.hasPermission();
    if (mounted && hasPermission != _hasPermission) {
      setState(() => _hasPermission = hasPermission);
      if (hasPermission) {
        // İzin verildiyse bildirimleri planla
        await _scheduler.rescheduleAll();
        _showSnackBar('Bildirimler etkinleştirildi', Colors.green);
      }
    }
  }

  Future<void> _loadSettings() async {
    await _settingsRepo.init();
    final hasPermission = await _notificationService.hasPermission();

    if (mounted) {
      setState(() {
        _settings = _settingsRepo.getSettings();
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(NotificationSettings newSettings) async {
    setState(() => _settings = newSettings);
    await _settingsRepo.saveSettings(newSettings);

    // Zamanlanmış bildirimleri güncelle
    await _scheduler.rescheduleAll();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirimler"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Başlık
          _buildHeader(context),
          const SizedBox(height: 24),

          // İzin yoksa uyarı
          if (!_hasPermission) _buildPermissionWarning(context),
          if (!_hasPermission) const SizedBox(height: 16),

          // Bildirim senaryoları
          _buildSectionTitleWithToggle(
            context,
            'Bildirim Senaryoları',
            _areAllNotificationsEnabled(),
            _toggleAllNotifications,
          ),
          const SizedBox(height: 12),
          _buildNotificationScenarios(context),
          const SizedBox(height: 24),

          // Zamanlama ayarları
          _buildSectionTitle(context, 'Zamanlama Ayarları'),
          const SizedBox(height: 12),
          _buildScheduleSettings(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bildirim Ayarları",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Finansal hatırlatmalar ve uyarıları yönetin",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AppSettings.openAppSettings(type: AppSettingsType.notification),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Bildirim izni verilmedi",
                style: TextStyle(
                  color: Colors.orange.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              "Ayarları Aç",
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.orange.shade600,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Tüm bildirimlerin açık olup olmadığını kontrol et
  bool _areAllNotificationsEnabled() {
    return _settings.recurringReminderEnabled &&
        _settings.streakReminderEnabled &&
        _settings.monthlySummaryEnabled &&
        _settings.streakBreakWarningEnabled &&
        _settings.weeklyMiniSummaryEnabled;
  }

  /// Tüm bildirimleri aç/kapat
  Future<void> _toggleAllNotifications(bool enable) async {
    await _updateSettings(
      _settings.copyWith(
        recurringReminderEnabled: enable,
        streakReminderEnabled: enable,
        monthlySummaryEnabled: enable,
        streakBreakWarningEnabled: enable,
        weeklyMiniSummaryEnabled: enable,
      ),
    );
  }

  Widget _buildSectionTitleWithToggle(
    BuildContext context,
    String title,
    bool allEnabled,
    Future<void> Function(bool) onToggle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        GestureDetector(
          onTap: _hasPermission ? () => onToggle(!allEnabled) : null,
          child: Text(
            allEnabled ? 'Tümünü Kapat' : 'Tümünü Aç',
            style: TextStyle(
              color: _hasPermission
                  ? (allEnabled ? Colors.red.shade400 : Colors.green.shade400)
                  : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationScenarios(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          _buildScenarioTile(
            context,
            icon: Icons.event_repeat_rounded,
            iconColor: Colors.blue,
            title: "Tekrarlayan İşlem Hatırlatıcı",
            subtitle: "Ödeme/fatura gününden 1 gün önce",
            value: _settings.recurringReminderEnabled,
            onChanged: (v) => _updateSettings(
              _settings.copyWith(recurringReminderEnabled: v),
            ),
          ),
          _buildDivider(context),
          _buildScenarioTile(
            context,
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            title: "Seri Hatırlatıcı",
            subtitle: "Günlük işlem girişi hatırlatması",
            value: _settings.streakReminderEnabled,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(streakReminderEnabled: v)),
          ),
          _buildDivider(context),
          _buildScenarioTile(
            context,
            icon: Icons.crisis_alert_rounded,
            iconColor: Colors.red,
            title: "Son Şans Uyarısı",
            subtitle: "Her gün 22:00 - seri kırılma riski",
            value: _settings.streakBreakWarningEnabled,
            onChanged: (v) => _updateSettings(
              _settings.copyWith(streakBreakWarningEnabled: v),
            ),
          ),
          _buildDivider(context),
          _buildScenarioTile(
            context,
            icon: Icons.bar_chart_rounded,
            iconColor: Colors.purple,
            title: "Aylık Özet",
            subtitle: "Her ayın son günü finansal özet",
            value: _settings.monthlySummaryEnabled,
            onChanged: (v) =>
                _updateSettings(_settings.copyWith(monthlySummaryEnabled: v)),
          ),
          _buildDivider(context),
          _buildScenarioTile(
            context,
            icon: Icons.date_range_rounded,
            iconColor: Colors.teal,
            title: "Haftalık Rapor",
            subtitle: "Her Pazar 18:00 - en çok harcama kategorisi",
            value: _settings.weeklyMiniSummaryEnabled,
            onChanged: (v) => _updateSettings(
              _settings.copyWith(weeklyMiniSummaryEnabled: v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSettings(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Seri hatırlatıcı saati
          _buildTimeTile(
            context,
            icon: Icons.access_time_rounded,
            iconColor: Colors.orange,
            title: "Seri Hatırlatıcı Saati",
            time: TimeOfDay(
              hour: _settings.streakReminderHour,
              minute: _settings.streakReminderMinute,
            ),
            enabled: _settings.streakReminderEnabled,
            onTap: () => _selectStreakTime(context),
          ),
          _buildDivider(context),
          // Aylık özet saati
          _buildMonthlySummaryTimeTile(
            context,
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.purple,
            title: "Aylık Özet Saati",
            hour: _settings.monthlySummaryHour,
            minute: _settings.monthlySummaryMinute,
            enabled: _settings.monthlySummaryEnabled,
            onTap: () => _selectMonthlySummaryTime(context),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      activeTrackColor: iconColor.withValues(alpha: 0.4),
      activeThumbColor: iconColor,
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
      inactiveThumbColor: Colors.grey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: _hasPermission ? onChanged : null,
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required TimeOfDay time,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: enabled ? iconColor : Colors.grey, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: enabled ? 1 : 0.5),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          timeStr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? iconColor : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: enabled && _hasPermission ? onTap : null,
    );
  }

  Widget _buildMonthlySummaryTimeTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required int hour,
    required int minute,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: enabled ? iconColor : Colors.grey, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: enabled ? 1 : 0.5),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Her ayın son günü',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: enabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          timeStr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? iconColor : Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: enabled && _hasPermission ? onTap : null,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 20,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }

  Future<void> _selectStreakTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(
      now.year,
      now.month,
      now.day,
      _settings.streakReminderHour,
      _settings.streakReminderMinute,
    );

    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: initialDate,
      mode: PickerMode.time,
      accentColor: Colors.orange,
    );

    if (selectedDate != null && context.mounted) {
      await _updateSettings(
        _settings.copyWith(
          streakReminderHour: selectedDate.hour,
          streakReminderMinute: selectedDate.minute,
        ),
      );
    }
  }

  Future<void> _selectMonthlySummaryTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(
      now.year,
      now.month,
      now.day,
      _settings.monthlySummaryHour,
      _settings.monthlySummaryMinute,
    );

    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: initialDate,
      mode: PickerMode.time,
      accentColor: Colors.purple,
    );

    if (selectedDate != null && context.mounted) {
      await _updateSettings(
        _settings.copyWith(
          monthlySummaryHour: selectedDate.hour,
          monthlySummaryMinute: selectedDate.minute,
        ),
      );
    }
  }
}
