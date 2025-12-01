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

  // Kullanılabilir ikonlar (100+ adet)
  final Map<String, IconData> ikonlar = {
    // Yemek & İçecek
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'local_bar': Icons.local_bar,
    'local_pizza': Icons.local_pizza,
    'lunch_dining': Icons.lunch_dining,
    'dinner_dining': Icons.dinner_dining,
    'breakfast_dining': Icons.breakfast_dining,
    'fastfood': Icons.fastfood,
    'bakery_dining': Icons.bakery_dining,
    'icecream': Icons.icecream,
    'coffee': Icons.coffee,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'cake': Icons.cake,
    'restaurant_menu': Icons.restaurant_menu,
    'ramen_dining': Icons.ramen_dining,
    'wine_bar': Icons.wine_bar,
    'liquor': Icons.liquor,
    'local_drink': Icons.local_drink,

    // Alışveriş
    'shopping_basket': Icons.shopping_basket,
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'local_mall': Icons.local_mall,
    'storefront': Icons.storefront,
    'store': Icons.store,
    'local_grocery_store': Icons.local_grocery_store,
    'local_convenience_store': Icons.local_convenience_store,
    'local_offer': Icons.local_offer,
    'loyalty': Icons.loyalty,
    'redeem': Icons.redeem,
    'card_giftcard': Icons.card_giftcard,

    // Ulaşım
    'two_wheeler': Icons.two_wheeler,
    'directions_car': Icons.directions_car,
    'directions_bus': Icons.directions_bus,
    'directions_subway': Icons.directions_subway,
    'train': Icons.train,
    'tram': Icons.tram,
    'local_taxi': Icons.local_taxi,
    'airport_shuttle': Icons.airport_shuttle,
    'flight': Icons.flight,
    'flight_takeoff': Icons.flight_takeoff,
    'flight_land': Icons.flight_land,
    'directions_bike': Icons.directions_bike,
    'electric_scooter': Icons.electric_scooter,
    'electric_bike': Icons.electric_bike,
    'electric_car': Icons.electric_car,
    'local_gas_station': Icons.local_gas_station,
    'local_parking': Icons.local_parking,
    'ev_station': Icons.ev_station,
    'car_rental': Icons.car_rental,
    'commute': Icons.commute,
    'directions_walk': Icons.directions_walk,
    'directions_run': Icons.directions_run,

    // Ev & Yaşam
    'home': Icons.home,
    'house': Icons.house,
    'apartment': Icons.apartment,
    'cottage': Icons.cottage,
    'hotel': Icons.hotel,
    'bed': Icons.bed,
    'living': Icons.living,
    'kitchen': Icons.kitchen,
    'bathroom': Icons.bathroom,
    'garage': Icons.garage,
    'chair': Icons.chair,
    'table_bar': Icons.table_bar,
    'light': Icons.light,
    'lightbulb': Icons.lightbulb,

    // Finans & Ödeme
    'credit_card': Icons.credit_card,
    'payment': Icons.payment,
    'account_balance': Icons.account_balance,
    'account_balance_wallet': Icons.account_balance_wallet,
    'attach_money': Icons.attach_money,
    'money': Icons.money,
    'paid': Icons.paid,
    'savings': Icons.savings,
    'currency_exchange': Icons.currency_exchange,
    'price_change': Icons.price_change,
    'receipt': Icons.receipt,
    'receipt_long': Icons.receipt_long,

    // Eğitim & Okul
    'school': Icons.school,
    'menu_book': Icons.menu_book,
    'book': Icons.book,
    'library_books': Icons.library_books,
    'auto_stories': Icons.auto_stories,
    'backpack': Icons.backpack,
    'calculate': Icons.calculate,
    'edit': Icons.edit,
    'draw': Icons.draw,
    'science': Icons.science,

    // Sağlık & Fitness
    'medical_services': Icons.medical_services,
    'local_hospital': Icons.local_hospital,
    'local_pharmacy': Icons.local_pharmacy,
    'healing': Icons.healing,
    'medication': Icons.medication,
    'vaccines': Icons.vaccines,
    'fitness_center': Icons.fitness_center,
    'sports_gymnastics': Icons.sports_gymnastics,
    'sports_martial_arts': Icons.sports_martial_arts,
    'self_improvement': Icons.self_improvement,
    'spa': Icons.spa,
    'hot_tub': Icons.hot_tub,
    'pool': Icons.pool,
    'sports': Icons.sports,
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'sports_tennis': Icons.sports_tennis,
    'sports_football': Icons.sports_football,
    'sports_baseball': Icons.sports_baseball,
    'sports_volleyball': Icons.sports_volleyball,
    'sports_golf': Icons.sports_golf,
    'sports_hockey': Icons.sports_hockey,
    'sports_cricket': Icons.sports_cricket,

    // Eğlence & Hobi
    'sports_esports': Icons.sports_esports,
    'videogame_asset': Icons.videogame_asset,
    'casino': Icons.casino,
    'movie': Icons.movie,
    'theaters': Icons.theaters,
    'local_movies': Icons.local_movies,
    'music_note': Icons.music_note,
    'headphones': Icons.headphones,
    'album': Icons.album,
    'library_music': Icons.library_music,
    'piano': Icons.piano,
    'mic': Icons.mic,
    'palette': Icons.palette,
    'brush': Icons.brush,
    'color_lens': Icons.color_lens,
    'photo_camera': Icons.photo_camera,
    'camera_alt': Icons.camera_alt,
    'videocam': Icons.videocam,
    'celebration': Icons.celebration,
    'party_mode': Icons.party_mode,

    // Teknoloji & Elektronik
    'phone_android': Icons.phone_android,
    'phone_iphone': Icons.phone_iphone,
    'smartphone': Icons.smartphone,
    'tablet': Icons.tablet,
    'computer': Icons.computer,
    'laptop': Icons.laptop,
    'desktop_windows': Icons.desktop_windows,
    'keyboard': Icons.keyboard,
    'mouse': Icons.mouse,
    'headset': Icons.headset,
    'watch': Icons.watch,
    'devices': Icons.devices,
    'router': Icons.router,
    'wifi': Icons.wifi,
    'bluetooth': Icons.bluetooth,
    'battery_charging_full': Icons.battery_charging_full,

    // Kişisel Bakım
    'face': Icons.face,
    'face_retouching_natural': Icons.face_retouching_natural,
    'checkroom': Icons.checkroom,
    'dry_cleaning': Icons.dry_cleaning,
    'iron': Icons.iron,
    'wash': Icons.wash,
    'content_cut': Icons.content_cut,

    // Hayvanlar
    'pets': Icons.pets,
    'cruelty_free': Icons.cruelty_free,

    // Doğa & Bahçe
    'local_florist': Icons.local_florist,
    'eco': Icons.eco,
    'park': Icons.park,
    'forest': Icons.forest,
    'grass': Icons.grass,
    'yard': Icons.yard,

    // Genel & Diğer
    'category': Icons.category,
    'label': Icons.label,
    'bookmark': Icons.bookmark,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'workspace_premium': Icons.workspace_premium,
    'diamond': Icons.diamond,
    'build': Icons.build,
    'handyman': Icons.handyman,
    'construction': Icons.construction,
    'plumbing': Icons.plumbing,
    'electrical_services': Icons.electrical_services,
    'cleaning_services': Icons.cleaning_services,
    'business': Icons.business,
    'work': Icons.work,
    'card_travel': Icons.card_travel,
    'luggage': Icons.luggage,
    'beach_access': Icons.beach_access,
    'child_care': Icons.child_care,
    'toys': Icons.toys,
    'notifications': Icons.notifications,
    'campaign': Icons.campaign,
    'mail': Icons.mail,
    'send': Icons.send,
  };

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
        content: Text('Kategori eklendi ✅'),
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
                  content: Text('Varsayılan kategoriler yüklendi'),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
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
                Text(
                  'İkon Seç:',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: ikonlar.length,
                    itemBuilder: (context, index) {
                      final ikonAdi = ikonlar.keys.elementAt(index);
                      final ikon = ikonlar[ikonAdi]!;
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
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                              width: seciliMi ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            ikon,
                            color: seciliMi
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.54),
                            size: 28,
                          ),
                        ),
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
              child: ListView.builder(
                itemCount: kategoriler.length,
                itemBuilder: (context, index) {
                  final kategori = kategoriler[index];
                  final ikon = ikonlar[kategori['ikon']] ?? Icons.category;

                  return Card(
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
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: ColorConstants.kirmiziVurgu,
                        ),
                        onPressed: () => kategoriSil(index),
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
