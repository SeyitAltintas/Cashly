---
description: Veri yedekleme sistemini analiz eder, eksik veya gereksiz yedekleme öğelerini tespit eder
---

# Veri Yedekleme Analizi Workflow

Bu workflow, BackupService'in güncel durumunu analiz eder ve yedeklenmesi gereken yeni verileri veya artık kullanılmayan yedekleme öğelerini tespit eder.

## Adımlar

### 1. Mevcut BackupService Analizi
- `lib/services/backup_service.dart` dosyasını oku
- Şu anda yedeklenen verilerin listesini çıkar:
  - `data` bloğundaki veriler (harcamalar, gelirler, varlıklar vb.)
  - `settings` bloğundaki ayarlar (tema, haptic vb.)

### 2. Uygulama Genelinde Hive Box Taraması
- `Hive.openBox` kullanımlarını ara: `grep -r "Hive.openBox" lib/`
- Her bulunan box için:
  - Box adını not et
  - Hangi verileri sakladığını analiz et
  - BackupService'te yedeklenip yedeklenmediğini kontrol et

### 3. Eklenecek Yedeklemeleri Tespit Et
Şu kriterlere göre yeni yedekleme adaylarını belirle:
- Kullanıcı tercihleri (ayarlar)
- Uygulama verileri (finansal veriler)
- Özelleştirmeler (kategoriler, temalar)

### 4. Kaldırılacak Yedeklemeleri Tespit Et
- BackupService'te yedeklenen ama artık kullanılmayan verileri tespit et
- Kaldırılan özelliklerle ilgili yedekleme kodlarını kontrol et

### 5. Kullanıcıya Rapor Sun
Aşağıdaki formatta bir rapor oluştur:

```
## Yedekleme Analiz Raporu

### Mevcut Yedeklenen Veriler
- [liste]

### Yeni Eklenmesi Gereken Veriler
- [varsa liste, yoksa "Yok"]

### Kaldırılması Gereken Veriler
- [varsa liste, yoksa "Yok"]

### Öneriler
- [gerekli değişiklikler]
```

### 6. Kullanıcı Onayı
- Raporu kullanıcıya sun
- Kullanıcı onayı bekle
- Onay alındıktan sonra değişiklikleri uygula

## Notlar
- BackupService versiyonu değiştirilirse (örn: 1.1 → 1.2), geriye dönük uyumluluk korunmalı
- Yeni eklenen veriler için `settings` veya `data` bloğuna uygun şekilde ekleme yap
- Import işleminde null kontrolü yaparak eski yedek dosyalarıyla uyumluluk sağla
