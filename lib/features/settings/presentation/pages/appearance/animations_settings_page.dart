import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../../core/theme/theme_manager.dart';

class AnimationsSettingsPage extends StatelessWidget {
  const AnimationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.animations),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.animationPreferences,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.animationPreferencesDescription,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ayarlar Listesi
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (context) {
                  final isMoneyAnimationEnabled = context.select(
                    (ThemeManager t) => t.isMoneyAnimationEnabled,
                  );
                  final themeManager = context.read<ThemeManager>();

                  return Column(
                    children: [
                      // Para Animasyonu Switch
                      SwitchListTile(
                        activeTrackColor: ColorConstants.yesil.withValues(alpha: 0.5),
                        activeThumbColor: ColorConstants.yesil,
                        inactiveTrackColor: ColorConstants.kirmiziVurgu.withValues(alpha: 0.3),
                        inactiveThumbColor: ColorConstants.kirmiziVurgu,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ColorConstants.yesil.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: ColorConstants.yesil,
                          ),
                        ),
                        title: Text(
                          context.l10n.moneyAnimation,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            context.l10n.moneyAnimationDescription,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        value: isMoneyAnimationEnabled,
                        onChanged: (value) {
                          themeManager.toggleMoneyAnimation(value);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
