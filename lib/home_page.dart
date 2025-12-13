import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/widgets/money_animation.dart';

import 'services/database_helper.dart';
import 'recycle_bin_page.dart';
import 'profile_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/assets/presentation/pages/assets_page.dart';
import 'features/assets/data/models/asset_model.dart';
import 'features/analysis/presentation/pages/analysis_page.dart';
import 'features/tools/presentation/pages/tools_page.dart';
import 'features/income/presentation/pages/income_page.dart';
import 'features/income/presentation/widgets/add_income_sheet.dart';
import 'features/income/data/models/income_model.dart';
import 'features/income/presentation/pages/income_recycle_bin_page.dart';
import 'features/expenses/presentation/widgets/add_expense_sheet.dart';
import 'features/expenses/presentation/widgets/voice_input_sheet.dart';

class AnaSayfa extends StatefulWidget {
  final AuthController authController;

  const AnaSayfa({super.key, required this.authController});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _selectedIndex = 0;
  late PageController _pageController;
  List<Map<String, dynamic>> tumHarcamalar = [];
  List<Map<String, dynamic>> gosterilenHarcamalar = [];
  List<Asset> varliklar = [];

  final TextEditingController tArama = TextEditingController();

  bool aramaModu = false;

  DateTime secilenAy = DateTime.now();

  double butceLimiti = 8000.0;

  Map<String, IconData> kategoriIkonlari = {};
  Map<String, IconData> gelirKategoriIkonlari = {};
  List<Income> tumGelirler = [];

  // Gelir araması için
  final TextEditingController tGelirArama = TextEditingController();
  bool gelirAramaModu = false;

  final List<String> aylarListesi = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    kategorileriYukle();
    gelirKategorileriYukle();
    verileriOku();
    filtreleVeGoster();
  }

  @override
  void dispose() {
    _pageController.dispose();
    tArama.dispose();
    tGelirArama.dispose();
    super.dispose();
  }

  void kategorileriYukle() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> dbKategoriler = DatabaseHelper.kategorileriGetir(
      userId,
    );

    // İkon string'i IconData'ya dönüştür (200+ ikon)
    final Map<String, IconData> ikonMap = {
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

    setState(() {
      kategoriIkonlari = {};
      for (var kategori in dbKategoriler) {
        String isim = kategori['isim'];
        String ikonAdi = kategori['ikon'];
        kategoriIkonlari[isim] = ikonMap[ikonAdi] ?? Icons.category;
      }
    });
  }

  void gelirKategorileriYukle() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> dbKategoriler =
        DatabaseHelper.gelirKategorileriGetir(userId);

    final Map<String, IconData> ikonMap = {
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'home': Icons.home,
      'card_giftcard': Icons.card_giftcard,
      'category': Icons.category,
      'account_balance': Icons.account_balance,
      'attach_money': Icons.attach_money,
      'savings': Icons.savings,
      'business': Icons.business,
    };

    setState(() {
      gelirKategoriIkonlari = {};
      for (var kategori in dbKategoriler) {
        String isim = kategori['isim'];
        String ikonAdi = kategori['ikon'];
        gelirKategoriIkonlari[isim] = ikonMap[ikonAdi] ?? Icons.category;
      }
    });
  }

  void verileriOku() {
    String userId = widget.authController.currentUser!.id;

    // Harcamaları oku
    List<Map<String, dynamic>> gelen = DatabaseHelper.harcamalariGetir(userId);
    double kayitliButce = DatabaseHelper.butceGetir(userId);

    gelen.sort((a, b) {
      DateTime tarihA =
          DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
      DateTime tarihB =
          DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
      return tarihB.compareTo(tarihA);
    });

    // Varlıkları oku
    List<Map<String, dynamic>> varlikVerileri = DatabaseHelper.varliklariGetir(
      userId,
    );
    List<Asset> okunanVarliklar = varlikVerileri
        .map((map) => Asset.fromMap(map))
        .toList();

    // Gelirleri oku
    List<Map<String, dynamic>> gelirVerileri = DatabaseHelper.gelirleriGetir(
      userId,
    );
    List<Income> okunanGelirler = gelirVerileri
        .map((map) => Income.fromMap(map))
        .toList();

    setState(() {
      tumHarcamalar = gelen;
      butceLimiti = kayitliButce;
      varliklar = okunanVarliklar;
      tumGelirler = okunanGelirler;
      filtreleVeGoster();
    });
  }

  /// Gelirleri veritabanına kaydeder
  void gelirleriKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> gelirMapleri = tumGelirler
        .map((income) => income.toMap())
        .toList();
    DatabaseHelper.gelirleriKaydet(userId, gelirMapleri);
  }

  void filtreleVeGoster() {
    setState(() {
      List<Map<String, dynamic>> aktifHarcamalar = tumHarcamalar
          .where((h) => h['silindi'] != true)
          .toList();

      if (aramaModu) {
        String aranan = tArama.text.toLowerCase();
        gosterilenHarcamalar = aktifHarcamalar.where((h) {
          return h['isim'].toString().toLowerCase().contains(aranan);
        }).toList();
      } else {
        gosterilenHarcamalar = aktifHarcamalar.where((h) {
          DateTime hTarih =
              DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
          return hTarih.year == secilenAy.year &&
              hTarih.month == secilenAy.month;
        }).toList();
      }
    });
  }

  void verileriKaydet() {
    String userId = widget.authController.currentUser!.id;
    DatabaseHelper.harcamalariKaydet(userId, tumHarcamalar);
  }

  /// Varlıkları veritabanına kaydeder
  void varliklariKaydet() {
    String userId = widget.authController.currentUser!.id;
    List<Map<String, dynamic>> varlikMapleri = varliklar
        .map((asset) => asset.toMap())
        .toList();
    DatabaseHelper.varliklariKaydet(userId, varlikMapleri);
  }

  void oncekiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month - 1);
      filtreleVeGoster();
    });
  }

  void sonrakiAy() {
    setState(() {
      secilenAy = DateTime(secilenAy.year, secilenAy.month + 1);
      filtreleVeGoster();
    });
  }

  void ayYilSeciciAc() {
    int geciciYil = secilenAy.year;
    int geciciAyIndex = secilenAy.month;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
              title: const Center(
                child: Text(
                  "Dönem Seç",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SizedBox(
                height: 300,
                width: double.maxFinite,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Yıl",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              fontSize: 12,
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 11,
                              itemBuilder: (context, index) {
                                int yil = 2020 + index;
                                bool seciliMi = (yil == geciciYil);
                                return ListTile(
                                  title: Center(
                                    child: Text(
                                      "$yil",
                                      style: TextStyle(
                                        color: seciliMi
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                        fontWeight: seciliMi
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: seciliMi ? 18 : 16,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setStateDialog(() => geciciYil = yil);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(color: Colors.white24),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Ay",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              fontSize: 12,
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 12,
                              itemBuilder: (context, index) {
                                int ayNo = index + 1;
                                bool seciliMi = (ayNo == geciciAyIndex);
                                return ListTile(
                                  title: Center(
                                    child: Text(
                                      aylarListesi[index],
                                      style: TextStyle(
                                        color: seciliMi
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondary
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                        fontWeight: seciliMi
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: seciliMi ? 18 : 16,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setStateDialog(() => geciciAyIndex = ayNo);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "İptal",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      secilenAy = DateTime(geciciYil, geciciAyIndex);
                      filtreleVeGoster();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Tamam"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double get toplamTutar {
    double toplam = 0;
    for (var h in gosterilenHarcamalar) {
      toplam += double.tryParse(h['tutar'].toString()) ?? 0;
    }
    return toplam;
  }

  Map<String, double> get kategoriToplamlari {
    Map<String, double> toplamlar = {};
    for (var kat in kategoriIkonlari.keys) {
      toplamlar[kat] = 0;
    }
    for (var h in gosterilenHarcamalar) {
      String kat = h['kategori'] ?? "Diğer";
      double tutar = double.tryParse(h['tutar'].toString()) ?? 0;
      if (toplamlar.containsKey(kat)) {
        toplamlar[kat] = (toplamlar[kat] ?? 0) + tutar;
      } else {
        toplamlar[kat] = tutar;
      }
    }
    return toplamlar;
  }

  Map<String, List<Map<String, dynamic>>> get gunlukGruplanmisHarcamalar {
    Map<String, List<Map<String, dynamic>>> gruplar = {};

    for (var h in gosterilenHarcamalar) {
      DateTime tarih =
          DateTime.tryParse(h['tarih'].toString()) ?? DateTime.now();
      String tarihBasligi = tarihFormatla(tarih);

      if (!gruplar.containsKey(tarihBasligi)) {
        gruplar[tarihBasligi] = [];
      }
      gruplar[tarihBasligi]!.add(h);
    }
    return gruplar;
  }

  String tarihFormatla(DateTime tarih) {
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final oTarih = DateTime(tarih.year, tarih.month, tarih.day);
    final fark = bugun.difference(oTarih).inDays;

    if (fark == 0) return "Bugün";
    if (fark == 1) return "Dün";

    return "${oTarih.day} ${aylarListesi[oTarih.month - 1]}";
  }

  void harcamaSil(Map<String, dynamic> harcama) {
    setState(() {
      harcama['silindi'] = true;
      filtreleVeGoster();
    });
    verileriKaydet();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Harcama çöp kutusuna taşındı 🗑️",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorConstants.koyuKirmizi,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void pencereAc({Map<String, dynamic>? duzenlenecekHarcama}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        expenseToEdit: duzenlenecekHarcama,
        categories: kategoriIkonlari,
        onSave: (name, amount, category, date) {
          setState(() {
            if (duzenlenecekHarcama != null) {
              int index = tumHarcamalar.indexOf(duzenlenecekHarcama);
              if (index != -1) {
                tumHarcamalar[index] = {
                  "isim": name,
                  "tutar": amount,
                  "kategori": category,
                  "tarih": date.toString(),
                  "silindi": false,
                };
              }
            } else {
              tumHarcamalar.add({
                "isim": name,
                "tutar": amount,
                "kategori": category,
                "tarih": date.toString(),
                "silindi": false,
              });
            }

            tumHarcamalar.sort((a, b) {
              DateTime tarihA =
                  DateTime.tryParse(a['tarih'].toString()) ?? DateTime.now();
              DateTime tarihB =
                  DateTime.tryParse(b['tarih'].toString()) ?? DateTime.now();
              return tarihB.compareTo(tarihA);
            });

            filtreleVeGoster();
          });
          verileriKaydet();

          // Yeni harcama eklendiyse para animasyonu göster
          if (duzenlenecekHarcama == null) {
            if (context.read<ThemeManager>().isMoneyAnimationEnabled) {
              MoneyAnimationOverlay.show(context);
            }
          }
        },
      ),
    );
  }

  String get ayIsmi {
    return "${aylarListesi[secilenAy.month - 1]} ${secilenAy.year}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime simdi = DateTime.now();
    bool buAyMi =
        (secilenAy.year == simdi.year && secilenAy.month == simdi.month);

    Map<String, double> katToplamlar = kategoriToplamlari;
    List<MapEntry<String, double>> aktifKategoriler = katToplamlar.entries
        .where((e) => e.value > 0)
        .toList();
    aktifKategoriler.sort((a, b) => b.value.compareTo(a.value));

    double harcanan = toplamTutar;
    double dolulukOrani = (harcanan / butceLimiti).clamp(0.0, 1.0);
    double kalanLimit = butceLimiti - harcanan;
    double asilanMiktar = harcanan - butceLimiti;

    Color barRengi = Theme.of(context).colorScheme.secondary;
    if (dolulukOrani > 0.5) barRengi = Colors.orangeAccent;
    if (dolulukOrani > 0.8) barRengi = ColorConstants.kirmiziVurgu;

    Map<String, List<Map<String, dynamic>>> gruplar =
        gunlukGruplanmisHarcamalar;

    // Harcamalar Sayfası İçeriği (Body)
    Widget harcamalarBody = Column(
      children: [
        if (!aramaModu) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      onPressed: oncekiAy,
                    ),
                    TextButton(
                      onPressed: ayYilSeciciAc,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(
                            ayIsmi.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      onPressed: sonrakiAy,
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Toplam Harcama",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${toplamTutar.toStringAsFixed(2)} ₺",
                          style: TextStyle(
                            color: ColorConstants.kirmiziVurgu,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorConstants.kirmiziVurgu.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.trending_down,
                        color: ColorConstants.kirmiziVurgu,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Bütçe Durumu Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Bütçe Durumu",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "%${(dolulukOrani * 100).toStringAsFixed(0)}",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: dolulukOrani,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(barRengi),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: kalanLimit < 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConstants.kirmiziVurgu,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Limit aşıldı: ${asilanMiktar.toStringAsFixed(2)} ₺",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                "Kalan: ${kalanLimit.toStringAsFixed(2)} ₺",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],

        Expanded(
          child: gosterilenHarcamalar.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        aramaModu
                            ? Icons.search_off
                            : Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.white12,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        aramaModu
                            ? "Sonuç bulunamadı."
                            : "$ayIsmi için harcama yok.",
                        style: const TextStyle(color: Colors.white24),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  itemCount: gruplar.keys.length,
                  itemBuilder: (context, index) {
                    String gunBasligi = gruplar.keys.elementAt(index);
                    List<Map<String, dynamic>> harcamalar =
                        gruplar[gunBasligi]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            bottom: 5,
                            top: 10,
                          ),
                          child: Text(
                            gunBasligi.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        ...harcamalar.map((harcama) {
                          return Dismissible(
                            key: ValueKey(harcama),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: ColorConstants.koyuKirmizi,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              harcamaSil(harcama);
                            },
                            child: GestureDetector(
                              onTap: () =>
                                  pencereAc(duzenlenecekHarcama: harcama),
                              child: Card(
                                color: Theme.of(context).colorScheme.surface,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.05),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      kategoriIkonlari[harcama['kategori']] ??
                                          Icons.help,
                                      color:
                                          context
                                              .watch<ThemeManager>()
                                              .isDefaultTheme
                                          ? PageThemeColors.getIconColor(
                                              gosterilenHarcamalar.indexOf(
                                                harcama,
                                              ),
                                            )
                                          : Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                    ),
                                  ),
                                  title: Text(
                                    harcama['isim'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    harcama['kategori'],
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Text(
                                    "-${harcama['tutar']} ₺",
                                    style: TextStyle(
                                      color:
                                          context
                                              .watch<ThemeManager>()
                                              .isDefaultTheme
                                          ? Colors.red
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );

    // AppBar Seçimi
    PreferredSizeWidget? appBar;
    if (_selectedIndex == 0) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: aramaModu
            ? TextField(
                controller: tArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Harcama ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
                onChanged: (val) => filtreleVeGoster(),
              )
            : const Text("Harcamalarım"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!aramaModu && !buAyMi)
            TextButton(
              onPressed: () {
                setState(() {
                  secilenAy = DateTime.now();
                  filtreleVeGoster();
                });
              },
              child: Text(
                "Bugüne git",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          if (!aramaModu) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: "Çöp Kutusu",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CopKutusuSayfasi(
                      userId: widget.authController.currentUser!.id,
                    ),
                  ),
                ).then((_) {
                  verileriOku();
                });
              },
            ),
            // Sesli harcama girişi butonu
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              tooltip: "Sesli Giriş",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => VoiceInputSheet(
                    categoryIcons: kategoriIkonlari,
                    userId: widget.authController.currentUser?.id,
                    onConfirm: (name, amount, category, date) {
                      setState(() {
                        tumHarcamalar.add({
                          "isim": name,
                          "tutar": amount,
                          "kategori": category,
                          "tarih": date.toString(),
                          "silindi": false,
                        });

                        tumHarcamalar.sort((a, b) {
                          DateTime tarihA =
                              DateTime.tryParse(a['tarih'].toString()) ??
                              DateTime.now();
                          DateTime tarihB =
                              DateTime.tryParse(b['tarih'].toString()) ??
                              DateTime.now();
                          return tarihB.compareTo(tarihA);
                        });

                        filtreleVeGoster();
                      });
                      verileriKaydet();

                      // Para animasyonu göster 💰
                      if (context
                          .read<ThemeManager>()
                          .isMoneyAnimationEnabled) {
                        MoneyAnimationOverlay.show(context);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Harcama eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(12),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    // Sesli komut: Son harcamayı sil
                    onDeleteLastExpense: () async {
                      // Bu ayın harcamalarından son eklenen (silindi=false) olanı bul
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      if (buAyHarcamalari.isEmpty) return null;

                      // En son eklenen harcamayı bul (tarihe göre sırala)
                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      final sonHarcama = buAyHarcamalari.first;

                      // Harcamayı sil (soft delete)
                      setState(() {
                        sonHarcama['silindi'] = true;
                        filtreleVeGoster();
                      });
                      verileriKaydet();

                      return sonHarcama;
                    },
                    // Sesli komut: Bu ay ne kadar harcadım?
                    onGetMonthlyTotal: () {
                      return toplamTutar;
                    },
                    // Sesli komut: En çok hangi kategoride harcamışım?
                    onGetTopCategory: () {
                      if (kategoriToplamlari.isEmpty) return null;

                      String? enCokKategori;
                      double enYuksekTutar = 0;

                      kategoriToplamlari.forEach((kategori, tutar) {
                        if (tutar > enYuksekTutar) {
                          enYuksekTutar = tutar;
                          enCokKategori = kategori;
                        }
                      });

                      if (enCokKategori == null || enYuksekTutar == 0) {
                        return null;
                      }

                      return {
                        'kategori': enCokKategori,
                        'tutar': enYuksekTutar,
                      };
                    },
                    // Sesli komut: Bu hafta ne kadar harcadım?
                    onGetWeeklyTotal: () {
                      final now = DateTime.now();
                      final weekStart = now.subtract(
                        Duration(days: now.weekday - 1),
                      );

                      double haftalikToplam = 0;
                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null &&
                            tarih.isAfter(
                              weekStart.subtract(const Duration(days: 1)),
                            ) &&
                            tarih.isBefore(now.add(const Duration(days: 1)))) {
                          haftalikToplam +=
                              (h['tutar'] as num?)?.toDouble() ?? 0;
                        }
                      }
                      return haftalikToplam;
                    },
                    // Sesli komut: Bugün ne kadar harcadım?
                    onGetDailyTotal: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      double gunlukToplam = 0;
                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null) {
                          final harcamaTarihi = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                          );
                          if (harcamaTarihi.isAtSameMomentAs(today)) {
                            gunlukToplam +=
                                (h['tutar'] as num?)?.toDouble() ?? 0;
                          }
                        }
                      }
                      return gunlukToplam;
                    },
                    // Sesli komut: Son harcamalarım neler?
                    onGetLastExpenses: () {
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      return buAyHarcamalari.take(5).toList();
                    },
                    // Sesli komut: Bütçemi aştım mı? / Kalan bütçem ne kadar?
                    onCheckBudget: () {
                      return {
                        'kalanLimit': kalanLimit > 0 ? kalanLimit : 0,
                        'asilanMiktar': asilanMiktar,
                        'butceLimiti': butceLimiti,
                      };
                    },
                    // Sesli komut: Kategoride ne kadar harcadım?
                    onGetCategoryTotal: (String kategori) {
                      return kategoriToplamlari[kategori] ?? 0.0;
                    },
                    // Sesli komut: Sabit giderleri ekle
                    onAddFixedExpenses: () async {
                      final sabitGiderler =
                          DatabaseHelper.sabitGiderSablonlariGetir(
                            widget.authController.currentUser!.id,
                          );

                      if (sabitGiderler.isEmpty) {
                        return {'adet': 0, 'toplam': 0.0};
                      }

                      DateTime simdi = DateTime.now();
                      double toplam = 0;

                      for (var sablon in sabitGiderler) {
                        double tutar =
                            (sablon['tutar'] as num?)?.toDouble() ?? 0;
                        toplam += tutar;
                        tumHarcamalar.add({
                          'isim': sablon['isim'],
                          'tutar': tutar,
                          'kategori': 'Sabit Giderler',
                          'tarih': simdi.toString(),
                          'silindi': false,
                        });
                      }

                      verileriKaydet();
                      setState(() {
                        filtreleVeGoster();
                      });

                      return {'adet': sabitGiderler.length, 'toplam': toplam};
                    },
                    // Sesli komut: Son harcamayı düzenle
                    onEditLastExpense: (double yeniTutar) async {
                      // Bu ayın harcamalarından son eklenen (silindi=false) olanı bul
                      final buAyHarcamalari = tumHarcamalar.where((h) {
                        if (h['silindi'] == true) return false;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih == null) return false;
                        return tarih.year == secilenAy.year &&
                            tarih.month == secilenAy.month;
                      }).toList();

                      if (buAyHarcamalari.isEmpty) return null;

                      // Son harcamayı bul (tarih sıralı)
                      buAyHarcamalari.sort((a, b) {
                        DateTime tarihA =
                            DateTime.tryParse(a['tarih'].toString()) ??
                            DateTime.now();
                        DateTime tarihB =
                            DateTime.tryParse(b['tarih'].toString()) ??
                            DateTime.now();
                        return tarihB.compareTo(tarihA);
                      });

                      final sonHarcama = buAyHarcamalari.first;
                      final eskiTutar =
                          (sonHarcama['tutar'] as num?)?.toDouble() ?? 0;
                      final isim = sonHarcama['isim'] ?? 'Harcama';

                      // 0 TL ise harcamayı sil
                      if (yeniTutar == 0) {
                        sonHarcama['silindi'] = true;
                      } else {
                        // Tutarı güncelle
                        sonHarcama['tutar'] = yeniTutar;
                      }

                      // Veriyi kaydet - setState bottom sheet kapandıktan sonra çağrılacak
                      verileriKaydet();

                      // setState'i erteleyerek çağır (bottom sheet kapandıktan sonra)
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          setState(() {
                            filtreleVeGoster();
                          });
                        }
                      });

                      return {
                        'isim': isim,
                        'eskiTutar': eskiTutar,
                        'yeniTutar': yeniTutar,
                        'silindi': yeniTutar == 0,
                      };
                    },
                    // Sesli komut: Tarihli harcama sorgusu
                    onGetDateRangeTotal: (DateTime baslangic, DateTime bitis) {
                      double toplam = 0;
                      final baslangicGun = DateTime(
                        baslangic.year,
                        baslangic.month,
                        baslangic.day,
                      );
                      final bitisGun = DateTime(
                        bitis.year,
                        bitis.month,
                        bitis.day,
                      );

                      for (var h in tumHarcamalar) {
                        if (h['silindi'] == true) continue;
                        DateTime? tarih = DateTime.tryParse(
                          h['tarih'].toString(),
                        );
                        if (tarih != null) {
                          final harcamaTarihi = DateTime(
                            tarih.year,
                            tarih.month,
                            tarih.day,
                          );
                          if ((harcamaTarihi.isAtSameMomentAs(baslangicGun) ||
                                  harcamaTarihi.isAfter(baslangicGun)) &&
                              (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                                  harcamaTarihi.isBefore(bitisGun))) {
                            toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
                          }
                        }
                      }
                      return toplam;
                    },
                    // Sesli komut: Tarihli kategori sorgusu
                    onGetDateRangeCategoryTotal:
                        (DateTime baslangic, DateTime bitis, String kategori) {
                          double toplam = 0;
                          final baslangicGun = DateTime(
                            baslangic.year,
                            baslangic.month,
                            baslangic.day,
                          );
                          final bitisGun = DateTime(
                            bitis.year,
                            bitis.month,
                            bitis.day,
                          );

                          for (var h in tumHarcamalar) {
                            if (h['silindi'] == true) continue;
                            if (h['kategori'] != kategori) continue;
                            DateTime? tarih = DateTime.tryParse(
                              h['tarih'].toString(),
                            );
                            if (tarih != null) {
                              final harcamaTarihi = DateTime(
                                tarih.year,
                                tarih.month,
                                tarih.day,
                              );
                              if ((harcamaTarihi.isAtSameMomentAs(
                                        baslangicGun,
                                      ) ||
                                      harcamaTarihi.isAfter(baslangicGun)) &&
                                  (harcamaTarihi.isAtSameMomentAs(bitisGun) ||
                                      harcamaTarihi.isBefore(bitisGun))) {
                                toplam += (h['tutar'] as num?)?.toDouble() ?? 0;
                              }
                            }
                          }
                          return toplam;
                        },
                    // Sesli komut: Aylık limitimi X lira yap
                    onSetBudgetLimit: (double yeniLimit) async {
                      await DatabaseHelper.butceKaydet(
                        widget.authController.currentUser!.id,
                        yeniLimit,
                      );
                      setState(() {
                        butceLimiti = yeniLimit;
                        filtreleVeGoster();
                      });
                    },
                    // Sesli komut: Bu ay ne kadar tasarruf ettim?
                    onGetSavings: () {
                      // Tasarruf = Bütçe - Harcama
                      final tasarruf = butceLimiti - toplamTutar;
                      return {'tasarruf': tasarruf, 'butceLimiti': butceLimiti};
                    },
                  ),
                );
              },
            ),
          ],
          IconButton(
            icon: Icon(
              aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                aramaModu = !aramaModu;
                if (!aramaModu) {
                  tArama.clear();
                }
                filtreleVeGoster();
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: gelirAramaModu
            ? TextField(
                controller: tGelirArama,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Gelir ara...",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text("Gelirlerim"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GelirCopKutusuSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              ).then((_) {
                verileriOku();
              });
            },
          ),
          IconButton(
            icon: Icon(
              gelirAramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                gelirAramaModu = !gelirAramaModu;
                if (!gelirAramaModu) {
                  tGelirArama.clear();
                }
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 2) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Araçlar"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    } else if (_selectedIndex == 3) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _pageController.jumpToPage(0);
        }
      },
      child: Scaffold(
        appBar: appBar,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            // Sayfa 0: Harcamalarım
            harcamalarBody,
            // Sayfa 1: Gelirlerim
            IncomePage(
              incomes: tumGelirler,
              selectedDate: secilenAy,
              searchQuery: gelirAramaModu ? tGelirArama.text : '',
              onDelete: (income) {
                setState(() {
                  income.isDeleted = true;
                });
                gelirleriKaydet();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Gelir silindi 🗑️",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onEdit: (income) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddIncomeSheet(
                    incomeToEdit: income.toMap(),
                    categories: gelirKategoriIkonlari,
                    onSave: (name, amount, category, date) {
                      setState(() {
                        int index = tumGelirler.indexOf(income);
                        if (index != -1) {
                          tumGelirler[index] = Income(
                            id: income.id,
                            name: name,
                            amount: amount,
                            category: category,
                            date: date,
                            isDeleted: false,
                          );
                        }
                      });
                      gelirleriKaydet();
                    },
                  ),
                );
              },
              onPreviousMonth: () {
                setState(() {
                  secilenAy = DateTime(secilenAy.year, secilenAy.month - 1);
                });
              },
              onNextMonth: () {
                setState(() {
                  secilenAy = DateTime(secilenAy.year, secilenAy.month + 1);
                });
              },
              onSelectMonth: ayYilSeciciAc,
            ),
            // Sayfa 2: Araçlar
            ToolsPage(
              onAssetsPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetsPage(
                      assets: varliklar.where((a) => !a.isDeleted).toList(),
                      deletedAssets: varliklar
                          .where((a) => a.isDeleted)
                          .toList(),
                      onDelete: (asset) {
                        setState(() {
                          asset.isDeleted = true;
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık çöp kutusuna taşındı 🗑️",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: ColorConstants.koyuKirmizi,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onEdit: (asset) {
                        setState(() {
                          int index = varliklar.indexWhere(
                            (a) => a.id == asset.id,
                          );
                          if (index != -1) {
                            varliklar[index] = asset;
                          }
                        });
                        varliklariKaydet();
                      },
                      onRestore: (asset) {
                        setState(() {
                          asset.isDeleted = false;
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık geri yüklendi ♻️",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                      onPermanentDelete: (asset) {
                        setState(() {
                          varliklar.remove(asset);
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık kalıcı olarak silindi ❌",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: ColorConstants.koyuKirmizi,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                      onEmptyBin: () {
                        setState(() {
                          varliklar.removeWhere((a) => a.isDeleted);
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Çöp kutusu boşaltıldı 🧹",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: ColorConstants.koyuKirmizi,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                      onAdd: (name, amount, quantity, category, type) {
                        setState(() {
                          varliklar.add(
                            Asset(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: name,
                              amount: amount,
                              quantity: quantity,
                              category: category,
                              type: type,
                              lastUpdated: DateTime.now(),
                              isDeleted: false,
                            ),
                          );
                        });
                        varliklariKaydet();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Varlık eklendi ✅",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(12),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              onAnalysisPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnalysisPage(
                      expenses: tumHarcamalar,
                      assets: varliklar,
                      incomes: tumGelirler,
                      selectedDate: secilenAy,
                    ),
                  ),
                );
              },
            ),
            // Sayfa 3: Profil
            ProfilSayfasi(
              authController: widget.authController,
              onRefresh: () {
                kategorileriYukle();
                verileriOku();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_selectedIndex == 0) {
              pencereAc();
            } else if (_selectedIndex == 1) {
              // Gelir ekleme bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddIncomeSheet(
                  categories: gelirKategoriIkonlari,
                  onSave: (name, amount, category, date) {
                    setState(() {
                      tumGelirler.insert(
                        0,
                        Income(
                          id: DateTime.now().toString(),
                          name: name,
                          amount: amount,
                          category: category,
                          date: date,
                        ),
                      );
                    });
                    gelirleriKaydet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gelir eklendi: $name - ${amount.toStringAsFixed(2)} ₺',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  },
                ),
              );
            } else {
              // Diğer sayfalarda harcama ekleme sayfasına git
              setState(() {
                _selectedIndex = 0;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pencereAc();
              });
            }
          },
          backgroundColor: context.watch<ThemeManager>().isDefaultTheme
              ? (_selectedIndex == 0
                    ? PageThemeColors.expensePrimary
                    : _selectedIndex == 1
                    ? PageThemeColors.incomePrimary
                    : PageThemeColors.defaultPrimary)
              : Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            color: context.watch<ThemeManager>().isDefaultTheme
                ? Colors.white
                : Colors.white,
            size: 32,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).colorScheme.surface,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.receipt_long,
                    color: _selectedIndex == 0
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white24,
                    size: 28,
                  ),
                  onPressed: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  tooltip: "Harcamalarım",
                ),
                IconButton(
                  icon: Icon(
                    Icons.trending_up,
                    color: _selectedIndex == 1
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white24,
                    size: 28,
                  ),
                  onPressed: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  tooltip: "Gelirlerim",
                ),
                const SizedBox(width: 48), // FAB için boşluk
                IconButton(
                  icon: Icon(
                    Icons.apps,
                    color: _selectedIndex == 2
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white24,
                    size: 28,
                  ),
                  onPressed: () {
                    _pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  tooltip: "Araçlar",
                ),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: _selectedIndex == 3
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white24,
                    size: 28,
                  ),
                  onPressed: () {
                    _pageController.animateToPage(
                      3,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  tooltip: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
