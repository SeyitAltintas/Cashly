# CODEBASE.md — Cashly Project Intelligence

> **Purpose:** This is the single source of truth for AI agents working on this Flutter project.
> Referenced by GEMINI.md § File Dependency Awareness. Read this BEFORE touching any file.

---

## 🔑 Project Identity

| Key | Value |
|---|---|
| Name | Cashly |
| Type | **Flutter Mobile App** (Android + iOS) |
| Architecture | Clean Architecture + Feature-First |
| State Management | Provider + ChangeNotifier |
| Dependency Injection | GetIt (get_it) |
| Database | **Hive (local) + Firebase Firestore (cloud)** — flag-based switch |
| Cloud Backend | Firebase (Firestore, Auth, Crashlytics) |
| Navigation | go_router v14 |
| Localization | gen-l10n ARB (TR, EN) |
| Dart SDK | ^3.10.0 |
| Entry Point | `lib/main.dart` |
| Agent | `mobile-developer` (PRIMARY) |

---

## 📍 Critical Paths (Quick Lookup)

```
lib/main.dart                              → App entry, Firebase init, Hive init, DI init
lib/firebase_options.dart                  → FlutterFire CLI generated config
lib/core/di/injection_container.dart       → ALL GetIt registrations (~310 lines, flag-based repo selection)
lib/core/router/app_router.dart            → GoRouter config, auth guard
lib/core/router/route_names.dart           → Type-safe route constants
lib/core/theme/app_theme.dart              → Dark theme, colors, typography
lib/core/services/database_helper.dart     → Hive box operations
lib/core/services/migration_flags.dart     → Hive↔Firestore feature flag
lib/core/services/hive_to_firestore_migration.dart → One-time data migration
lib/core/services/error_logger_service.dart → Hybrid error logger (Hive + Crashlytics)
lib/core/services/cloud_sync_service.dart  → Cloud data sync on login & refresh
lib/core/services/crashlytics_test_helper.dart → Crashlytics test utilities
lib/core/domain/usecases/base_usecase.dart → UseCase<O,P>, Result<T>, NoParams
lib/core/exceptions/app_exceptions.dart    → 8 exception classes
lib/l10n/app_tr.arb                        → Turkish strings (~500 keys)
lib/l10n/app_en.arb                        → English strings (~500 keys)
pubspec.yaml                               → 30+ runtime + 5 dev dependencies
firestore.rules                            → Security rules (user isolation)
android/app/google-services.json           → Firebase Android config
```

---

## 🏗️ Architecture Contract

### Layer Rules (MUST follow)

```
Presentation → Domain → Data
     ↓             ↓         ↓
  Pages          Entities   Models/DTOs
  Controllers    UseCases   Repository Impl (Hive)
  State          Repo IF    Repository Firestore (Cloud)
  Widgets                   DataSources (Hive / Firestore)
```

**Dependency Rule:** Outer layers depend on inner layers. NEVER import `data/` from `domain/`.

### Feature Module Template

Every feature under `lib/features/{name}/` SHOULD have:

```
{feature}/
├── index.dart                          # Barrel export
├── data/
│   ├── models/        → {name}_model.dart
│   └── repositories/  → {name}_repository_impl.dart      (Hive)
│                        {name}_repository_firestore.dart  (Firestore)
├── domain/
│   ├── entities/      → {name}_entity.dart (optional)
│   └── repositories/  → {name}_repository.dart (abstract interface)
└── presentation/
    ├── controllers/   → {name}_controller.dart (ChangeNotifier)
    ├── pages/         → {name}_page.dart
    ├── state/         → {name}_page_state.dart
    └── widgets/       → Feature-specific widgets
```

### Incomplete Features (missing layers)

| Feature | Has data/ | Has domain/ | Note |
|---|---|---|---|
| analysis | ❌ | ❌ | Presentation only |
| dashboard | ❌ | ❌ | Presentation only |
| tools | ❌ | ❌ | Presentation only |
| home | ❌ | ❌ | Presentation + providers/ |

---

## 📦 Feature Registry (11 modules)

| Feature | Purpose | Key Files | Firestore |
|---|---|---|---|
| `auth` | Login, signup, multi-user, biometric | `auth_controller`, `user_model`, `user_entity` | ✅ CloudSync (UID) |
| `dashboard` | Overview cards, budget status, recent txns | `dashboard_controller`, 6 card widgets | — |
| `expenses` | CRUD, categories, filters, recycle bin | `expenses_controller`, `expense_repository_impl` | ✅ `expense_repository_firestore` |
| `income` | CRUD, categories, recurring, recycle bin | `incomes_controller`, `income_repository_impl` | ✅ `income_repository_firestore` |
| `assets` | Gold/forex/crypto tracking, live prices | `assets_controller`, `asset_model`, API prices | ✅ `asset_repository_firestore` |
| `payment_methods` | Cards, cash, transfers, scheduled transfers | `payment_methods_controller`, `transfer_model` | ✅ `payment_method_repository_firestore` |
| `analysis` | Charts (fl_chart), PDF export | `analysis_controller`, `pdf_export_page` | — |
| `streak` | Gamification, daily streaks, badges | `streak_controller`, `streak_service`, celebration dialog | ✅ `streak_repository_firestore` |
| `settings` | 6 sub-modules (appearance, finance, voice, profile, notifications, support) | ~42 files | ❌ |
| `tools` | Quick access menu | `tools_controller`, `tools_page` | — |
| `home` | 3-tab bottom nav (Tools, Dashboard, Profile) | `home_page` (763 lines — refactor candidate) | — |

---

## 🔗 File Dependency Map

### Core → Feature Dependencies

When modifying these core files, check ALL listed dependents:

| Core File | Dependent Features |
|---|---|
| `injection_container.dart` | **ALL** — every controller/repo is registered here |
| `main.dart` | Firebase init, Crashlytics handlers, MigrationFlags check |
| `migration_flags.dart` | `injection_container.dart` (determines Hive vs Firestore) |
| `hive_to_firestore_migration.dart` | All Hive repositories (reads data for migration) |
| `error_logger_service.dart` | **ALL** — hybrid Hive + Crashlytics error logging |
| `app_router.dart` | `auth`, `home` |
| `route_names.dart` | `home` (navigation), all feature pages |
| `app_theme.dart` | **ALL** — every UI file uses theme |
| `database_helper.dart` | `auth` (delete user), settings |
| `base_usecase.dart` | All usecases in `core/domain/usecases/` |
| `app_exceptions.dart` | All controllers, repositories |
| `l10n_extensions.dart` | All pages/widgets using `context.l10n` |
| `validators.dart` | All form pages (add expense, add income, etc.) |
| `currency_formatter.dart` | All pages displaying money amounts |
| `backup_service.dart` | `settings` (profile/danger zone), all repositories (data format) |

### Feature → Feature Dependencies

| Source Feature | Depends On |
|---|---|
| `home` | `dashboard`, `expenses`, `income`, `assets`, `payment_methods`, `streak`, `tools`, `settings`, `analysis` |
| `dashboard` | `expenses`, `income`, `assets`, `payment_methods` (reads their data) |
| `analysis` | `expenses`, `income` (reads transaction data) |
| `settings/finance` | `expenses`, `income`, `payment_methods` (category/budget config) |
| `streak` | `expenses` (checks daily expense logging) |

### Shared Widgets Usage

| Widget | Used By |
|---|---|
| `app_snackbar.dart` | ALL features |
| `app_loading_overlay.dart` | `home`, `settings/profile`, `auth` |
| `empty_state_widget.dart` | `expenses`, `income`, `assets`, `payment_methods` |
| `animated_card.dart` | `dashboard`, `expenses`, `income` |
| `form/` widgets | `expenses/add`, `income/add`, `assets/add`, `payment_methods/add` |
| `month_year_picker.dart` | `home`, `expenses`, `income`, `analysis` |
| `error_boundary.dart` | `home` (wraps all pages) |
| `network_status_banner.dart` | `home` |

---

## 🗄️ Data Layer Details

### Database Strategy (Dual-mode)

```
┌──────────────────────────────────────────────────────┐
│  MigrationFlags.useFirestore == false (default)      │
│  → Hive repositories (offline, local-only)           │
│                                                      │
│  MigrationFlags.useFirestore == true                 │
│  → Firestore repositories (cloud, offline-cached)    │
└──────────────────────────────────────────────────────┘
```

**Switch mechanism:** `injection_container.dart` receives `useFirestore` flag → registers Hive or Firestore repos.

### Hive Box Schema

| Box Name | Purpose |
|---|---|
| `cashly_box` | Main data (expenses, incomes, assets, payment methods, settings per user) |
| `settings` | App-level settings (theme, currency, animation toggles) |
| `error_logs` | Local error log buffer (hybrid with Crashlytics) |
| `migration_flags` | Migration status flag |

### Firestore Collection Schema

| Collection Path | Purpose | Security |
|---|---|---|
| `users/{uid}/expenses/{docId}` | Expense documents | Owner-only |
| `users/{uid}/incomes/{docId}` | Income documents | Owner-only |
| `users/{uid}/assets/{docId}` | Asset documents | Owner-only |
| `users/{uid}/payment_methods/{docId}` | Payment method documents | Owner-only |

**Date handling:** Hive stores dates as `String`, Firestore uses `Timestamp` for query performance.
**Batch limit:** Migration uses 450-doc batches (Firestore max is 500).
**Offline:** `persistenceEnabled: true`, `cacheSizeBytes: UNLIMITED`.

### Key Naming Convention (User-scoped, Hive)

All user data keys follow: `{data_type}_{userId}`

```
harcamalar_{userId}         → Expenses list (JSON array)
butce_limiti_{userId}       → Monthly budget limit
sabit_gider_sablonlari_{userId} → Recurring expense templates
kategoriler_{userId}        → Custom expense categories
gelirler_{userId}           → Incomes list
gelir_kategorileri_{userId} → Custom income categories
tekrarlayan_gelirler_{userId} → Recurring income templates
varliklar_{userId}          → Assets list
silinen_varliklar_{userId}  → Deleted assets (recycle bin)
odeme_yontemleri_{userId}   → Payment methods
silinen_odeme_yontemleri_{userId} → Deleted payment methods
varsayilan_odeme_yontemi_{userId} → Default payment method
transferler_{userId}        → Transfer history
sesli_geri_bildirim_{userId} → Voice feedback toggle
```

---

## 🧭 Naming Conventions

### Dart Files
- **Models:** `{name}_model.dart` (e.g., `asset_model.dart`)
- **Entities:** `{name}_entity.dart` (e.g., `user_entity.dart`)
- **Controllers:** `{name}_controller.dart` (ChangeNotifier)
- **Pages:** `{name}_page.dart` or `{action}_{name}_page.dart`
- **State:** `{name}_state.dart` or `{page_name}_state.dart`
- **Repository Interface:** `{name}_repository.dart` (abstract)
- **Repository Impl (Hive):** `{name}_repository_impl.dart`
- **Repository Impl (Firestore):** `{name}_repository_firestore.dart`
- **Barrel Exports:** `index.dart` in each feature root

### Code Language
- **Variable/function names:** Turkish naming in some legacy code (e.g., `harcamalar`, `butce`), English in newer code
- **Comments:** Turkish (legacy) + English (newer)
- **UI strings:** Always localized via ARB (never hardcoded)

---

## 🧪 Test Yapısı — Kapsamlı Dokümantasyon

### Genel Bakış

| Kategori | Dosya Sayısı | Test Sayısı | Kapsam |
|---|---|---|---|
| **Unit Test** | 51 | 826 | Controllers, Services, Models, Utils, Handlers |
| **Widget Test** | 21 | ~200+ | UI bileşenleri, form widgets |
| **E2E Integration Test** | 80 | 80 akış | Tüm 47 sayfa %100 kapsam + Cihaz Teorileri + Aşırı Limitler + State Havuzları |
| **TOPLAM** | **152** | **1105+** | ✅ |

```
test/
├── helpers/           → mock_hive.dart, test_helpers.dart (paylaşılan test araçları)
├── unit/              → 51 dosya (controller, servis, model, handler, util testleri)
└── widget/            → 21 dosya (UI bileşen testleri)

integration_test/      → 80 dosya (E2E kullanıcı akışları)
```

**Test adlandırma:** `{kaynak_dosya}_test.dart`
**Mock framework:** `mocktail`
**CI:** GitHub Actions (`ci.yml`) → analyze + test + coverage + conditional APK build

---

### 📋 Unit Testler (51 dosya / 826 test)

#### 🎮 Controller Testleri (9 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `analysis_controller_test.dart` | `analysis_controller.dart` | Analiz sayfası state yönetimi, tarih filtresi, grafik veri hazırlama |
| `auth_controller_test.dart` | `auth_controller.dart` | Login/logout, PIN doğrulama, kullanıcı değiştirme, oturum yönetimi |
| `assets_controller_test.dart` | `assets_controller.dart` | Varlık CRUD, fiyat güncelleme, filtreleme, silme/geri yükleme |
| `dashboard_controller_test.dart` | `dashboard_controller.dart` | Dashboard veri toplama, bakiye hesaplama, bütçe durum kontrolü |
| `expenses_controller_test.dart` | `expenses_controller.dart` | Harcama CRUD, kategori filtreleme, ay bazlı sorgulama |
| `incomes_controller_test.dart` | `incomes_controller.dart` | Gelir CRUD, kategori yönetimi, tekrarlayan gelirler |
| `payment_methods_controller_test.dart` | `payment_methods_controller.dart` | Ödeme yöntemi CRUD, bakiye güncelleme, transfer işlemleri |
| `streak_controller_test.dart` | `streak_controller.dart` | Seri güncellemesi, rozet kontrolü, freeze kullanımı |
| `tools_controller_test.dart` | `tools_controller.dart` | Araçlar sayfası state yönetimi |

#### 🔧 Servis Testleri (8 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `currency_service_test.dart` | `currency_service.dart` | `supportedCurrencies` map (TRY/USD/EUR/GBP), `convert()` — aynı birim, sıfır tutar, bilinmeyen birim, negatif tutar, büyük tutarlar, ondalık hassasiyet, sembol çözümleme |
| `currency_formatter_test.dart` | `currency_formatter.dart` | Para biçimlendirme, binlik ayracı, ondalık, sembol konumu |
| `price_service_test.dart` | `price_service.dart` | TRY=1.0 sabiti, altın tipleri (gram/çeyrek/yarım/tam/cumhuriyet/ata/ons), gümüş (gram/ons), kripto (bitcoin/ethereum), döviz (USD/EUR/GBP), cache helper fonksiyonları |
| `asset_price_update_service_test.dart` | `asset_price_update_service.dart` | Kategori filtreleme (Banka/Hisse/Diğer atlanır), silinen varlık koruması, sıralama tutarlılığı, API online/offline davranış, `getUnitPrice` routing |
| `cache_service_test.dart` | `price_cache_service.dart` | Cache okuma/yazma, TTL, geçersizleme |
| `image_cache_service_test.dart` | `image_cache_service.dart` | Profil resmi cache, boyut limiti |
| `image_compression_service_test.dart` | `image_compression_service.dart` | Varsayılan boyutlar, kalite sabitleri, singleton pattern, Size model |
| `network_service_test.dart` | `network_service.dart` | Bağlantı durumu, offline/online geçişleri |

#### 📊 Model Testleri (5 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `asset_model_test.dart` | `asset_model.dart` | Constructor defaults, kâr/zarar hesaplama (%50 kâr, %20 zarar, başa baş, sıfıra bölme), birim fiyat, `toMap`/`fromMap` round-trip, geriye dönük uyumluluk, `copyWith` |
| `income_model_test.dart` | `income_model.dart` | Constructor zorunlu/opsiyonel alanlar, serialization, varsayılan değerler, `copyWith` immutability |
| `payment_method_model_test.dart` | `payment_method_model.dart` | `typeDisplayName` (banka/kredi/nakit/unknown), `remainingLimit` (normal, maxed out, exceeded, limit null), serialization round-trip, geriye dönük uyumluluk |
| `transfer_model_test.dart` | `transfer_model.dart` | `isDue` (geçmiş/bugün/gelecek tarih), `isPending` durum makinesi (5 senaryo), serialization, `copyWith` |
| `user_model_test.dart` | `user_model.dart` + `user_entity.dart` | UserEntity/UserModel constructor, `toMap`/`fromMap`, `fromEntity` dönüşümü, geriye dönük uyumluluk |

#### 🏷️ Streak & Rozet Testleri (3 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `streak_model_badges_test.dart` | `streak_model.dart` + `streak_badges.dart` | StreakData constructor, `empty()` factory, `canUseFreeze`, serialization, `copyWith`, `toString`; 7 rozet sıralama (3→365 gün), `getBadgeById`, `getEarnedBadges` ilerleme (0→365+ gün), `getNextBadge` |
| `streak_service_logic_test.dart` | `streak_service.dart` | Seri hesaplama mantığı, gün atlanması, freeze kullanımı |
| `streak_controller_test.dart` | `streak_controller.dart` | UI state yönetimi, rozet bildirimleri |

#### 🗣️ Ses Komutu Handler Testleri (4 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `voice_command_handlers_test.dart` | `expense_action_handler.dart`, `expense_query_handler.dart`, `misc_handler.dart` | Harcama silme/düzenleme/ekleme komutları, 7 zaman bazlı sorgu tipi, tarih aralığı çıkarma, öncelik sıralaması |
| `voice_command_types_test.dart` | `voice_command_types.dart` | Komut enum'ları, tip güvenliği |
| `budget_handler_test.dart` | `budget_handler.dart` | Bütçe aşım sorguları, kalan bütçe, limit belirleme, tasarruf hesaplama |
| `category_query_handler_test.dart` | `category_query_handler.dart` | Kategori bazlı sorgular, "en çok hangi kategori", zaman bazlı kategori sorguları |

#### 🔢 Util & Parser Testleri (7 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `amount_extractor_test.dart` | `amount_extractor.dart` | Sayı çıkarma, ondalık, binlik, "bin/milyon" çarpanları, Türkçe sayı kelimeleri |
| `amount_input_formatter_test.dart` | `amount_input_formatter.dart` | Tutar giriş formatlama, binlik ayracı, max değer |
| `date_extractor_test.dart` | `date_extractor.dart` | "bugün", "dün", "geçen hafta", "bu ay" gibi Türkçe tarih ifadelerinden DateTime çıkarma |
| `category_matcher_test.dart` | `category_matcher.dart` | Kategori eşleme, fuzzy matching, büyük/küçük harf duyarsızlık |
| `validators_test.dart` | `validators.dart` | Form validasyonları: email, PIN, tutar, zorunlu alan |
| `validators_extended_test.dart` | `validators.dart` | Genişletilmiş validasyonlar: edge case'ler, uluslararası formatlar |
| `debouncer_test.dart` | `debouncer.dart` | Zamanlayıcı, iptal, yeniden tetikleme |

#### 📦 İş Mantığı Testleri (6 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `expense_business_logic_test.dart` | Gider iş kuralları | Bütçe kontrolü, kategori filtreleme, toplam hesaplama |
| `income_business_logic_test.dart` | Gelir iş kuralları | Aylık gelir toplama, kategori bazlı raporlama |
| `asset_business_logic_test.dart` | Varlık iş kuralları | Portföy değerleme, kar/zarar hesaplama |
| `payment_method_business_logic_test.dart` | Ödeme yöntemi iş kuralları | Bakiye kontrolü, limit aşım, transfer validasyonu |
| `recurring_transaction_logic_test.dart` | Tekrarlayan işlem mantığı | Otomatik oluşturma zamanlaması, şablon uygulama |
| `export_filter_logic_test.dart` | PDF dışa aktarma filtreleme | Tarih aralığı, kategori filtresi, veri hazırlama |

#### 🛡️ Altyapı Testleri (9 dosya)

| Dosya | Test Edilen Kaynak | Test İçeriği |
|---|---|---|
| `base_usecase_test.dart` | `base_usecase.dart` | `NoParams` marker, `Result` Either-pattern, `fold` type-safe callbacks, generic type safety |
| `app_exceptions_test.dart` | `app_exceptions.dart` | 8 exception sınıfı, hata mesajları, inheritance |
| `error_handler_test.dart` | `error_handler.dart` | Hata yakalama, loglama, kullanıcıya gösterme stratejisi |
| `color_constants_test.dart` | `color_constants.dart` | Renk sabitleri, tema tutarlılığı |
| `month_year_picker_state_test.dart` | `month_year_picker` state | Ay/yıl seçimi state yönetimi |
| `notification_service_test.dart` | `notification_service.dart` | Bildirim servisi, zamanlama |
| `notification_scheduler_test.dart` | `notification_scheduler.dart` | Bildirim zamanlayıcı, tekrarlayan bildirimler |
| `notification_types_test.dart` | `notification_types.dart` | Bildirim tipleri enum, öncelik |
| `notification_exception_test.dart` | `notification_exception.dart` | Bildirim hata sınıfları |
| `pdf_utils_test.dart` | `pdf_utils.dart` | PDF oluşturma yardımcı fonksiyonları |

---

### 🖼️ Widget Testleri (21 dosya / ~200+ test)

| Dosya | Test Edilen Widget | Test İçeriği |
|---|---|---|
| `add_expense_form_test.dart` | Harcama ekleme formu | Form validasyonu, tutar girişi, kategori seçimi |
| `add_income_form_test.dart` | Gelir ekleme formu | Form alanları, varsayılan değerler |
| `add_asset_form_test.dart` | Varlık ekleme formu | Kategori bazlı form değişimi (Altın/Kripto/Döviz) |
| `add_payment_method_form_test.dart` | Ödeme yöntemi formu | Kart tipi seçimi, son 4 hane, limit alanı |
| `dashboard_card_test.dart` | Dashboard kartları | Bakiye kartı, bütçe kartı, son işlemler |
| `expense_list_item_test.dart` | Harcama listesi öğesi | Tutar formatlama, kategori ikonu, tarih gösterimi |
| `income_list_item_test.dart` | Gelir listesi öğesi | Tutar, kategori, ödeme yöntemi gösterimi |
| `asset_list_item_test.dart` | Varlık listesi öğesi | Güncel fiyat, kar/zarar renklendirme |
| `payment_method_card_test.dart` | Ödeme yöntemi kartı | Kart rengi, bakiye, son 4 hane |
| `category_chip_test.dart` | Kategori chip widget | Seçili/seçilmemiş durumu, ikon |
| `empty_state_test.dart` | Boş durum widget | İkon, mesaj, buton |
| `animated_card_test.dart` | Animasyonlu kart | Giriş animasyonu, dokunma efekti |
| `app_snackbar_test.dart` | Bildirim snackbar | Başarı/hata/uyarı renkleri |
| `month_year_picker_test.dart` | Ay-yıl seçici | Ay seçimi, yıl değiştirme, sınır kontrolü |
| `budget_progress_test.dart` | Bütçe ilerleme çubuğu | Yüzde hesaplama, renk değişimi (yeşil→sarı→kırmızı) |
| `streak_badge_test.dart` | Rozet widget | Kazanılmış/kazanılmamış gösterimi, animasyon |
| `transfer_form_test.dart` | Transfer formu | Hesap seçimi, tutar validasyonu |
| `currency_selector_test.dart` | Para birimi seçici | TRY/USD/EUR/GBP listesi, sembol gösterimi |
| `search_bar_test.dart` | Arama çubuğu | Metin girişi, temizleme, debounce |
| `date_picker_test.dart` | Tarih seçici | Tarih seçimi, format |
| `confirmation_dialog_test.dart` | Onay dialog | İptal/Onayla butonları, mesaj |

---

### 🚀 E2E Integration Testler (80 dosya / 80 akış)

#### 🔐 Kimlik Doğrulama & Lifecycle & Cihaz Ayarları (8 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `app_test.dart` | Uygulama başlatma, ana sayfa yüklenmesi |
| `login_test.dart` | PIN ile giriş yapma akışı |
| `auth_flow_test.dart` | Login → Signup geçişi, kimlik doğrulama |
| `signup_multiuser_flow_test.dart` | Yeni kullanıcı kaydı, kullanıcı listesi, kullanıcı değiştirme |
| `app_lifecycle_lock_flow_test.dart` | Uygulamanın background'a (Paused) gidip tekrar açılması (Resumed) ve kilit davranışı / stabilizasyonu |
| `hardware_back_navigation_test.dart` | Derin sayfalarda Android/iOS Donanım (Geri) Tuşunun Route pop davranışını test eder. |
| `accessibility_text_scale_test.dart` | Telefon Text Size ayarının %300 (3.0x) büyütülmesinde UI'ın "RenderFlex Overflow" çökmesi yaşayıp yaşamadığı. |
| `theme_persistence_restart_test.dart` | Ayarlardan UI seçeneklerini (Tema vs.) değiştirip app'i reboot/detach ettikten sonra açılış senaryosunun testi. |

#### 📊 Dashboard & Navigasyon (4 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `dashboard_sync_test.dart` | Gelir ekleme → Dashboard bakiye senkronizasyonu |
| `navigation_test.dart` | Alt menü sekmeleri arası geçiş |
| `full_app_tour_test.dart` | **Smoke test:** Tüm ana sekmelere (Dashboard, vb.) sırayla git, hiçbirinde crash olmadığını doğrula |
| `date_filter_flow_test.dart` | Tarih/Ay seçici üzerinden geçmiş aylara gidip filtreleme ve boş veri UI kontrolü |

#### 💸 Gider Akışları (9 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `expense_flow_test.dart` | Harcama ekleme → Listede görünme → Tutar doğrulama |
| `expense_edit_flow_test.dart` | Harcama ekle → Detaya tıkla → İsim ve tutarı düzenle → Kaydedildiğini doğrula |
| `multi_expense_flow_test.dart` | 3 harcama sırayla ekle (Kahve/Taksi/Yemek) → Listede sıralama → Dashboard toplamı |
| `expense_delete_balance_test.dart` | Harcama ekle → Swipe-to-delete → Dashboard bakiyesinin geri döndüğünü doğrula |
| `recycle_bin_flow_test.dart` | Silinen harcama → Çöp kutusunda görünme |
| `complex_recycle_bin_flow_test.dart` | Harcama sil → Çöp kutusuna git → Geri yükle → Ana listede tekrar göründüğünü doğrula |
| `category_management_flow_test.dart` | Ayarlar → Gider Ayarları → Kategori Yönetimi → "Hobi E2E" kategorisi ekle → Listede doğrula |
| `search_filter_flow_test.dart` | Gider listesinde 'Arama' ikonuna basıp kelime ile spesifik veriyi filtreleme |
| `custom_category_delete_test.dart` | Özel kategori oluşturup Sil butonuna basma, Onay Dialog'unun gelmesinin testi |

#### 💰 Gelir Akışları (5 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `income_flow_test.dart` | Gelir ekleme → Listede görünme → Tutar doğrulama |
| `income_edit_flow_test.dart` | Gelir ekle → Detaya tıkla → İsim düzenle → Kaydet → Güncelleme doğrula |
| `recurring_income_flow_test.dart` | Gelir Ayarları → "Maaş E2E" tekrarlayan gelir ekle → Listede doğrula |
| `income_category_flow_test.dart` | Gelir Ayarları → Kategori Yönetimi → "Yatırım Geliri E2E" ekle → Doğrula |
| `income_recycle_bin_flow_test.dart` | Gelirler → Ayarlar → Çöp kutusu sayfasını aç → Stabilite kontrolü |

#### 📦 Varlık Akışları (4 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `asset_flow_test.dart` | Varlık ekleme (varlık tipini seç) → Listede görünme |
| `asset_offline_sync_test.dart` | Varlık ekle → Pull-to-refresh (fiyat çek) → Offline toleransı, cache kullanımı |
| `asset_detail_flow_test.dart` | Varlık ekle → Detay sayfasını aç → Kar/zarar bilgisi → Geri dön |
| `asset_recycle_bin_flow_test.dart` | Varlıklar → Çöp kutusunu aç → Silinen varlıkları gör → Geri dön |

#### 💳 Ödeme Yöntemi & Transfer Akışları (6 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `payment_method_flow_test.dart` | Ödeme yöntemi ekleme (banka/kredi/nakit) → Listede görünme |
| `payment_detail_flow_test.dart` | İlk ödeme yöntemine tıkla → Detay sayfasında bakiye/limit → Borç analizi → Geri |
| `payment_recycle_bin_flow_test.dart` | Hesaplarım → Çöp kutusunu aç → Silinen yöntemleri gör |
| `transfer_flow_test.dart` | Hesaplarım → Transfer sayfası → Tutar gir → Transfer Et |
| `scheduled_transfer_flow_test.dart` | Transfer ederken pop-up tarih seçicide ileri tarihli bekleme (Pending) zamanı atamak |
| `credit_card_payment_flow_test.dart` | Bankadan eksi limitli kredi kartına ödeme atıp borç kapatma simülasyonu (Dropdown etkileşimi) |

#### 📈 Analiz & Raporlar (2 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `analysis_flow_test.dart` | Harcama ekle → Analiz sekmesi → Grafik/liste render → Tab değiştirme |
| `export_report_flow_test.dart` | Harcama ekle → Raporlar → PDF dışa aktarma başlat → Crash kontrolü |

#### 🎯 Bütçe Yönetimi (2 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `budget_limit_warning_flow_test.dart` | Ayarlar'da 1000 TL bütçe koy → 1500 TL harcama ekle → Dashboard'da aşım uyarısı |
| `category_budget_flow_test.dart` | Ayarlar → Kategori Bütçeleri → Kategoriye 2000 TL limit → Dashboard'da yansıma |

#### ⚙️ Ayarlar Akışları (11 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `settings_flow_test.dart` | Ayarlar sekmesi → Tema değiştirme → UI güncelleme |
| `theme_toggle_rebuild_test.dart` | Ayarlar'dan Karanlık tema seçip Ağır UI Grafik ekranlarına giderek "Rebuild/Crash" kontrolü |
| `language_change_flow_test.dart` | Ayarlar → Dil → TR'den EN'e geçiş → Nav bar güncellenmesi → Tekrar TR'ye |
| `currency_change_flow_test.dart` | Dashboard'da ₺ (TRY) → Ayarlar → $ (USD) → Dashboard sembol değişimi → ₺'ye geri |
| `notification_settings_flow_test.dart` | Ayarlar → Bildirimler → Switch toggle açma/kapama → Stabilite |
| `appearance_settings_flow_test.dart` | Ayarlar → Görünüm → Animasyon toggle → Haptic toggle → Stabilite |
| `transfer_settings_flow_test.dart` | Ayarlar → Transfer Ayarları → Switch toggle → Geri dön |
| `recurring_transaction_flow_test.dart` | Ayarlar → Gider Ayarları → Tekrarlayan gider "Kira 5000 TL" ekle → Doğrula |
| `profile_update_flow_test.dart` | Ayarlar → Profil → İsim "E2E Test Kullanıcı" olarak güncelle → Kaydet → Doğrula |
| `voice_commands_flow_test.dart` | Ayarlar → Sesli Asistan → Komut listesi → Detay → Geri dön |
| `about_support_flow_test.dart` | Ayarlar → Hakkında → SSS açma → Gizlilik Politikası → Kullanım Koşulları |

#### 🔥 Form, Streak, UI Limits & Edge Cases (16 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `form_validation_errors_test.dart` | Ekleme formunu boş bırakıp kaydetme zorlaması, Validator mesajlarının ekrana düşme testi |
| `empty_state_ui_flow_test.dart` | Kayıtlı işlem yokken Varlıkların ve Hesapların EmptyState "Burada işlem yok" uyarısı çizme testi |
| `unsaved_form_changes_alert_test.dart` | Bir input formunu doldurup kaydetmeden doğrudan 'Geri' basıp verileri feda etme (WillPopScope / Uyarı) uyarısı testleri |
| `streak_page_flow_test.dart` | Dashboard'daki streak ikonu → Streak sayfası (rozet/istatistik) → Yardım → Geri |
| `tools_page_flow_test.dart` | Araçlar sekmesi → Kartlara tıklama → Alt sayfa açma → Geri dön |
| `quick_add_from_tools_test.dart` | Form açılışlarını Ana Ekran (FAB) yerine "Tools/Araçlar" kısa yollarından başlatma stabilitesi |
| `keyboard_visibility_scroll_test.dart` | Bir formdaki en dip Input alanına tıklandığında ekran klavyesinin Scroll view'i itip görünürlüğünü koruması |
| `rapid_tap_debouncer_test.dart` | Spam/Throttle Testi: Kaydet butonuna aralıksız defalarca basarak uygulamanın kilitlenmesinin engellenmesi ("Debouncer") |
| `long_list_scroll_performance_test.dart` | Yüzlerce işlemin olduğu bir ListView içinde çok hızlı/sert `fling` (aşağı çekmeler) yaparak RAM sızıntısı olmadığını saptama kapasitesi |
| `negative_amount_input_test.dart` | Matematiksel Limitler: Tutar Input'una `-500` veya diğer geçersiz karakterler basılıp kaydetmeye basılma testi. |
| `long_press_context_menu_test.dart` | Etkileşim: Bir Liste (ListTile) elemanına uzun tıklandığında uygulamanın hata atmadan Context / Animasyon döngüsüne girmesi. |
| `pull_to_refresh_lists_test.dart` | Kaydırma Fiziği: Listenin en başındayken sertçe aşağı çekilerek (RefreshIndicator) tetiklenmesi ve Asenkron yenilemenin testi. |
| `fast_tab_switching_memory_test.dart` | Bellek İşkencesi: Alt menü (BottomNav) içindeki 4 sekme arasında saniyenin onda biri hızında Spam tıklamalar yaparak Engine'in kilitlenmemesi. |
| `empty_search_query_test.dart` | Regex/Search Kaosu: Arama formuna "!!^%%[]" gibi karmaşık, filtreleme motoruna aykırı karakterler girilip DB'nin test edilmesi. |
| `cancel_transaction_discard_test.dart` | State Temizliği: Formu yarım doldurup (İptal) diyerek geri çıkıldıktan sonra form tekrar açıldığında RAM'de hayalet verilerin (Silinmemiş state) kalmadığının testi. |
| `switch_account_dropdown_state_test.dart` | State Spam: Form alanındaki "Ödeme Yöntemi" Dropdown menüsünün hızla 4-5 kere değiştirilmesi ve UI kilidinin önlenmesi. |

#### 🔗 Cross-Feature & Network / Entegrasyon Testleri (12 test)

| Dosya | Kullanıcı Yolculuğu |
|---|---|
| `income_payment_integration_test.dart` | Gelir eklerken ödeme yöntemine bağla → Hesaplarım'da bakiye yansıması |
| `net_balance_flow_test.dart` | 10000 TL gelir ekle + 3000 TL gider ekle → Dashboard'da net bakiye doğrulama |
| `offline_network_currency_test.dart` | Varlık piyasası API yenileme isteğinde İnternet bağlantı zaman aşımı testlerinin Timeout Exception sarmalaması |
| `export_backup_file_flow_test.dart` | Dosya okuma/yazma Native I/O entegrasyonuna (Platform-Channel) geçiş yapıp JSON backup almaya çalışması |
| `multi_currency_conversion_test.dart` | Çapraz para çiftleriyle ($ USD harcama, € EUR varlık) gibi egzotik işlemlerde Matematiksel ondalıklı Parse'ın UI'ı yıkıp yıkmadığı |
| `massive_numbers_overflow_test.dart` | Kullanıcının Form alanlarına Astronomik rakamlar (999 Milyar vs) girdiğinde UI kartlarının / Formatter'ın Overflow çökmesi yaşamaması. |
| `expense_note_long_text_test.dart` | UI Kırıcı: Bir not alanına yüzlerce (500+) kelime girildiğinde TextOverflow (Ellipsis/Punto) Limitini test eder. |
| `chart_zero_division_prevention_test.dart` | Ekstrem Limit Durumu: Veritabanı boş (0) iken pasta/çizgi grafiklere geçip 0'a bölme hesaplama (Division by Zero) Crash'ini engelleme testi. |
| `rapid_transaction_sync_test.dart` | Saniyeler içinde Arka Arkaya (Async Race Condition) Veritabanına (Gelir + Gider) yazma (I/O) operasyonlarını sıraya dizme (Queue) çökme kontrolü. |
| `category_filter_empty_result_test.dart` | Filtre/Arama testlerinin Veri Dönmediğinde (Empty Array) sayfayı doğru bir NullState durumunda ayakta tutup (Out Of Bounds) indeks kazalarını önleme provaları. |
| `delete_all_transactions_flow_test.dart` | Matematiği Çökertme: Arka arkaya sonsuz silme (Wipe) yaparak Dashboard'un Null Reference yerine başarıyla Mutlak Sıfır (0.00) Hesaplaması testi. |
| `currency_locale_switch_test.dart` | Global Çökme Provası: Dil ayarlarından Localizasyon çekilip paranın USD Formatından (Sola $) TR (Sağa ₺) geçişinde Form yapısının esnekliği. |
| `deep_nested_navigation_test.dart` | Stack Kaosu: Ayarların alt menüsünün alt menüsündeki modal formlara kadar 5 katman inip arka arkaya `back()` rotasıyla UI Hafıza Kaşıntısı ve Sızıntı ölçümü. |

---

### 🗺️ Sayfa ↔ Test Eşleştirme Tablosu (47/47 = %100)

| Sayfa | Test Eden E2E Dosya(ları) |
|---|---|
| `home_page.dart` | `app_test`, `navigation_test`, `full_app_tour_test` |
| `dashboard_page.dart` | `dashboard_sync_test`, `budget_limit_warning_flow_test`, `net_balance_flow_test` |
| `login_page.dart` | `login_test`, `auth_flow_test` |
| `signup_page.dart` | `auth_flow_test`, `signup_multiuser_flow_test` |
| `user_list_page.dart` | `signup_multiuser_flow_test` |
| `expenses_page.dart` | `expense_flow_test`, `multi_expense_flow_test`, `expense_delete_balance_test` |
| `add_expense_page.dart` | `expense_flow_test`, `multi_expense_flow_test` |
| `expense_detail_page.dart` | `expense_edit_flow_test` |
| `recycle_bin_page.dart` | `recycle_bin_flow_test`, `complex_recycle_bin_flow_test` |
| `category_management_page.dart` | `category_management_flow_test` |
| `incomes_page.dart` | `income_flow_test`, `income_edit_flow_test` |
| `add_income_page.dart` | `income_flow_test` |
| `income_settings_page.dart` | `recurring_income_flow_test`, `income_category_flow_test` |
| `recurring_income_page.dart` | `recurring_income_flow_test` |
| `income_category_management_page.dart` | `income_category_flow_test` |
| `income_recycle_bin_page.dart` | `income_recycle_bin_flow_test` |
| `assets_page.dart` | `asset_flow_test`, `asset_offline_sync_test` |
| `add_asset_page.dart` | `asset_flow_test`, `asset_detail_flow_test` |
| `asset_detail_page.dart` | `asset_detail_flow_test` |
| `asset_recycle_bin_page.dart` | `asset_recycle_bin_flow_test` |
| `payment_methods_page.dart` | `payment_method_flow_test`, `payment_recycle_bin_flow_test` |
| `add_payment_method_page.dart` | `payment_method_flow_test` |
| `payment_method_detail_page.dart` | `payment_detail_flow_test` |
| `payment_method_recycle_bin_page.dart` | `payment_recycle_bin_flow_test` |
| `transfer_page.dart` | `transfer_flow_test` |
| `balance_card_page.dart` | `payment_detail_flow_test` |
| `debt_analysis_card_page.dart` | `payment_detail_flow_test` |
| `analysis_page.dart` | `analysis_flow_test` |
| `pdf_export_page.dart` | `export_report_flow_test` |
| `category_budget_page.dart` | `category_budget_flow_test` |
| `category_budget_detail_page.dart` | `category_budget_flow_test` |
| `main_settings_page.dart` | `settings_flow_test` |
| `appearance_page.dart` | `appearance_settings_flow_test` |
| `animations_settings_page.dart` | `appearance_settings_flow_test` |
| `haptic_settings_page.dart` | `appearance_settings_flow_test` |
| `language_settings_page.dart` | `language_change_flow_test` |
| `currency_settings_page.dart` | `currency_change_flow_test` |
| `expense_settings_page.dart` | `recurring_transaction_flow_test`, `category_management_flow_test` |
| `recurring_transactions_page.dart` | `recurring_transaction_flow_test` |
| `transfer_settings_page.dart` | `transfer_settings_flow_test` |
| `notification_settings_page.dart` | `notification_settings_flow_test` |
| `profile_page.dart` | `profile_update_flow_test` |
| `profile_settings_page.dart` | `profile_update_flow_test` |
| `about_support_page.dart` | `about_support_flow_test` |
| `voice_assistant_page.dart` | `voice_commands_flow_test` |
| `voice_commands_page.dart` | `voice_commands_flow_test` |
| `streak_page.dart` | `streak_page_flow_test` |
| `streak_help_page.dart` | `streak_page_flow_test` |
| `tools_page.dart` | `tools_page_flow_test` |

---

## ⚠️ Known Technical Debt

| Item | Severity | Location |
|---|---|---|
| `home_page.dart` is 763 lines | HIGH | `features/home/presentation/pages/` |
| Repository overlap (core vs feature) | MEDIUM | `core/repositories/` duplicates some feature repo interfaces |
| 4 features missing data/domain layers | MEDIUM | `analysis`, `dashboard`, `tools`, `home` |
| Mixed TR/EN naming in code | LOW | Legacy files use Turkish variable names |
| Settings/Category repos not on Firestore | MEDIUM | Streak migrated, Settings remain local |
| FirebaseAuthService not yet implemented | LOW | Auth uses local PIN + CloudSync via UID |

---

## 🚀 DI Registration Pattern

When adding a new feature, register in `injection_container.dart`:

```dart
// 1. Repository (lazy singleton — flag-based Hive/Firestore switch)
getIt.registerLazySingleton<FeatureRepository>(
  () => useFirestore
      ? FeatureRepositoryFirestore()
      : FeatureRepositoryImpl(),
);

// 2. Controller (factory - new instance each time)
getIt.registerFactory<FeatureController>(
  () => FeatureController(repository: getIt<FeatureRepository>()),
);
```

> **Note:** `useFirestore` is determined by `MigrationFlags.useFirestore` at app startup.

---

## 📐 Architecture Decision Records

| Decision | Choice | Rationale |
|---|---|---|
| State Management | Provider (not Riverpod/Bloc) | Simplicity, lower learning curve |
| Database (Local) | Hive (not SQLite/Drift) | No-schema flexibility, fast reads |
| Database (Cloud) | Firebase Firestore | Offline persistence, real-time sync, serverless |
| Error Tracking | Firebase Crashlytics | Hybrid mode (local Hive + cloud), automatic crash reporting |
| Auth (Local) | PIN + Biometric | Offline-first, no internet required |
| Auth (Cloud) | Firebase Auth (planned) | Email/password, user isolation via UID |
| Migration Strategy | Feature flags (`MigrationFlags`) | Zero-downtime switch, rollback capability |
| Navigation | go_router (not Navigator 2.0) | Declarative, auth guard support |
| DI | GetIt (not Injectable) | Manual control, no code generation |
| Localization | gen-l10n ARB | Official Flutter approach |
| Theme | Dark only | Brand identity, single theme simplicity |
