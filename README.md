# 💰 Cashly - Kişisel Bütçe Takip Uygulaması

<p align="center">
  <img src="assets/image/logokeskinbuyuk.png" alt="Cashly Logo" width="120"/>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Flutter-3.24+-blue.svg" alt="Flutter"/></a>
  <a href="#"><img src="https://img.shields.io/badge/Dart-3.10+-blue.svg" alt="Dart"/></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg" alt="Platform"/></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License"/></a>
</p>

<p align="center">
  <b>Harcamalarınızı takip edin, bütçenizi yönetin, finansal hedeflerinize ulaşın!</b>
</p>

---

## 📱 Ekran Görüntüleri

<!-- Ekran görüntüleri eklenebilir -->
| Dashboard | Harcamalar | Gelirler |
|:---------:|:----------:|:--------:|
| 📊 | 💸 | 💰 |

---

## ✨ Özellikler

### 💳 Finansal Yönetim
- **Harcama Takibi** - Günlük, haftalık, aylık harcama analizi
- **Gelir Yönetimi** - Gelirlerinizi kategorize edin
- **Bütçe Limiti** - Aylık bütçe belirleme ve uyarı sistemi
- **Varlık Takibi** - Nakit, banka, kripto varlıklarınız

### 💳 Ödeme Yöntemleri
- Kredi/Banka kartları
- Nakit takibi
- Kart bakiye ve limit yönetimi

### 🎙️ Sesli Komutlar
- Sesli harcama ekleme
- Doğal dil işleme desteği

### 📊 Raporlama
- Kategori bazlı analiz
- Grafikler ve istatistikler
- PDF rapor dışa aktarma

### 🔐 Güvenlik
- PIN koruması
- Biyometrik kimlik doğrulama
- Güvenlik sorusu

### 🎨 Arayüz
- Modern ve minimal tasarım
- Karanlık/Aydınlık tema
- Özelleştirilebilir kategoriler

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.24+
- Dart SDK 3.10+
- Android Studio / VS Code

### Adımlar

```bash
# Repository'yi klonla
git clone https://github.com/SeyitAltintas/ButceTakipUygulamasi.git
cd cashly

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

---

## 🏗️ Proje Yapısı

```
lib/
├── core/                 # Ortak bileşenler
│   ├── constants/        # Sabitler
│   ├── di/               # Dependency Injection
│   ├── mixins/           # Mixin'ler
│   ├── services/         # Servisler
│   ├── theme/            # Tema yönetimi
│   ├── utils/            # Yardımcı fonksiyonlar
│   └── widgets/          # Ortak widget'lar
│
├── features/             # Özellik modülleri
│   ├── assets/           # Varlık yönetimi
│   ├── auth/             # Kimlik doğrulama
│   ├── dashboard/        # Ana ekran
│   ├── expenses/         # Harcamalar
│   ├── income/           # Gelirler
│   ├── payment_methods/  # Ödeme yöntemleri
│   └── settings/         # Ayarlar
│
└── main.dart             # Uygulama giriş noktası
```

---

## 🧪 Testler

```bash
# Unit ve Widget testleri
flutter test

# Test coverage ile
flutter test --coverage

# Entegrasyon testleri
flutter test integration_test/
```

**Test İstatistikleri:** 224+ test ✅

---

## 🔄 CI/CD

GitHub Actions ile otomatik:
- ✅ Kod analizi (`flutter analyze`)
- ✅ Testler (`flutter test`)
- ✅ APK build (commit mesajında `build` varsa)

---

## 📦 Kullanılan Paketler

| Paket | Kullanım |
|-------|----------|
| `hive_flutter` | Yerel veritabanı |
| `provider` | State yönetimi |
| `get_it` | Dependency Injection |
| `fl_chart` | Grafikler |
| `speech_to_text` | Sesli komutlar |
| `local_auth` | Biyometrik kimlik |
| `pdf` | PDF oluşturma |

---

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'feat: amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

---

<p align="center">
  Made with ❤️ using Flutter
</p>
