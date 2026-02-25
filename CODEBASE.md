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
| Database | Hive (NoSQL, key-value, local) |
| Navigation | go_router v14 |
| Localization | gen-l10n ARB (TR, EN) |
| Dart SDK | ^3.10.0 |
| Entry Point | `lib/main.dart` |
| Agent | `mobile-developer` (PRIMARY) |

---

## 📍 Critical Paths (Quick Lookup)

```
lib/main.dart                              → App entry, Hive init, DI init
lib/core/di/injection_container.dart       → ALL GetIt registrations (~300 lines)
lib/core/router/app_router.dart            → GoRouter config, auth guard
lib/core/router/route_names.dart           → Type-safe route constants
lib/core/theme/app_theme.dart              → Dark theme, colors, typography
lib/core/services/database_helper.dart     → Hive box operations
lib/core/domain/usecases/base_usecase.dart → UseCase<O,P>, Result<T>, NoParams
lib/core/exceptions/app_exceptions.dart    → 8 exception classes
lib/l10n/app_tr.arb                        → Turkish strings (~500 keys)
lib/l10n/app_en.arb                        → English strings (~500 keys)
pubspec.yaml                               → 27 runtime + 5 dev dependencies
```

---

## 🏗️ Architecture Contract

### Layer Rules (MUST follow)

```
Presentation → Domain → Data
     ↓             ↓         ↓
  Pages          Entities   Models/DTOs
  Controllers    UseCases   Repository Impl
  State          Repo IF    DataSources (Hive)
  Widgets
```

**Dependency Rule:** Outer layers depend on inner layers. NEVER import `data/` from `domain/`.

### Feature Module Template

Every feature under `lib/features/{name}/` SHOULD have:

```
{feature}/
├── index.dart                          # Barrel export
├── data/
│   ├── models/        → {name}_model.dart
│   └── repositories/  → {name}_repository_impl.dart
├── domain/
│   ├── entities/      → {name}_entity.dart (optional)
│   └── repositories/  → {name}_repository.dart (abstract)
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

| Feature | Purpose | Key Files |
|---|---|---|
| `auth` | Login, signup, multi-user, biometric | `auth_controller`, `user_model`, `user_entity` |
| `dashboard` | Overview cards, budget status, recent txns | `dashboard_controller`, 6 card widgets |
| `expenses` | CRUD, categories, filters, recycle bin | `expenses_controller`, `expense_repository_impl` |
| `income` | CRUD, categories, recurring, recycle bin | `incomes_controller`, `income_repository_impl` |
| `assets` | Gold/forex/crypto tracking, live prices | `assets_controller`, `asset_model`, API prices |
| `payment_methods` | Cards, cash, transfers, scheduled transfers | `payment_methods_controller`, `transfer_model` |
| `analysis` | Charts (fl_chart), PDF export | `analysis_controller`, `pdf_export_page` |
| `streak` | Gamification, daily streaks, badges | `streak_controller`, `streak_service`, celebration dialog |
| `settings` | 6 sub-modules (appearance, finance, voice, profile, notifications, support) | ~42 files |
| `tools` | Quick access menu | `tools_controller`, `tools_page` |
| `home` | 3-tab bottom nav (Tools, Dashboard, Profile) | `home_page` (763 lines — refactor candidate) |

---

## 🔗 File Dependency Map

### Core → Feature Dependencies

When modifying these core files, check ALL listed dependents:

| Core File | Dependent Features |
|---|---|
| `injection_container.dart` | **ALL** — every controller/repo is registered here |
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

### Hive Box Schema

| Box Name | Purpose |
|---|---|
| `cashly_box` | Main data (expenses, incomes, assets, payment methods, settings per user) |
| `settings` | App-level settings (theme, currency, animation toggles) |

### Key Naming Convention (User-scoped)

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
- **Repository Impl:** `{name}_repository_impl.dart`
- **Barrel Exports:** `index.dart` in each feature root

### Code Language
- **Variable/function names:** Turkish naming in some legacy code (e.g., `harcamalar`, `butce`), English in newer code
- **Comments:** Turkish (legacy) + English (newer)
- **UI strings:** Always localized via ARB (never hardcoded)

---

## 🧪 Test Structure

```
test/helpers/     → mock_hive.dart, test_helpers.dart (shared utilities)
test/unit/        → 25 files (controllers, services, business logic)
test/widget/      → 21 files (UI component tests)
integration_test/ → 11 files (E2E flows: auth, expense, income, nav, settings)
```

**Test naming:** `{source_file}_test.dart`
**Mock framework:** `mocktail`
**CI:** GitHub Actions (`ci.yml`) → analyze + test + coverage + conditional APK build

---

## ⚠️ Known Technical Debt

| Item | Severity | Location |
|---|---|---|
| `home_page.dart` is 763 lines | HIGH | `features/home/presentation/pages/` |
| Repository overlap (core vs feature) | MEDIUM | `core/repositories/` duplicates some feature repo interfaces |
| 4 features missing data/domain layers | MEDIUM | `analysis`, `dashboard`, `tools`, `home` |
| Mixed TR/EN naming in code | LOW | Legacy files use Turkish variable names |

---

## 🚀 DI Registration Pattern

When adding a new feature, register in `injection_container.dart`:

```dart
// 1. Repository (lazy singleton)
getIt.registerLazySingleton<FeatureRepository>(
  () => FeatureRepositoryImpl(),
);

// 2. Controller (factory - new instance each time)
getIt.registerFactory<FeatureController>(
  () => FeatureController(repository: getIt<FeatureRepository>()),
);
```

---

## 📐 Architecture Decision Records

| Decision | Choice | Rationale |
|---|---|---|
| State Management | Provider (not Riverpod/Bloc) | Simplicity, lower learning curve |
| Database | Hive (not SQLite/Drift) | No-schema flexibility, fast reads |
| Navigation | go_router (not Navigator 2.0) | Declarative, auth guard support |
| DI | GetIt (not Injectable) | Manual control, no code generation |
| Localization | gen-l10n ARB | Official Flutter approach |
| Theme | Dark only | Brand identity, single theme simplicity |
