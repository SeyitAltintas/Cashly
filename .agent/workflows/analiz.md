---
description: Projeyi analiz et, yapılanları listele ve öneriler sun
---

# Proje Analiz Komutu

Bu komut çalıştırıldığında aşağıdaki adımları gerçekleştir:

## 1. Proje Yapısını İncele
- Projenin klasör yapısını analiz et (`lib/` klasörünü ve alt klasörlerini tara)
- Mevcut feature'ları, sayfaları ve widget'ları listele
- Kullanılan paketleri `pubspec.yaml` dosyasından çıkar

## 2. Yapılan Şeyleri Listele
Projedeki mevcut özellikleri kategorilere ayırarak listele:

### Temel Özellikler
- Mevcut sayfaları ve ekranları listele
- Kullanıcı arayüzü bileşenlerini listele
- Veri modelleri ve servislerini listele

### Teknik Altyapı
- State management yaklaşımını belirle
- Veritabanı/storage çözümünü tespit et
- Navigasyon yapısını analiz et
- Tema ve stil yapısını incele

## 3. İyileştirme Önerileri Sun
Aşağıdaki kategorilerde öneriler sun: (zaten önceden yapılmış önerileri sunma)

### Kod Kalitesi
- Refactoring gerektiren alanları tespit et
- Tekrar eden kod bloklarını belirle
- Best practice ihlallerini tespit et

### Performans
- Olası performans iyileştirmelerini öner
- Gereksiz widget rebuild'leri tespit et
- Memory leak riskleri varsa belirt

### Kullanıcı Deneyimi (UX)
- UI/UX iyileştirme önerileri sun
- Eksik olabilecek kullanıcı dostu özellikleri öner
- Erişilebilirlik (accessibility) önerileri ver

### Yeni Özellik Önerileri
- Mevcut yapıya uygun yeni özellikler öner
- Kullanıcı deneyimini zenginleştirecek fikirler sun
- Mevcut özelliklerin genişletme olanaklarını belirt

## 4. Özet Rapor
- Projenin genel durumunu özetle
- Öncelikli iyileştirme alanlarını belirt
- Bir sonraki adımlar için yol haritası öner

---

**Not:** Analiz sonucunu Türkçe olarak, anlaşılır ve düzenli bir formatta sun. Markdown formatında kategorilenmiş listeler kullan.