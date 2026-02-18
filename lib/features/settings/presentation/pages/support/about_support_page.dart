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
            content: _privacyPolicyText,
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
            content: _termsOfServiceText,
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
        children: List.generate(_faqItems.length, (index) {
          final faq = _faqItems[index];
          final isExpanded = _expandedFaq[index] ?? false;
          final isLast = index == _faqItems.length - 1;

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

  static const String _privacyPolicyText = '''
1. Giriş

Bu Gizlilik Politikası, Cashly uygulamasının ("Uygulama") kullanıcılarının kişisel verilerinin nasıl toplandığını, saklandığını ve korunduğunu açıklamaktadır. Uygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.

Son güncelleme: 17 Şubat 2026

2. Veri Toplama ve Kullanım

Cashly, tüm verilerinizi yalnızca cihazınızda (yerel olarak) saklar. Sunucularımıza herhangi bir kişisel veri gönderilmez, aktarılmaz veya iletilmez.

Toplanan ve cihazda saklanan veriler:
• Kullanıcı bilgileri (isim ve e-posta adresi)
• Harcama ve gelir kayıtları (tutar, kategori, tarih, açıklama)
• Varlık bilgileri (tür, miktar, değer)
• Ödeme yöntemleri ve bakiye bilgileri
• Transfer kayıtları
• Bütçe limitleri ve kategori bütçeleri
• Profil fotoğrafı (isteğe bağlı)
• Uygulama tercihleri ve ayarları
• Seri (streak) kayıtları

Bu veriler yalnızca uygulamanın temel işlevlerini sağlamak amacıyla kullanılır.

3. Veri Güvenliği

Verilerinizin güvenliği bizim için en önemli önceliktir:

• Tüm veriler cihazınızda yerel veritabanında saklanır.
• 4 haneli PIN kodu ile uygulamaya erişim korunur.
• Biyometrik doğrulama (parmak izi / yüz tanıma) desteği mevcuttur.
• Güvenlik sorusu ile ek koruma katmanı sağlanır.
• Uygulama arka plana alındığında otomatik kilit devreye girer.
• Uygulama dışarıya herhangi bir ağ bağlantısı kurmaz.

4. Üçüncü Taraf Paylaşımı

Cashly, topladığı hiçbir veriyi üçüncü taraflarla paylaşmaz, satmaz veya kiralamaz. Verileriniz tamamen size aittir. Uygulama içinde üçüncü taraf analitik veya reklam araçları kullanılmamaktadır.

5. Veri Yedekleme ve Aktarım

• Yedekleme işlemi tamamen kullanıcı kontrolündedir ve isteğe bağlıdır.
• Yedek dosyaları JSON formatında cihazınıza dışa aktarılır.
• Yedek dosyasının güvenliği ve saklanması kullanıcının sorumluluğundadır.
• Yedek dosyası; harcamalar, gelirler, varlıklar, ödeme yöntemleri, transferler ve profil bilgilerini içerir.
• Geri yükleme işlemi mevcut verilerin üzerine yazar.

6. Veri Saklama Süresi

Verileriniz, hesabınızı silene kadar cihazınızda saklanır. Uygulamayı kaldırmanız durumunda tüm veriler otomatik olarak silinir.

7. Veri Silme Hakkı

Hesabınızı ve tüm verilerinizi istediğiniz zaman kalıcı olarak silebilirsiniz:
• Profil > Kullanıcı Bilgileri > Hesabı Sil seçeneğini kullanın.
• Silme işlemi güvenlik doğrulaması gerektirir.
• Silinen veriler geri getirilemez.
• Silme öncesi yedek almanız önerilir.

8. Çocukların Gizliliği

Cashly, 13 yaşın altındaki çocuklara yönelik değildir. 13 yaşın altındaki kullanıcılardan bilerek veri toplamıyoruz.

9. Politika Değişiklikleri

Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir.

10. İletişim

Gizlilik politikamız hakkında sorularınız veya talepleriniz için uygulama içinden bizimle iletişime geçebilirsiniz.''';

  static const String _termsOfServiceText = '''
1. Kabul ve Kapsam

Cashly uygulamasını ("Uygulama") indirerek, kurarak veya kullanarak bu Kullanım Koşullarını kabul etmiş olursunuz. Bu koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayınız.

Son güncelleme: 17 Şubat 2026

2. Hizmet Tanımı

Cashly, kişisel bütçe takibi ve finansal yönetim aracıdır. Uygulama aşağıdaki hizmetleri sunar:

• Harcama ve gelir takibi (manuel ve sesli giriş)
• Varlık yönetimi (altın, döviz, kripto, banka hesabı)
• Bütçe planlama ve kategori bazlı limit belirleme
• Ödeme yöntemi yönetimi ve bakiye takibi
• Hesaplar arası transfer kayıtları
• Düzenli gelir/gider tanımlama
• Sesli asistan ile doğal dil komutları
• Veri yedekleme ve geri yükleme
• İstatistik ve grafik raporları

3. Hesap ve Güvenlik

• Hesabınızı oluştururken doğru bilgiler girmeniz gerekmektedir.
• PIN kodunuz hesabınızın güvenlik anahtarıdır; kimseyle paylaşmayınız.
• Biyometrik giriş ve güvenlik sorusu ek koruma katmanlarıdır.
• Hesabınıza yetkisiz erişimden siz sorumlusunuz.
• Şüpheli bir durum fark ederseniz PIN kodunuzu değiştirmeniz önerilir.

4. Kullanıcı Sorumlulukları

• Girdiğiniz finansal veriler tamamen size aittir ve doğruluğundan siz sorumlusunuz.
• Uygulamayı yasa dışı amaçlarla kullanamazsınız.
• Düzenli veri yedeklemesi yapmanız önerilir.
• Yedek dosyalarınızın güvenliğinden siz sorumlusunuz.
• Uygulamayı tersine mühendislik, kaynak kod çıkarma veya değiştirme girişiminde bulunamazsınız.

5. Sorumluluk Reddi

ÖNEMLİ - Lütfen dikkatlice okuyunuz:

• Cashly bir finansal danışmanlık, yatırım tavsiyesi veya muhasebe aracı değildir.
• Uygulama, herhangi bir yatırım, tasarruf veya harcama tavsiyesi vermez.
• Finansal kararlarınızdan Cashly sorumlu tutulamaz.
• Uygulama "olduğu gibi" sunulmaktadır; kesintisiz veya hatasız çalışacağı garanti edilmez.
• Cihaz arızası, yazılım hatası veya kullanıcı kaynaklı veri kaybından dolayı sorumluluk kabul edilmez.
• Güncel döviz kurları ve varlık fiyatları bilgi amaçlıdır; gerçek piyasa değerlerinden farklılık gösterebilir.

6. Veri ve İçerik

• Uygulamaya girdiğiniz tüm veriler cihazınızda saklanır.
• Verilerin doğruluğu, bütünlüğü ve güncelliğinden siz sorumlusunuz.
• Hesap silme işlemi geri alınamaz; tüm verileriniz kalıcı olarak kaldırılır.

7. Fikri Mülkiyet

• Cashly uygulaması, tasarımı, logoları ve tüm içeriği telif hakkı ile korunmaktadır.
• Uygulama kodunun, görsellerinin ve tasarımının izinsiz kopyalanması, dağıtılması veya türev çalışma oluşturulması yasaktır.
• "Cashly" ismi ve logosu tescilli markadır.

8. Hizmet Değişiklikleri

• Uygulama özellikleri önceden haber verilmeksizin eklenebilir, değiştirilebilir veya kaldırılabilir.
• Güncellemeler, hata düzeltmeleri ve iyileştirmeler düzenli olarak yapılabilir.

9. Koşul Değişiklikleri

Bu kullanım koşulları zaman zaman güncellenebilir. Önemli değişiklikler uygulama içinden bildirilecektir. Güncellemelerden sonra uygulamayı kullanmaya devam etmeniz, yeni koşulları kabul ettiğiniz anlamına gelir.

10. Geçerli Hukuk

Bu koşullar Türkiye Cumhuriyeti yasalarına tabidir. Uyuşmazlıklarda Türkiye mahkemeleri yetkilidir.

11. İletişim

Kullanım koşullarımız hakkında sorularınız için uygulama içinden bizimle iletişime geçebilirsiniz.''';

  // SSS Öğeleri
  static const List<Map<String, String>> _faqItems = [
    {
      'q': 'Verilerim güvende mi?',
      'a':
          'Kesinlikle! Cashly, gizliliğinizi en üst düzeyde korur:\n\n'
          '• Tüm verileriniz yalnızca cihazınızda saklanır, hiçbir sunucuya gönderilmez.\n'
          '• 4 haneli PIN kodu ile uygulamaya erişim korunur.\n'
          '• Biyometrik giriş (parmak izi / yüz tanıma) desteği mevcuttur.\n'
          '• Güvenlik sorusu ile ek koruma katmanı ekleyebilirsiniz.\n\n'
          'Verileriniz tamamen size aittir ve hiçbir üçüncü tarafla paylaşılmaz.',
    },
    {
      'q': 'İnternet bağlantısı gerekli mi?',
      'a':
          'Hayır! Cashly tamamen çevrimdışı çalışacak şekilde tasarlanmıştır.\n\n'
          '• Harcama ve gelir ekleme, düzenleme, silme\n'
          '• Varlık yönetimi ve takibi\n'
          '• Bütçe planlama ve kategori yönetimi\n'
          '• Sesli asistan ile komut verme\n'
          '• Veri yedekleme ve geri yükleme\n\n'
          'Tüm bu özellikler internet olmadan sorunsuz çalışır. '
          'Yalnızca güncel döviz/altın kurları için internet bağlantısı gerekebilir.',
    },
    {
      'q': 'Verilerimi nasıl yedekleyebilirim?',
      'a':
          'Verilerinizi güvence altına almak için düzenli yedekleme yapmanızı öneririz:\n\n'
          '1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n'
          '2. "Verileri Yedekle" seçeneğine dokunun.\n'
          '3. Tüm verileriniz JSON formatında bir dosyaya aktarılır.\n'
          '4. Dosyayı Google Drive, e-posta veya istediğiniz bir yere kaydedin.\n\n'
          'Yedek dosyası; harcamalarınızı, gelirlerinizi, varlıklarınızı, '
          'ödeme yöntemlerinizi, transferlerinizi ve profil bilgilerinizi içerir.',
    },
    {
      'q': 'Yedeğimi nasıl geri yüklerim?',
      'a':
          'Daha önce aldığınız yedeği geri yüklemek için:\n\n'
          '1. Profil > Ayarlar > Veri İşlemleri bölümüne gidin.\n'
          '2. "Verileri Geri Yükle" seçeneğine dokunun.\n'
          '3. Daha önce kaydettiğiniz JSON yedek dosyasını seçin.\n'
          '4. İşlem tamamlandığında uygulama otomatik olarak yenilenir.\n\n'
          'Dikkat: Geri yükleme işlemi mevcut verilerinizi yedekteki verilerle değiştirir. '
          'Mevcut verilerinizi kaybetmemek için önce yeni bir yedek almanızı öneririz.',
    },
    {
      'q': 'Sesli asistan nasıl çalışır?',
      'a':
          'Cashly\'nin sesli asistanı, doğal dil ile harcama ve gelir eklemenizi sağlar:\n\n'
          '• Ana ekrandaki mikrofon ikonuna dokunun.\n'
          '• Doğal bir şekilde komut verin, örneğin:\n'
          '  - "50 lira market harcaması ekle"\n'
          '  - "1500 lira maaş geliri ekle"\n'
          '  - "200 lira yemek harcaması ekle nakit ile"\n\n'
          'Asistan, tutarı, kategoriyi ve ödeme yöntemini otomatik olarak algılar. '
          'Sesli geri bildirim ile işlemin başarılı olduğunu onaylar. '
          'Komut listesinin tamamını Ayarlar > Sesli Asistan bölümünden görebilirsiniz.',
    },
    {
      'q': 'Bütçe limitimi nasıl belirlerim?',
      'a':
          'Aylık harcama bütçenizi kontrol altında tutmak için:\n\n'
          '1. Profil > Ayarlar > Harcamalar bölümüne gidin.\n'
          '2. "Aylık Bütçe Limiti" alanına toplam aylık bütçenizi girin.\n'
          '3. Kaydet butonuna dokunun.\n\n'
          'Bütçe limitinizi belirledikten sonra:\n'
          '• Ana ekranda bütçe doluluk oranınızı görebilirsiniz.\n'
          '• Limiti aşmaya yaklaştığınızda görsel uyarı alırsınız.\n'
          '• Renk kodları ile durumunuzu anlık takip edebilirsiniz '
          '(yeşil: güvenli, sarı: dikkat, kırmızı: limit aşıldı).',
    },
    {
      'q': 'Kategori bazında bütçe limiti nedir?',
      'a':
          'Genel bütçe limitinin yanı sıra her kategori için ayrı limit belirleyebilirsiniz:\n\n'
          '1. Profil > Ayarlar > Harcamalar > Kategori Bütçeleri bölümüne gidin.\n'
          '2. İstediğiniz kategoriye dokunun (örn. Yemek & Kafe).\n'
          '3. O kategori için aylık limit belirleyin.\n\n'
          'Örnek kullanım:\n'
          '• Yemek & Kafe: 2.000₺\n'
          '• Ulaşım: 500₺\n'
          '• Eğlence: 1.000₺\n\n'
          'Bu sayede harcamalarınızı kategori bazında detaylı kontrol edebilir '
          've hangi alanda tasarruf yapabileceğinizi görebilirsiniz.',
    },
    {
      'q': 'Düzenli gelir/gider nedir?',
      'a':
          'Her ay düzenli olarak tekrarlayan gelir veya giderlerinizi tanımlayabilirsiniz:\n\n'
          'Düzenli gelir örnekleri: Maaş, kira geliri, yan gelir\n'
          'Düzenli gider örnekleri: Kira, internet, telefon faturası, abonelikler\n\n'
          'Nasıl eklenir:\n'
          '1. Ayarlar > Harcamalar veya Gelirler bölümüne gidin.\n'
          '2. "Düzenli İşlemler" seçeneğine dokunun.\n'
          '3. Tutar, kategori ve tekrar sıklığını belirleyin.\n\n'
          'Düzenli işlemler her ay otomatik olarak kaydedilir, '
          'böylece her seferinde manuel ekleme yapmanıza gerek kalmaz.',
    },
    {
      'q': 'Varlık takibi nasıl yapılır?',
      'a':
          'Cashly ile finansal varlıklarınızı tek bir yerden takip edebilirsiniz:\n\n'
          'Desteklenen varlık türleri:\n'
          '• Altın (gram, çeyrek, yarım, tam)\n'
          '• Döviz (USD, EUR vb.)\n'
          '• Kripto para\n'
          '• Banka hesapları\n'
          '• Gümüş\n\n'
          'Varlıklarınızı ekleyin, miktarını ve alış fiyatını girin. '
          'Toplam portföy değerinizi, kazanç/kayıp durumunuzu '
          've varlık dağılımınızı grafiklerle takip edin.',
    },
    {
      'q': 'Ödeme yöntemlerimi nasıl yönetirim?',
      'a':
          'Farklı ödeme yöntemlerinizi tanımlayarak harcamalarınızı detaylı takip edin:\n\n'
          '• Nakit\n'
          '• Banka/kredi kartları\n'
          '• Dijital cüzdanlar\n\n'
          'Her ödeme yöntemine bakiye tanımlayabilir ve harcama yaptıkça '
          'bakiyenin otomatik güncellenmesini sağlayabilirsiniz. '
          'Bu sayede hangi karttan ne kadar harcadığınızı veya '
          'kasanızda ne kadar nakit kaldığını anlık görebilirsiniz.',
    },
    {
      'q': 'Hesaplar arası transfer nasıl yapılır?',
      'a':
          'Ödeme yöntemleriniz arasında para transferi kaydedebilirsiniz:\n\n'
          'Örnek senaryolar:\n'
          '• Bankadan nakit çekme\n'
          '• Kredi kartı borcunu ödeme\n'
          '• Bir hesaptan diğerine aktarım\n\n'
          'Transfer işlemi, kaynak hesaptan tutarı düşer ve hedef hesaba ekler. '
          'Böylece tüm hesaplarınızın bakiyesi her zaman güncel kalır. '
          'Transfer geçmişinizi Ayarlar > Para Transferleri bölümünden görüntüleyebilirsiniz.',
    },
    {
      'q': 'Bildirimler ne işe yarar?',
      'a':
          'Cashly, finansal hedeflerinizi takip etmeniz için çeşitli bildirimler sunar:\n\n'
          '• Günlük hatırlatıcı: Harcamalarınızı girmeyi unutmayın.\n'
          '• Bütçe uyarısı: Aylık limitinize yaklaştığınızda uyarı alın.\n'
          '• Düzenli işlem bildirimi: Tekrarlayan gelir/giderler kaydedildiğinde bilgilenin.\n\n'
          'Tüm bildirim ayarlarını Profil > Ayarlar > Bildirimler bölümünden '
          'istediğiniz gibi açıp kapatabilir ve saatlerini özelleştirebilirsiniz.',
    },
    {
      'q': 'Seri sistemi nedir?',
      'a':
          'Seri sistemi, düzenli kullanım alışkanlığı oluşturmanıza yardımcı olan '
          'bir motivasyon aracıdır:\n\n'
          '• Her gün uygulamayı kullanarak serinizi sürdürün.\n'
          '• Ardışık gün sayınız arttıkça seri seviyeniz yükselir.\n'
          '• Belirli seviyelere ulaştığınızda kutlama animasyonu görürsünüz.\n'
          '• Bir gün kaçırırsanız seriniz sıfırlanır.\n\n'
          'Seri sistemi, harcamalarınızı düzenli takip etme alışkanlığı kazanmanıza '
          'yardımcı olur. En yüksek serinizi kırmaya çalışın!',
    },
    {
      'q': 'Profil fotoğrafımı nasıl değiştiririm?',
      'a':
          'Profil fotoğrafınızı değiştirmek için:\n\n'
          '1. Profil > Kullanıcı Bilgileri sayfasına gidin.\n'
          '2. Profil fotoğrafınızın üzerindeki düzenleme ikonuna dokunun.\n'
          '3. Galeriden fotoğraf seçin veya hazır avatarlardan birini kullanın.\n'
          '4. Seçtiğiniz fotoğrafı kırpın, döndürün ve filtre uygulayın.\n\n'
          'Fotoğraf düzenleyici ile fotoğrafınızı tam istediğiniz gibi ayarlayabilirsiniz.',
    },
    {
      'q': 'PIN kodumu unutursam ne yapmalıyım?',
      'a':
          'PIN kodunuzu unuttuysanız, giriş ekranında güvenlik sorunuzu '
          'kullanarak sıfırlama yapabilirsiniz. Bunun için önceden '
          'bir güvenlik sorusu ve cevabı belirlemiş olmanız gerekir.\n\n'
          'Güvenlik sorunuzu ayarlamak için:\n'
          'Profil > Kullanıcı Bilgileri > Güvenlik bölümünü kullanabilirsiniz.\n\n'
          'Güvenlik sorusu belirlememişseniz ve PIN\'inizi unuttuysanız, '
          'uygulamayı yeniden kurmanız gerekebilir. Bu durumda yedeğiniz varsa '
          'verilerinizi geri yükleyebilirsiniz.',
    },
    {
      'q': 'Hesabımı silersem ne olur?',
      'a':
          'Hesap silme işlemi kalıcıdır ve geri alınamaz. Silinen veriler:\n\n'
          '• Tüm harcama kayıtları\n'
          '• Tüm gelir kayıtları\n'
          '• Varlıklarınız\n'
          '• Ödeme yöntemleri ve bakiyeleri\n'
          '• Transfer geçmişi\n'
          '• Seri kayıtları\n'
          '• Profil bilgileri ve fotoğrafınız\n\n'
          'Silmeden önce mutlaka verilerinizi yedeklemenizi öneririz. '
          'Hesap silme işlemi güvenlik doğrulaması (matematik sorusu) '
          'gerektirir ve iki aşamalı onay ile gerçekleştirilir.',
    },
  ];
}
