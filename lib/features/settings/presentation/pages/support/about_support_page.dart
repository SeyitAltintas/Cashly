import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../../core/services/haptic_service.dart';

/// Hakkında & Destek Sayfası
/// Uygulama bilgileri, yasal metinler, SSS ve paylaşım
class AboutSupportPage extends StatefulWidget {
  const AboutSupportPage({super.key});

  @override
  State<AboutSupportPage> createState() => _AboutSupportPageState();
}

class _AboutSupportPageState extends State<AboutSupportPage>
    with SingleTickerProviderStateMixin {
  // Fallback: pubspec.yaml'daki değerler
  String _appVersion = '1.0.0';
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  // SSS expand durumları
  final Map<int, bool> _expandedFaq = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadPackageInfo();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {
      // Native plugin yüklenemezse fallback değerler kullanılır
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.aboutAndSupport),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Uygulama logosu ve versiyon bilgisi
              _buildAppHeader(theme),
              const SizedBox(height: 28),

              // Yasal bölümü
              _buildSectionLabel(theme, context.l10n.legal),
              const SizedBox(height: 12),
              _buildLegalSection(theme),
              const SizedBox(height: 28),

              // Destek bölümü
              _buildSectionLabel(theme, context.l10n.support),
              const SizedBox(height: 12),
              _buildSupportSection(theme),
              const SizedBox(height: 28),

              // SSS bölümü
              _buildSectionLabel(theme, context.l10n.faq),
              const SizedBox(height: 12),
              _buildFaqSection(theme),
              const SizedBox(height: 32),

              // Alt bilgi
              _buildFooter(theme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UYGULAMA HEADER
  // ============================================================================

  Widget _buildAppHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.8,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Şeffaf Cashly logosu
          Image.asset(
            'assets/image/seffaflogo.png',
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(
              'Cashly',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Slogan
          Text(
            context.l10n.appSlogan,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 18),
          // Versiyon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'v$_appVersion',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // YASAL BÖLÜM
  // ============================================================================

  Widget _buildLegalSection(ThemeData theme) {
    return _buildCardGroup(
      theme,
      children: [
        _buildTile(
          theme,
          icon: Icons.privacy_tip_outlined,
          iconColor: Colors.teal,
          title: context.l10n.privacyPolicy,
          subtitle: context.l10n.privacyPolicyDesc,
          onTap: () => _showLegalSheet(
            context,
            title: context.l10n.privacyPolicy,
            content: context.l10n.privacyPolicyContent,
          ),
        ),
        _buildDivider(theme),
        _buildTile(
          theme,
          icon: Icons.description_outlined,
          iconColor: Colors.blue,
          title: context.l10n.termsOfService,
          subtitle: context.l10n.termsOfServiceDesc,
          onTap: () => _showLegalSheet(
            context,
            title: context.l10n.termsOfService,
            content: context.l10n.termsOfServiceContent,
          ),
        ),
        _buildDivider(theme),
        _buildTile(
          theme,
          icon: Icons.source_outlined,
          iconColor: Colors.orange,
          title: context.l10n.openSourceLicenses,
          subtitle: context.l10n.openSourceLicensesDesc,
          isLast: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: '',
            applicationVersion: '',
            applicationLegalese: '',
            applicationIcon: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.8,
                  colors: [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/image/seffaflogo.png',
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Cashly',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    context.l10n.appSlogan,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      'v$_appVersion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.copyright,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // DESTEK BÖLÜMÜ
  // ============================================================================

  Widget _buildSupportSection(ThemeData theme) {
    return _buildCardGroup(
      theme,
      children: [
        _buildTile(
          theme,
          icon: Icons.share_outlined,
          iconColor: Colors.green,
          title: context.l10n.shareApp,
          subtitle: context.l10n.shareAppDesc,
          isLast: true,
          onTap: _shareApp,
        ),
      ],
    );
  }

  // ============================================================================
  // SSS BÖLÜMÜ
  // ============================================================================

  Widget _buildFaqSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
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
        children: List.generate(_getFaqItems(context).length, (index) {
          final faq = _getFaqItems(context)[index];
          final isExpanded = _expandedFaq[index] ?? false;
          final isLast = index == _getFaqItems(context).length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticService.lightImpact();
                    setState(() {
                      _expandedFaq[index] = !isExpanded;
                    });
                  },
                  borderRadius: isLast && !isExpanded
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.amber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            faq['q']!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Cevap
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                  child: Text(
                    faq['a']!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              if (!isLast) _buildDivider(theme),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================================
  // ALT BİLGİ
  // ============================================================================

  Widget _buildFooter(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Text(
            context.l10n.footerMessage,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.copyright,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ORTAK WİDGET'LAR
  // ============================================================================

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: TextStyle(
        color: theme.colorScheme.secondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCardGroup(ThemeData theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    );
  }

  // ============================================================================
  // AKSİYONLAR
  // ============================================================================

  void _shareApp() {
    SharePlus.instance.share(ShareParams(text: context.l10n.shareText));
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sürükleme çubuğu
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Başlık
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.lastUpdated,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    ctx,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),
              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Theme.of(
                        ctx,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SABİT METİNLER
  // ============================================================================

  // SSS Öğeleri - Localized getter
  List<Map<String, String>> _getFaqItems(BuildContext context) {
    return [
      {'q': context.l10n.faqSafetyQ, 'a': context.l10n.faqSafetyA},
      {'q': context.l10n.faqOfflineQ, 'a': context.l10n.faqOfflineA},
      {'q': context.l10n.faqBackupQ, 'a': context.l10n.faqBackupA},
      {'q': context.l10n.faqRestoreQ, 'a': context.l10n.faqRestoreA},
      {'q': context.l10n.faqVoiceAssisQ, 'a': context.l10n.faqVoiceAssisA},
      {'q': context.l10n.faqBudgetLimitQ, 'a': context.l10n.faqBudgetLimitA},
      {
        'q': context.l10n.faqCategoryBudgetQ,
        'a': context.l10n.faqCategoryBudgetA,
      },
      {'q': context.l10n.faqRecurringQ, 'a': context.l10n.faqRecurringA},
      {
        'q': context.l10n.faqAssetTrackingQ,
        'a': context.l10n.faqAssetTrackingA,
      },
      {
        'q': context.l10n.faqPaymentMethodsQ,
        'a': context.l10n.faqPaymentMethodsA,
      },
      {'q': context.l10n.faqTransferQ, 'a': context.l10n.faqTransferA},
      {
        'q': context.l10n.faqNotificationsQ,
        'a': context.l10n.faqNotificationsA,
      },
      {'q': context.l10n.faqStreakQ, 'a': context.l10n.faqStreakA},
      {'q': context.l10n.faqProfilePhotoQ, 'a': context.l10n.faqProfilePhotoA},
      {'q': context.l10n.faqForgotPinQ, 'a': context.l10n.faqForgotPinA},
      {
        'q': context.l10n.faqDeleteAccountQ,
        'a': context.l10n.faqDeleteAccountA,
      },
    ];
  }
}
