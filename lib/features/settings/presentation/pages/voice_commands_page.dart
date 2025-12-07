import 'package:flutter/material.dart';

/// Tüm sesli komutları detaylı listeleyen sayfa
class VoiceCommandsPage extends StatelessWidget {
  const VoiceCommandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Komutlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Açıklama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aşağıdaki komutları sesli asistanla kullanabilirsiniz.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Harcama Ekleme
            _buildCommandSection(
              context,
              icon: Icons.add_circle_outline,
              title: 'Harcama Ekleme',
              description:
                  'Tutarı, kategoriyi ve opsiyonel olarak tarihi söyleyerek harcama ekleyin.',
              examples: [
                '100 lira market',
                '50 TL kahve',
                'Dün 80 lira market',
                'Geçen pazartesi 200 TL benzin',
                'Önceki gün 150 lira yemek',
              ],
            ),

            const SizedBox(height: 16),

            // Harcama Silme
            _buildCommandSection(
              context,
              icon: Icons.delete_outline,
              title: 'Harcama Silme',
              description: 'Son eklediğiniz harcamayı silin.',
              examples: [
                'Son harcamayı sil',
                'Sonuncuyu sil',
                'Son eklediğimi sil',
                'Son kaydı sil',
              ],
            ),

            const SizedBox(height: 16),

            // Harcama Düzenleme
            _buildCommandSection(
              context,
              icon: Icons.edit,
              title: 'Harcama Düzenleme',
              description: 'Son harcamanızın tutarını değiştirin.',
              examples: [
                'Son harcamayı 100 lira yap',
                'Sonuncuyu 50 TL yap',
                'Son harcamayı 200 lira güncelle',
                'Son kaydı 75 lira değiştir',
              ],
            ),

            const SizedBox(height: 16),

            // Toplam Sorgulama
            _buildCommandSection(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Toplam Harcama Sorgulama',
              description:
                  'Aylık, haftalık veya günlük toplam harcamanızı öğrenin.',
              examples: [
                'Bu ay ne kadar harcadım?',
                'Bu hafta ne kadar harcadım?',
                'Bugün ne kadar harcadım?',
                'Toplam harcamam ne kadar?',
                'Haftalık harcamam',
                'Bugünkü harcamam',
              ],
            ),

            const SizedBox(height: 16),

            // Kategori Analizi
            _buildCommandSection(
              context,
              icon: Icons.pie_chart,
              title: 'Kategori Analizi',
              description: 'En çok harcama yaptığınız kategoriyi öğrenin.',
              examples: [
                'En çok hangi kategoride harcamışım?',
                'En çok nereye harcadım?',
                'En fazla harcama nerede?',
              ],
            ),

            const SizedBox(height: 16),

            // Kategori Bazlı Sorgulama
            _buildCommandSection(
              context,
              icon: Icons.category,
              title: 'Kategoriye Göre Harcama',
              description:
                  'Belirli bir kategorideki toplam harcamanızı öğrenin.',
              examples: [
                'Markete ne kadar harcadım?',
                'Yemek kategorisinde ne kadar?',
                'Ulaşıma ne kadar harcamışım?',
                'Spor kategorisinde kaç lira?',
              ],
            ),

            const SizedBox(height: 16),

            // Son Harcamalar
            _buildCommandSection(
              context,
              icon: Icons.list_alt,
              title: 'Son Harcamaları Listeleme',
              description: 'Son yaptığınız harcamaları listeleyin.',
              examples: [
                'Son harcamalarım neler?',
                'Son harcamalarımı söyle',
                'Son 5 harcamam',
                'Son harcamalarımı listele',
              ],
            ),

            const SizedBox(height: 16),

            // Bütçe Durumu
            _buildCommandSection(
              context,
              icon: Icons.warning_amber,
              title: 'Bütçe Durumu',
              description: 'Bütçenizin durumunu kontrol edin.',
              examples: [
                'Bütçemi aştım mı?',
                'Limit durumum ne?',
                'Limiti geçtim mi?',
                'Bütçe durumu',
              ],
            ),

            const SizedBox(height: 16),

            // Sabit Giderleri Ekle
            _buildCommandSection(
              context,
              icon: Icons.repeat,
              title: 'Sabit Giderleri Ekle',
              description:
                  'Ayarlardan tanımladığınız sabit giderleri bu aya ekleyin.',
              examples: [
                'Sabit giderleri ekle',
                'Sabit giderleri bu aya ekle',
                'Faturaları ekle',
                'Düzenli giderleri ekle',
              ],
            ),

            const SizedBox(height: 32),

            // İpucu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'İpucu: Komutları doğal bir şekilde söyleyin. Sesli asistan farklı söyleyişleri de anlayabilir.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> examples,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Açıklama
          Text(
            description,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Örnekler
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples
                .map(
                  (example) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '"$example"',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
