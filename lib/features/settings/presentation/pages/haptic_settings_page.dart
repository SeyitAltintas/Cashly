import 'package:flutter/material.dart';
import '../../../../core/services/haptic_service.dart';

/// Haptic (titreşim) geri bildirim ayarları sayfası
/// Kullanıcı tüm titreşim tiplerini ayrı ayrı açıp kapatabilir
class HapticSettingsPage extends StatefulWidget {
  const HapticSettingsPage({super.key});

  @override
  State<HapticSettingsPage> createState() => _HapticSettingsPageState();
}

class _HapticSettingsPageState extends State<HapticSettingsPage> {
  late Map<String, bool> _settings;
  bool _hasVibrator = false;

  @override
  void initState() {
    super.initState();
    _settings = HapticService.getAllSettings();
    _checkVibrator();
  }

  Future<void> _checkVibrator() async {
    final has = await HapticService.hasVibrator();
    if (mounted) {
      setState(() => _hasVibrator = has);
    }
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _settings[key] = value;
    });
    HapticService.setSetting(key, value);

    // Test titreşimi
    if (value) {
      HapticService.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterEnabled = _settings[HapticService.keyMasterEnabled] ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Titreşim Geri Bildirimi"),
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

          // Cihaz durumu
          if (!_hasVibrator) _buildWarningCard(context),

          if (!_hasVibrator) const SizedBox(height: 16),

          // Ana anahtar
          _buildMasterSwitch(context, masterEnabled),
          const SizedBox(height: 16),

          // Detaylı ayarlar
          AnimatedOpacity(
            opacity: masterEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !masterEnabled,
              child: _buildDetailedSettings(context),
            ),
          ),

          const SizedBox(height: 20),

          // Bilgi kutusu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Titreşim geri bildiriminin çalışabilmesi için cihazınızın ayarlarından \"Dokunma geri bildirimi\" veya \"Titreşim\" özelliğinin açık olması gerekmektedir.",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            "Dokunsal Geri Bildirim",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Önemli işlemlerde titreşim geri bildirimi alın",
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

  Widget _buildWarningCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bu cihazda titreşim özelliği algılanamadı.",
              style: TextStyle(color: Colors.orange.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch(BuildContext context, bool value) {
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
      child: SwitchListTile(
        activeTrackColor: Colors.green.withValues(alpha: 0.5),
        activeThumbColor: Colors.green,
        inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
        inactiveThumbColor: Colors.red,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (value ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.vibration,
            color: value ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          "Titreşimi Etkinleştir",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value ? "Tüm titreşimler açık" : "Tüm titreşimler kapalı",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: (v) => _updateSetting(HapticService.keyMasterEnabled, v),
      ),
    );
  }

  Widget _buildDetailedSettings(BuildContext context) {
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
          _buildSettingTile(
            context,
            icon: Icons.touch_app_outlined,
            iconColor: Colors.blue,
            title: "Buton Tıklamaları",
            subtitle: "Butonlara dokunduğunuzda",
            settingKey: HapticService.keyButtonTaps,
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.swipe_rounded,
            iconColor: Colors.purple,
            title: "Navigasyon",
            subtitle: "Sayfa geçişleri ve seçici kaydırmaları",
            settingKey: HapticService.keyNavigation,
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.red,
            title: "Silme İşlemleri",
            subtitle: "Öğe sildiğinizde",
            settingKey: HapticService.keyDelete,
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.green,
            title: "Başarı Bildirimi",
            subtitle: "İşlem başarılı olduğunda",
            settingKey: HapticService.keySuccess,
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.error_outline_rounded,
            iconColor: Colors.orange,
            title: "Hata Bildirimi",
            subtitle: "Hata oluştuğunda",
            settingKey: HapticService.keyError,
          ),
          _buildDivider(context),
          _buildSettingTile(
            context,
            icon: Icons.celebration_outlined,
            iconColor: Colors.amber,
            title: "Seri Kutlama",
            subtitle: "Seri arttığında kutlama titreşimi",
            settingKey: HapticService.keyCelebration,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String settingKey,
  }) {
    final value = _settings[settingKey] ?? true;

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
      onChanged: (v) => _updateSetting(settingKey, v),
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
}
