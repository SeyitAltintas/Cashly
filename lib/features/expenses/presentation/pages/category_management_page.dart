import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import '../../../../services/database_helper.dart';

class KategoriYonetimiSayfasi extends StatefulWidget {
  final String userId;

  const KategoriYonetimiSayfasi({super.key, required this.userId});

  @override
  State<KategoriYonetimiSayfasi> createState() =>
      _KategoriYonetimiSayfasiState();
}

class _KategoriYonetimiSayfasiState extends State<KategoriYonetimiSayfasi> {
  List<Map<String, dynamic>> kategoriler = [];
  final TextEditingController tKategoriIsmi = TextEditingController();
  String secilenIkon = 'category';

  // Kategorilere göre gruplandırılmış ikonlar
  final Map<String, List<Map<String, dynamic>>> ikonKategorileri = {
    'Yemek & İçecek': [
      {'key': 'restaurant', 'icon': Icons.restaurant},
      {'key': 'local_cafe', 'icon': Icons.local_cafe},
      {'key': 'local_pizza', 'icon': Icons.local_pizza},
      {'key': 'fastfood', 'icon': Icons.fastfood},
      {'key': 'lunch_dining', 'icon': Icons.lunch_dining},
      {'key': 'dinner_dining', 'icon': Icons.dinner_dining},
      {'key': 'breakfast_dining', 'icon': Icons.breakfast_dining},
      {'key': 'ramen_dining', 'icon': Icons.ramen_dining},
      {'key': 'bakery_dining', 'icon': Icons.bakery_dining},
      {'key': 'icecream', 'icon': Icons.icecream},
      {'key': 'cake', 'icon': Icons.cake},
      {'key': 'coffee', 'icon': Icons.coffee},
      {'key': 'local_bar', 'icon': Icons.local_bar},
      {'key': 'wine_bar', 'icon': Icons.wine_bar},
    ],
    'Alışveriş': [
      {'key': 'shopping_cart', 'icon': Icons.shopping_cart},
      {'key': 'shopping_bag', 'icon': Icons.shopping_bag},
      {'key': 'shopping_basket', 'icon': Icons.shopping_basket},
      {'key': 'local_mall', 'icon': Icons.local_mall},
      {'key': 'storefront', 'icon': Icons.storefront},
      {'key': 'local_grocery_store', 'icon': Icons.local_grocery_store},
      {'key': 'card_giftcard', 'icon': Icons.card_giftcard},
      {'key': 'redeem', 'icon': Icons.redeem},
    ],
    'Ulaşım': [
      {'key': 'directions_car', 'icon': Icons.directions_car},
      {'key': 'two_wheeler', 'icon': Icons.two_wheeler},
      {'key': 'directions_bike', 'icon': Icons.directions_bike},
      {'key': 'directions_bus', 'icon': Icons.directions_bus},
      {'key': 'train', 'icon': Icons.train},
      {'key': 'local_taxi', 'icon': Icons.local_taxi},
      {'key': 'flight', 'icon': Icons.flight},
      {'key': 'local_gas_station', 'icon': Icons.local_gas_station},
      {'key': 'local_parking', 'icon': Icons.local_parking},
      {'key': 'electric_car', 'icon': Icons.electric_car},
    ],
    'Ev & Yaşam': [
      {'key': 'home', 'icon': Icons.home},
      {'key': 'apartment', 'icon': Icons.apartment},
      {'key': 'bed', 'icon': Icons.bed},
      {'key': 'kitchen', 'icon': Icons.kitchen},
      {'key': 'chair', 'icon': Icons.chair},
      {'key': 'lightbulb', 'icon': Icons.lightbulb},
      {'key': 'cleaning_services', 'icon': Icons.cleaning_services},
      {'key': 'plumbing', 'icon': Icons.plumbing},
      {'key': 'electrical_services', 'icon': Icons.electrical_services},
    ],
    'Finans & Ödeme': [
      {'key': 'credit_card', 'icon': Icons.credit_card},
      {'key': 'payment', 'icon': Icons.payment},
      {'key': 'account_balance', 'icon': Icons.account_balance},
      {'key': 'account_balance_wallet', 'icon': Icons.account_balance_wallet},
      {'key': 'savings', 'icon': Icons.savings},
      {'key': 'currency_exchange', 'icon': Icons.currency_exchange},
      {'key': 'receipt', 'icon': Icons.receipt},
      {'key': 'paid', 'icon': Icons.paid},
    ],
    'Eğitim': [
      {'key': 'school', 'icon': Icons.school},
      {'key': 'menu_book', 'icon': Icons.menu_book},
      {'key': 'library_books', 'icon': Icons.library_books},
      {'key': 'backpack', 'icon': Icons.backpack},
      {'key': 'calculate', 'icon': Icons.calculate},
      {'key': 'science', 'icon': Icons.science},
      {'key': 'draw', 'icon': Icons.draw},
    ],
    'Sağlık & Spor': [
      {'key': 'medical_services', 'icon': Icons.medical_services},
      {'key': 'local_hospital', 'icon': Icons.local_hospital},
      {'key': 'local_pharmacy', 'icon': Icons.local_pharmacy},
      {'key': 'fitness_center', 'icon': Icons.fitness_center},
      {'key': 'pool', 'icon': Icons.pool},
      {'key': 'spa', 'icon': Icons.spa},
      {'key': 'sports_soccer', 'icon': Icons.sports_soccer},
      {'key': 'sports_basketball', 'icon': Icons.sports_basketball},
      {'key': 'sports_tennis', 'icon': Icons.sports_tennis},
    ],
    'Eğlence & Hobi': [
      {'key': 'sports_esports', 'icon': Icons.sports_esports},
      {'key': 'videogame_asset', 'icon': Icons.videogame_asset},
      {'key': 'movie', 'icon': Icons.movie},
      {'key': 'music_note', 'icon': Icons.music_note},
      {'key': 'headphones', 'icon': Icons.headphones},
      {'key': 'mic', 'icon': Icons.mic},
      {'key': 'photo_camera', 'icon': Icons.photo_camera},
      {'key': 'palette', 'icon': Icons.palette},
      {'key': 'celebration', 'icon': Icons.celebration},
    ],
    'Teknoloji': [
      {'key': 'smartphone', 'icon': Icons.smartphone},
      {'key': 'laptop', 'icon': Icons.laptop},
      {'key': 'computer', 'icon': Icons.computer},
      {'key': 'tablet', 'icon': Icons.tablet},
      {'key': 'watch', 'icon': Icons.watch},
      {'key': 'headset', 'icon': Icons.headset},
      {'key': 'wifi', 'icon': Icons.wifi},
      {'key': 'router', 'icon': Icons.router},
    ],
    'Kişisel Bakım': [
      {'key': 'face', 'icon': Icons.face},
      {'key': 'content_cut', 'icon': Icons.content_cut},
      {'key': 'checkroom', 'icon': Icons.checkroom},
      {'key': 'dry_cleaning', 'icon': Icons.dry_cleaning},
    ],
    'Diğer': [
      {'key': 'category', 'icon': Icons.category},
      {'key': 'star', 'icon': Icons.star},
      {'key': 'favorite', 'icon': Icons.favorite},
      {'key': 'pets', 'icon': Icons.pets},
      {'key': 'local_florist', 'icon': Icons.local_florist},
      {'key': 'business', 'icon': Icons.business},
      {'key': 'work', 'icon': Icons.work},
      {'key': 'build', 'icon': Icons.build},
      {'key': 'child_care', 'icon': Icons.child_care},
      {'key': 'toys', 'icon': Icons.toys},
    ],
  };

  // Tüm ikonları tek bir map'te tut (uyumluluk için)
  Map<String, IconData> get ikonlar {
    final Map<String, IconData> tumIkonlar = {};
    ikonKategorileri.forEach((kategori, ikonListesi) {
      for (var ikon in ikonListesi) {
        tumIkonlar[ikon['key']] = ikon['icon'];
      }
    });
    return tumIkonlar;
  }

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    setState(() {
      kategoriler = DatabaseHelper.kategorileriGetir(widget.userId);
    });
  }

  void kategoriEkle() {
    if (tKategoriIsmi.text.isEmpty) return;

    setState(() {
      kategoriler.add({'isim': tKategoriIsmi.text, 'ikon': secilenIkon});
    });

    DatabaseHelper.kategorileriKaydet(widget.userId, kategoriler);
    tKategoriIsmi.clear();
    secilenIkon = 'category';
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kategori eklendi ✅'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void kategoriSil(int index) {
    final kategoriIsmi = kategoriler[index]['isim'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Kategoriyi Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '"$kategoriIsmi" kategorisini silmek istediğinizden emin misiniz?',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                kategoriler.removeAt(index);
              });
              DatabaseHelper.kategorileriKaydet(widget.userId, kategoriler);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kategori silindi'),
                  backgroundColor: ColorConstants.kirmiziVurgu,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.kirmiziVurgu,
            ),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void defaultKategorilereGeriDon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Varsayılana Dön',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tüm özel kategorileriniz silinecek ve varsayılan kategoriler yüklenecek. Emin misiniz?',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                kategoriler = List.from(DatabaseHelper.defaultKategoriler);
              });
              DatabaseHelper.kategorileriKaydet(widget.userId, kategoriler);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Varsayılan kategoriler yüklendi'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Evet, Sıfırla',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void kategoriEkleDialogAc() {
    secilenIkon = 'category';
    tKategoriIsmi.clear();

    // Arama controller
    final TextEditingController aramaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final aramaMetni = aramaController.text.toLowerCase().trim();

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text(
              'Yeni Kategori Ekle',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tKategoriIsmi,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Kategori Adı',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    prefixIcon: Icon(
                      Icons.label,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'İkon Seç:',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: aramaController,
                          onChanged: (value) {
                            setStateDialog(() {}); // Rebuild dialog
                          },
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ara...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.38),
                              fontSize: 11,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: ikonKategorileri.length,
                    itemBuilder: (context, katIndex) {
                      final kategoriAdi = ikonKategorileri.keys.elementAt(
                        katIndex,
                      );
                      final tumIkonlar = ikonKategorileri[kategoriAdi]!;

                      // Arama metnine göre filtrele
                      final ikonListesi = aramaMetni.isEmpty
                          ? tumIkonlar
                          : tumIkonlar.where((ikon) {
                              final ikonAdi = ikon['key'] as String;
                              return kategoriAdi.toLowerCase().contains(
                                    aramaMetni,
                                  ) ||
                                  ikonAdi.toLowerCase().contains(aramaMetni);
                            }).toList();

                      // Eğer filtreleme sonrası liste boşsa bu kategoriyi gösterme
                      if (ikonListesi.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (katIndex > 0 && aramaMetni.isEmpty)
                            Divider(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.12),
                              thickness: 1,
                              height: 20,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              kategoriAdi,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                            itemCount: ikonListesi.length,
                            itemBuilder: (context, index) {
                              final ikonData = ikonListesi[index];
                              final ikonAdi = ikonData['key'];
                              final ikon = ikonData['icon'];
                              final seciliMi = secilenIkon == ikonAdi;

                              return GestureDetector(
                                onTap: () {
                                  setStateDialog(() {
                                    secilenIkon = ikonAdi;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: seciliMi
                                        ? Theme.of(context).colorScheme.primary
                                        : const Color(0xFF2E2E2E),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: seciliMi
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.1),
                                      width: seciliMi ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    ikon,
                                    color: seciliMi
                                        ? Colors.white
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.54),
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'İptal',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: kategoriEkle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Ekle',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Yönetimi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Varsayılana Dön',
            onPressed: defaultKategorilereGeriDon,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KATEGORİLERİM',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: kategoriEkleDialogAc,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  label: Text(
                    'Yeni Ekle',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: kategoriler.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final kategori = kategoriler.removeAt(oldIndex);
                    kategoriler.insert(newIndex, kategori);
                  });
                  DatabaseHelper.kategorileriKaydet(widget.userId, kategoriler);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Kategori sırası güncellendi'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final kategori = kategoriler[index];
                  final ikon = ikonlar[kategori['ikon']] ?? Icons.category;

                  return Card(
                    key: Key('kategori_${kategori['isim']}_$index'),
                    color: Theme.of(context).colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        ikon,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(
                        kategori['isim'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: ColorConstants.kirmiziVurgu,
                            ),
                            onPressed: () => kategoriSil(index),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
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
