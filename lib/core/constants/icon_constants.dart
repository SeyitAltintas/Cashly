import 'package:flutter/material.dart';

/// Tüm uygulama genelinde kullanılan ikon sabitleri.
/// Bu sınıf performans optimizasyonu için oluşturuldu.
/// İkon map'leri static const olarak tanımlandığından
/// her çağrıda yeniden oluşturulmaz.
class IconConstants {
  IconConstants._(); // Instantiation'ı engelle

  /// Harcama kategorileri için kullanılan ikonlar (200+)
  static const Map<String, IconData> harcamaIkonlari = {
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

  /// Gelir kategorileri için kullanılan ikonlar
  static const Map<String, IconData> gelirIkonlari = {
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

  /// İkon adından IconData döndürür
  static IconData getHarcamaIkonu(String ikonAdi) {
    return harcamaIkonlari[ikonAdi] ?? Icons.category;
  }

  /// Gelir ikonu adından IconData döndürür
  static IconData getGelirIkonu(String ikonAdi) {
    return gelirIkonlari[ikonAdi] ?? Icons.category;
  }

  /// Kategori isminden akıllı ikon bulma (Fallback mekanizması)
  /// Eğer veritabanındaki kategori ismi ile ikon eşleşmesi bozulursa,
  /// bu metod kategori ismindeki anahtar kelimelere bakarak doğru ikonu tahmin eder.
  static IconData getIconFromCategoryName(String categoryName) {
    if (categoryName.isEmpty) return Icons.category;

    final lowerName = categoryName.toLowerCase();

    // --- TIER 1: YÜKSEK ÖNCELİKLİ SPESİFİK KATEGORİLER ---

    // Sağlık & İlaç
    if (lowerName.contains('eczane') ||
        lowerName.contains('ilaç') ||
        lowerName.contains('hastane') ||
        lowerName.contains('doktor') ||
        lowerName.contains('muayene') ||
        lowerName.contains('sağlık') ||
        lowerName.contains('diş') ||
        lowerName.contains('tedavi')) {
      return Icons.medical_services;
    }

    // Evcil Hayvanlar
    if (lowerName.contains('veteriner') ||
        lowerName.contains('kedi') ||
        lowerName.contains('köpek') ||
        lowerName.contains('mama') ||
        lowerName.contains('pet')) {
      return Icons.pets;
    }

    // Eğitim & Kitap
    if (lowerName.contains('kitap') ||
        lowerName.contains('okul') ||
        lowerName.contains('kurs') ||
        lowerName.contains('eğitim') ||
        lowerName.contains('kırtasiye') ||
        lowerName.contains('udemy') ||
        lowerName.contains('ders')) {
      return Icons.school;
    }

    // Eğlence & Aktivite
    if (lowerName.contains('sinema') ||
        lowerName.contains('tiyatro') ||
        lowerName.contains('oyun') ||
        lowerName.contains('netflix') ||
        lowerName.contains('spotify') ||
        lowerName.contains('konser') ||
        lowerName.contains('etkinlik') ||
        lowerName.contains('bilet')) {
      return Icons.confirmation_number; // Bilet ikonu daha uygun
    }

    // Teknoloji & Elektronik
    if (lowerName.contains('telefon') ||
        lowerName.contains('bilgisayar') ||
        lowerName.contains('internet') || // Fatura değilse teknoloji olabilir
        lowerName.contains('elektronik') ||
        lowerName.contains('teknosa') ||
        lowerName.contains('mediamarkt') ||
        lowerName.contains('yazılım') ||
        lowerName.contains('uygulama')) {
      return Icons.devices;
    }

    // --- TIER 2: GENEL HARCAMA KATEGORİLERİ ---

    // Giyim & Moda
    if (lowerName.contains('giyim') ||
        lowerName.contains('kıyafet') ||
        lowerName.contains('ayakkabı') ||
        lowerName.contains('moda') ||
        lowerName.contains('tekstil') ||
        lowerName.contains('mağaza')) {
      return Icons.checkroom;
    }

    // Bakım & Kozmetik
    if (lowerName.contains('kuaför') ||
        lowerName.contains('berber') ||
        lowerName.contains('kozmetik') ||
        lowerName.contains('bakım') ||
        lowerName.contains('gratis') ||
        lowerName.contains('watsons')) {
      return Icons.face;
    }

    // Yemek & Kafe (Geniş kapsam)
    if (lowerName.contains('yemek') ||
        lowerName.contains('kafe') ||
        lowerName.contains('restoran') ||
        lowerName.contains('cafe') ||
        lowerName.contains('kahve') ||
        lowerName.contains('starbucks') ||
        lowerName.contains('burger') ||
        lowerName.contains('pizza') ||
        lowerName.contains('lahmacun') ||
        lowerName.contains('kebap')) {
      return Icons.restaurant;
    }

    // Market & Alışveriş (Geniş kapsam)
    if (lowerName.contains('market') ||
        lowerName.contains('bakkal') ||
        lowerName.contains('süper') ||
        lowerName.contains('migros') ||
        lowerName.contains('bim') ||
        lowerName.contains('a101') ||
        lowerName.contains('şok') ||
        lowerName.contains('carrefour') ||
        lowerName.contains('pazar') ||
        lowerName.contains('alışveriş')) {
      return Icons.shopping_basket;
    }

    // Araç & Ulaşım
    if (lowerName.contains('araç') ||
        lowerName.contains('ulaşım') ||
        lowerName.contains('taksi') ||
        lowerName.contains('uber') ||
        lowerName.contains('martı') ||
        lowerName.contains('benzin') ||
        lowerName.contains('mazot') ||
        lowerName.contains('lpg') ||
        lowerName.contains('yakıt') ||
        lowerName.contains('otobüs') ||
        lowerName.contains('metro') ||
        lowerName.contains('uçak') ||
        lowerName.contains('bilet') || // Uçak bileti vs
        lowerName.contains('seyahat') ||
        lowerName.contains('otopark') ||
        lowerName.contains('hgs') ||
        lowerName.contains('ogs')) {
      return Icons.two_wheeler;
    }

    // Sabit Giderler & Faturalar
    if (lowerName.contains('fatura') ||
        lowerName.contains('kira') ||
        lowerName.contains('elektrik') ||
        lowerName.contains(
          'su ',
        ) || // Boşluk önemli: 'su' her kelimede geçebilir
        lowerName.contains('doğalgaz') ||
        lowerName.contains('internet') ||
        lowerName.contains('telefon') ||
        lowerName.contains('türk telekom') ||
        lowerName.contains('turkcell') ||
        lowerName.contains('vodafone') ||
        lowerName.contains('aidat')) {
      return Icons.receipt_long;
    }

    // Hediye
    if (lowerName.contains('hediye') ||
        lowerName.contains('bağış') ||
        lowerName.contains('yardım') ||
        lowerName.contains('özel gün')) {
      return Icons.card_giftcard;
    }

    // Ev & Yaşam
    if (lowerName.contains('ev') ||
        lowerName.contains('mobilya') ||
        lowerName.contains('dekor') ||
        lowerName.contains('tadilat') ||
        lowerName.contains('ikea') ||
        lowerName.contains('koçtaş')) {
      return Icons.home;
    }

    // --- TIER 3: FİNANSAL TERİMLER ---

    if (lowerName.contains('maaş')) return Icons.work;
    if (lowerName.contains('freelance') || lowerName.contains('proje')) {
      return Icons.laptop_mac;
    }
    if (lowerName.contains('yatırım') ||
        lowerName.contains('hisse') ||
        lowerName.contains('altın') ||
        lowerName.contains('döviz') ||
        lowerName.contains('coin') ||
        lowerName.contains('bitcoin')) {
      return Icons.trending_up;
    }
    if (lowerName.contains('kredi') || lowerName.contains('borç')) {
      return Icons.credit_score;
    }

    // Varsayılan: Eğer 've' bağlacı varsa muhtemelen bir kategori ismidir
    if (lowerName.contains(' ve ')) {
      // Kategori isminden tahmin edemiyorsak standart ikon
      return Icons.category;
    }

    return Icons.category;
  }
}
