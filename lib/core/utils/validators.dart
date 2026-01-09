/// Cashly uygulaması için validasyon yardımcı fonksiyonları
class Validators {
  /// Email adresi format kontrolü
  ///
  /// Örnek: validateEmail("test@example.com") -> null (geçerli)
  ///        validateEmail("invalid") -> "Geçerli bir e-posta adresi girin"
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen e-posta adresinizi girin';
    }

    // Boşlukları temizle
    final email = value.trim().toLowerCase();

    // Email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  /// PIN validasyonu (4-6 rakam arası)
  ///
  /// Örnek: validatePIN("1234") -> null (geçerli)
  ///        validatePIN("123") -> "PIN 4 ile 6 rakam arasında olmalıdır"
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen bir PIN belirleyin';
    }

    if (value.length < 4 || value.length > 6) {
      return 'PIN 4 ile 6 rakam arasında olmalıdır';
    }

    if (int.tryParse(value) == null) {
      return 'PIN sadece rakamlardan oluşmalıdır';
    }

    return null;
  }

  /// İsim validasyonu
  ///
  /// Örnek: validateName("Ali") -> null (geçerli)
  ///        validateName("A") -> "İsminiz en az 2 karakter olmalıdır"
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen isminizi girin';
    }

    if (value.trim().length < 2) {
      return 'İsminiz en az 2 karakter olmalıdır';
    }

    if (value.trim().length > 50) {
      return 'İsminiz en fazla 50 karakter olabilir';
    }

    return null;
  }

  /// Tutar validasyonu (pozitif sayı)
  ///
  /// Örnek: validateAmount("100.50") -> null (geçerli)
  ///        validateAmount("-10") -> "Tutar pozitif bir sayı olmalıdır"
  static String? validateAmount(String? value, {double? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen tutar girin';
    }

    // Virgülü noktaya çevir
    final cleanedValue = value.trim().replaceAll(',', '.');

    final amount = double.tryParse(cleanedValue);

    if (amount == null) {
      return 'Geçerli bir sayı girin';
    }

    if (amount <= 0) {
      return 'Tutar pozitif bir sayı olmalıdır';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Maksimum tutar ${maxAmount.toStringAsFixed(0)} ₺ olabilir';
    }

    return null;
  }

  /// Miktar/adet validasyonu (pozitif sayı)
  ///
  /// Örnek: validateQuantity("5") -> null (geçerli)
  ///        validateQuantity("0") -> "Miktar 0'dan büyük olmalıdır"
  ///
  /// Edge case kontrolleri:
  /// - Boş veya null değer
  /// - Geçersiz sayı formatı
  /// - 0 veya negatif değer
  /// - Çok büyük değer (maksimum 1 milyar)
  /// - Çok küçük değer (minimum 0.00001)
  /// - Çok fazla ondalık basamak (maksimum 8)
  static String? validateQuantity(
    String? value, {
    double maxQuantity = 1000000000, // 1 milyar
    double minQuantity = 0.00001, // Pratik minimum
    int maxDecimalPlaces = 8,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Lütfen miktar girin';
    }

    // Virgülü noktaya çevir
    final cleanedValue = value.trim().replaceAll(',', '.');

    // Birden fazla nokta kontrolü
    if (cleanedValue.split('.').length > 2) {
      return 'Geçerli bir sayı formatı girin';
    }

    final quantity = double.tryParse(cleanedValue);

    if (quantity == null) {
      return 'Geçerli bir sayı girin';
    }

    // Negatif değer kontrolü
    if (quantity < 0) {
      return 'Miktar negatif olamaz';
    }

    // Sıfır kontrolü
    if (quantity == 0) {
      return 'Miktar 0\'dan büyük olmalıdır';
    }

    // Çok küçük değer kontrolü (pratik olmayan değerler)
    if (quantity < minQuantity) {
      return 'Miktar çok küçük (min: $minQuantity)';
    }

    // Çok büyük değer kontrolü
    if (quantity > maxQuantity) {
      return 'Miktar çok büyük (max: ${_formatLargeNumber(maxQuantity)})';
    }

    // Ondalık basamak kontrolü
    if (cleanedValue.contains('.')) {
      final decimalPart = cleanedValue.split('.').last;
      if (decimalPart.length > maxDecimalPlaces) {
        return 'En fazla $maxDecimalPlaces ondalık basamak girebilirsiniz';
      }
    }

    return null;
  }

  /// Büyük sayıları okunabilir formata çevirir
  static String _formatLargeNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(0)} Milyar';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)} Milyon';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)} Bin';
    }
    return number.toStringAsFixed(0);
  }

  /// Zorunlu alan kontrolü (genel)
  ///
  /// Örnek: validateRequired("Değer", fieldName: "Kategori") -> null (geçerli)
  ///        validateRequired(null, fieldName: "Kategori") -> "Kategori gereklidir"
  static String? validateRequired(
    String? value, {
    String fieldName = 'Bu alan',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  /// Açıklama alanı validasyonu (opsiyonel, maksimum karakter)
  ///
  /// Örnek: validateDescription("Kısa açıklama") -> null (geçerli)
  static String? validateDescription(String? value, {int maxLength = 100}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opsiyonel alan
    }

    if (value.trim().length > maxLength) {
      return 'Açıklama en fazla $maxLength karakter olabilir';
    }

    return null;
  }

  /// Harcama/Varlık ismi validasyonu
  ///
  /// Örnek: validateItemName("Market Alışverişi") -> null (geçerli)
  static String? validateItemName(String? value, {String itemType = 'Öğe'}) {
    if (value == null || value.trim().isEmpty) {
      return '$itemType adı gereklidir';
    }

    if (value.trim().isEmpty) {
      return '$itemType adı en az 1 karakter olmalıdır';
    }

    if (value.trim().length > 50) {
      return '$itemType adı en fazla 50 karakter olabilir';
    }

    return null;
  }
}
