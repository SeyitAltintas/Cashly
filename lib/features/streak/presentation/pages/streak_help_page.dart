import 'package:flutter/material.dart';

/// Seri özelliği hakkında bilgi sayfası
/// Accordion menü ile tüm özellikleri açıklar
class StreakHelpPage extends StatelessWidget {
  const StreakHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seri Nasıl Çalışır?'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kartı
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            // Accordion menüler
            _buildExpansionTile(
              context,
              icon: Icons.local_fire_department,
              iconColor: const Color(0xFFFF6B35),
              title: 'Seri Nedir?',
              content: '''
Seri, uygulamayı art arda kaç gün açtığınızı gösteren bir sayaçtır.

• Her gün uygulamayı açtığınızda seriniz 1 artar
• Bir gün atlarsanız seriniz sıfırlanır
• Gün içinde birden fazla giriş yapmanız sadece 1 giriş olarak sayılır

Seri sistemi, finansal alışkanlıklarınızı takip etmenizi ve düzenli olmanızı teşvik eder.''',
            ),

            _buildExpansionTile(
              context,
              icon: Icons.ac_unit,
              iconColor: const Color(0xFF00BCD4),
              title: 'Seri Koruyucu Nedir?',
              content: '''
Seri Koruyucu, bir gün uygulamayı açmayı unutsanız bile serinizi koruyan özel bir özelliktir.

• Yeni kullanıcılar 1 seri koruyucu ile başlar
• Her 7 günlük seride 1 yeni koruyucu kazanırsınız
• Maksimum 3 koruyucu biriktirebilirsiniz
• 1 gün atlarsanız otomatik olarak kullanılır
• 2 veya daha fazla gün atlarsanız seri sıfırlanır''',
            ),

            _buildExpansionTile(
              context,
              icon: Icons.military_tech,
              iconColor: const Color(0xFFFFD700),
              title: 'Rozetler',
              content: '''
Belirli seri hedeflerine ulaştığınızda rozetler kazanırsınız:

🔥 Ateş Başlangıcı - 3 günlük seri
⭐ Haftalık Yıldız - 7 günlük seri
💪 Kararlı - 14 günlük seri
🏅 Aylık Şampiyon - 30 günlük seri
💎 Süper Seri - 60 günlük seri
👑 Seri Ustası - 100 günlük seri
🏆 Efsane - 365 günlük seri

Rozetler kalıcıdır, seri sıfırlansa bile kaybolmaz!''',
            ),

            _buildExpansionTile(
              context,
              icon: Icons.emoji_events,
              iconColor: const Color(0xFF9C27B0),
              title: 'Başarılar',
              content: '''
Başarılar, uygulamayı kullanırken elde ettiğiniz özel hedeflerdir:

✓ İlk Adım - Uygulamayı ilk kez açın
✓ Seri Başlatıcı - 3 günlük seri oluşturun
✓ Seri Koruyucu - Bir seri koruyucu kullanın
✓ Düzenli Kullanıcı - Toplam 10 gün giriş yapın
✓ Süreklilik Ustası - 30 günlük seri oluşturun
✓ Finansal Guru - Toplam 100 gün giriş yapın

Başarıları tamamladığınızda yeşil onay işareti görürsünüz.''',
            ),

            _buildExpansionTile(
              context,
              icon: Icons.bar_chart,
              iconColor: const Color(0xFF4CAF50),
              title: 'İstatistikler',
              content: '''
Seri sayfasında aşağıdaki istatistikleri görebilirsiniz:

📊 Mevcut Seri - Şu anki ardışık giriş sayınız
🏆 En Uzun Seri - Şimdiye kadarki en yüksek seriniz
📅 Toplam Giriş - Uygulamayı açtığınız toplam gün sayısı
❄️ Seri Koruyucu - Elinizdeki koruyucu sayısı

Bu istatistikler ilerlemenizi takip etmenize yardımcı olur.''',
            ),

            _buildExpansionTile(
              context,
              icon: Icons.tips_and_updates,
              iconColor: const Color(0xFFFF9800),
              title: 'İpuçları',
              content: '''
Serinizi korumak için bazı ipuçları:

💡 Her gün aynı saatte uygulamayı açmayı alışkanlık haline getirin
💡 Bildirimler açıksa günlük hatırlatıcı alabilirsiniz
💡 Seri koruyucularınızı tatil veya yoğun günler için saklayın
💡 7, 14, 30 gibi hedefler belirleyin
💡 En uzun seri rekorunuzu kırmaya çalışın

Düzenli finansal takip, daha iyi para yönetimi demektir!''',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.2),
            const Color(0xFFFF8C00).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 48,
            color: Color(0xFFFF6B35),
          ),
          const SizedBox(height: 16),
          Text(
            'Seri Sistemi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finansal alışkanlıklarınızı geliştirin ve\ndüzenli takip ödüllerini kazanın!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          iconColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          collapsedIconColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content.trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
