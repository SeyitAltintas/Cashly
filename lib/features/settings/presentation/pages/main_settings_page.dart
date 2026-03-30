import 'package:flutter/material.dart';


import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/income/presentation/pages/income_settings_page.dart';
import 'appearance/appearance_page.dart';
import 'appearance/language_settings_page.dart';
import 'voice/voice_assistant_page.dart';
import 'appearance/haptic_settings_page.dart';
import 'notifications/notification_settings_page.dart';
import 'finance/expense_settings_page.dart';
import 'finance/currency_settings_page.dart';
import '../state/main_settings_state.dart';

import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';

// Modüler widget'lar
import '../widgets/settings_tile.dart';


/// Ayarlar Sayfası
class AyarlarSayfasi extends StatefulWidget {
  final AuthController authController;
  final VoidCallback? onNavigationReturn; // Alt sayfalardan dönüşte çağrılır

  const AyarlarSayfasi({
    super.key,
    required this.authController,
    this.onNavigationReturn,
  });

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  late final MainSettingsState _mainState;

  bool get _needsRefresh => _mainState.needsRefresh;

  @override
  void initState() {
    super.initState();
    _mainState = MainSettingsState();
    _mainState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mainState.removeListener(_onStateChanged);
    _mainState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _needsRefresh);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settings),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _needsRefresh),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.appSettings,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsContainer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.palette_outlined,
            iconColor: Colors.purple,
            title: context.l10n.appearance,
            subtitle: context.l10n.appearanceSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppearancePage()),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.language,
            iconColor: Colors.indigo,
            title: context.l10n.language,
            subtitle: context.l10n.languageSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.vibration,
            iconColor: Colors.cyan,
            title: context.l10n.hapticFeedback,
            subtitle: context.l10n.hapticFeedbackSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HapticSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: Colors.amber,
            title: context.l10n.notifications,
            subtitle: context.l10n.notificationsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.mic_outlined,
            iconColor: Colors.orange,
            title: context.l10n.voiceAssistant,
            subtitle: context.l10n.voiceAssistantSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VoiceAssistantPage(authController: widget.authController),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Colors.green,
            title: context.l10n.expenses,
            subtitle: context.l10n.expensesSubtitle,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HarcamalarAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) _mainState.needsRefresh = true;
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.trending_up,
            iconColor: Colors.teal,
            title: context.l10n.incomes,
            subtitle: context.l10n.incomesSubtitle,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GelirlerAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) _mainState.needsRefresh = true;
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.currency_exchange,
            iconColor: Colors.purpleAccent,
            title: context.l10n.mainCurrency,
            subtitle: context.l10n.mainCurrencySubtitle,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencySettingsPage(),
                ),
              );
              _mainState.needsRefresh = true;
            },
          ),
        ],
      ),
    );
  }
}

// HarcamalarAyarlariSayfasi ayrı dosyaya taşındı
// Bkz: expense_settings_page.dart
