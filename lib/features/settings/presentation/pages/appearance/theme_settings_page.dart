import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.appearance,
        ), // Could add specific translation like themeSettings
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tema Ayarları", // Hardcoded translation placeholder
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Uygulamanın genel görünüm temasını değiştirin.",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: RadioGroup<ThemeMode>(
                    groupValue: themeManager.themeMode,
                    onChanged: (ThemeMode? value) {
                      if (value != null) themeManager.setThemeMode(value);
                    },
                    child: Column(
                      children: [

                        RadioListTile<ThemeMode>(
                          title: Text(
                            'Açık Tema',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          value: ThemeMode.light,
                        ),
                        Divider(
                          height: 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(
                            'Koyu Tema',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          value: ThemeMode.dark,
                        ),
                      ],
                    ),
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
