# Listeden Hesaplama (Price List Calculator)

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)

> **Dil Seçenekleri / Language Options:**  
> 🇹🇷 [Türkçe](README.md) | 🇺🇸 [English](README_EN.md)

Döviz kurlarına dayalı fiyat hesaplama uygulaması. USD, EUR ve TL para birimlerinde orijinal fiyatları alarak, çoklu iskonto ve kar marjı hesaplamaları yapabilir.

## 📋 İçindekiler

- [Özellikler](#özellikler)
- [Ekran Görüntüleri](#ekran-görüntüleri)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Özellik Detayları](#özellik-detayları)
- [Geliştirme](#geliştirme)
- [Katkıda Bulunma](#katkıda-bulunma)
- [Lisans](#lisans)

## ✨ Özellikler

### 💱 Döviz Kuru Desteği
- **Gerçek Zamanlı Kurlar**: İş Bankası'ndan otomatik döviz kuru çekme
- **Çoklu Para Birimi**: USD ($), EUR (€) ve TL (₺) desteği
- **Manuel Kur Girişi**: İsteğe bağlı manuel döviz kuru düzenleme

### 🧮 Gelişmiş Hesaplama
- **Çoklu İskonto**: 3'e kadar farklı iskonto oranı uygulama
- **Kar Marjı**: Esnek kar marjı hesaplama
- **KDV Hesabı**: Otomatik %20 KDV dahil fiyat hesaplama
- **Vergi Dahil Fiyat**: Alış fiyatı + %20 vergi hesaplama

### 🔒 Güvenlik
- **PIN Koruması**: Alış fiyatlarını PIN ile koruma
- **Gizlilik**: Hassas bilgilerin güvenli saklanması
- **PIN Güncelleme**: PIN kodunu değiştirme imkanı

### 💾 Preset Sistemi
- **Ayar Kaydetme**: Sık kullanılan iskonto kombinasyonlarını kaydetme
- **Hızlı Uygulama**: Kaydedilen ayarları tek tıkla uygulama
- **Preset Yönetimi**: Kayıtlı ayarları düzenleme ve silme

### 🌍 Çoklu Dil Desteği
- **Türkçe** ve **İngilizce** arayüz
- **Dinamik Çeviri**: Uygulama içinde dil değiştirme
- **Yerelleştirme**: Tarih ve para formatları

### 📱 Platform Desteği
- **Android**: Tam özellik desteği
- **iOS**: Tam özellik desteği  
- **macOS**: Desktop desteği
- **Windows**: Desktop desteği

## 📱 Ekran Görüntüleri

### Ana Ekran

#### 💱 Döviz Kurları
- **USD:** 34.25 ₺
- **EUR:** 37.18 ₺

#### 🏷️ Ürün Fiyatlandırma
- **Orijinal Fiyat:** [Giriş Alanı] $
- **Para Birimi:** USD | EUR | TL

#### ⚙️ İskonto ve Kar Ayarları
- **İskonto 1:** 45%
- **İskonto 2:** 10%
- **İskonto 3:** 0%
- **Kar Marjı:** 40%

#### 📊 Hesaplama Sonuçları
- **Çevrilmiş Fiyat:** 3,425.00 ₺
- **Satış Fiyatı:** 1,918.20 ₺
- **KDV Dahil:** 2,301.84 ₺

## 🚀 Kurulum

### 📦 Hazır Uygulama İndirme

#### 🤖 Android
1. [Releases sayfasından](https://github.com/amITranquil/price_list/releases) `price_list_android_v2.0.0.apk` dosyasını indirin
2. Telefon ayarlarında "Bilinmeyen kaynaklar" seçeneğini etkinleştirin
3. APK dosyasını çalıştırıp kurun

#### 🍎 macOS
1. [Releases sayfasından](https://github.com/amITranquil/price_list/releases) `price_list_macos_v2.0.0.zip` dosyasını indirin
2. ZIP dosyasını çıkarın
3. `Price List.app` dosyasını Applications klasörüne sürükleyin
4. İlk açılışta "Güvenlik ve Gizlilik" ayarlarından izin verin

#### 🪟 Windows
1. [Releases sayfasından](https://github.com/amITranquil/price_list/releases) `price_list_windows_v2.0.0.zip` dosyasını indirin
2. ZIP dosyasını istediğiniz klasöre çıkarın
3. `price_list.exe` dosyasını çalıştırın
4. İlk açılışta Windows Defender uyarısı çıkarsa "Yine de çalıştır" seçeneğini tıklayın

### 🛠️ Geliştirici Kurulumu

#### Gereksinimler

- **Flutter SDK**: 3.2.5 veya üzeri
- **Dart SDK**: 3.2.5 veya üzeri
- **Android Studio** / **VS Code**
- **Git**

#### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/amITranquil/price_list.git
cd price_list
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
flutter run
```

### Platform Özel Kurulum

#### Android
```bash
flutter build apk --release
# veya
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

## 📖 Kullanım

### İlk Kurulum

1. **PIN Oluşturma**: Uygulamayı ilk açtığınızda bir PIN kodu oluşturmanız istenecek
2. **Dil Seçimi**: Sağ üst köşedeki dil simgesinden Türkçe/İngilizce seçebilirsiniz

### Temel Kullanım

#### 1. Döviz Kurlarını Kontrol Etme
- Uygulama otomatik olarak güncel kurları çeker
- 🔄 simgesine tıklayarak kurları yenileyebilirsiniz
- İsterseniz kurları manuel olarak düzenleyebilirsiniz

#### 2. Fiyat Hesaplama
```
1. Orijinal fiyatı girin (örn: 100)
2. Para birimini seçin (USD/EUR/TL)
3. İskonto oranlarını ayarlayın
4. Kar marjını belirleyin
5. "Fiyat Hesapla" butonuna tıklayın
```

#### 3. İskonto ve Kar Ayarları
- **İskonto 1-3**: Sıralı iskonto uygulaması
- **Kar Marjı**: Net alış fiyatı üzerine kar ekleme
- **Varsayılan Değerler**: İskonto 45%-10%-0%, Kar %40

#### 4. Sonuçları Görüntüleme
- **Çevrilmiş Fiyat**: Orijinal fiyat × Döviz kuru
- **Alış Fiyatı**: İskontolar uygulandıktan sonraki fiyat (PIN gerekli)
- **Satış Fiyatı**: Kar marjı eklenmiş fiyat
- **KDV Dahil**: %20 KDV eklenmiş nihai fiyat

### Gelişmiş Özellikler

#### Preset Sistemi

1. **Preset Kaydetme**:
   - İskonto ve kar ayarlarınızı yapın
   - Alt kısımda preset adı girin
   - "Mevcut Değerleri Kaydet" butonuna tıklayın

2. **Preset Kullanma**:
   - Dropdown menüden kaydettiğiniz preset'i seçin
   - Ayarlar otomatik olarak uygulanır

3. **Preset Silme**:
   - Silinecek preset'i seçin
   - "Seçileni Sil" butonuna tıklayın

#### PIN Koruması

1. **Alış Fiyatını Görüntüleme**:
   - PIN kodunuzu girin
   - "Göster" butonuna tıklayın

2. **PIN Değiştirme**:
   - Sağ üst köşedeki ⚙️ simgesine tıklayın
   - Mevcut PIN'i girin
   - Yeni PIN'i belirleyin

## 🔧 Özellik Detayları

### Hesaplama Formülü

```dart
// 1. Döviz çevirimi
çevrilmişFiyat = orijinalFiyat × dövizKuru

// 2. İskonto uygulaması (sıralı)
fiyat1 = orijinalFiyat × (1 - iskonto1/100)
fiyat2 = fiyat1 × (1 - iskonto2/100)
fiyat3 = fiyat2 × (1 - iskonto3/100)

// 3. Alış fiyatı (döviz kurlu)
alışFiyatı = fiyat3 × dövizKuru

// 4. Vergi dahil alış
alışVergiDahil = alışFiyatı × 1.20

// 5. Kar marjı ekleme
satışFiyatı = alışFiyatı × (1 + karMarjı/100)

// 6. KDV dahil satış
kdvDahilFiyat = satışFiyatı × 1.20
```

### Veri Saklama

- **Hive Database**: Yerel veri saklama
- **PIN Şifreleme**: Güvenli PIN saklama
- **Preset Yönetimi**: Kullanıcı ayarları
- **Dil Tercihi**: Seçilen dil saklama

### API Entegrasyonu

- **İş Bankası API**: Gerçek zamanlı döviz kurları
- **HTML Parsing**: Kur verisi çıkarma
- **Hata Yönetimi**: Bağlantı hatalarında fallback

## 🛠 Geliştirme

### Proje Yapısı

```
lib/
├── main.dart              # Uygulama giriş noktası
├── l10n/                  # Çoklu dil dosyaları
│   ├── app_en.arb        # İngilizce çeviriler
│   └── app_tr.arb        # Türkçe çeviriler
├── screens/               # Ekran widget'ları
│   ├── price_calculator_screen.dart
│   ├── create_pin_page.dart
│   └── update_pin_page.dart
└── utils/                 # Yardımcı sınıflar
    └── database_helper.dart
```

### Bağımlılıklar

```yaml
dependencies:
  flutter_localizations: # Çoklu dil desteği
  intl: ^0.19.0          # Sayı formatlaması
  http: ^1.2.2           # API çağrıları
  html: ^0.15.4          # HTML parsing
  window_manager: ^0.4.2  # Masaüstü pencere yönetimi
  hive: ^2.2.0           # Yerel veritabanı
  hive_flutter: ^1.1.0   # Flutter entegrasyonu
```

### Test Etme

```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Entegrasyon testler
flutter drive --target=test_driver/app.dart
```

### Build Etme

```bash
# Debug build
flutter run

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release

# Release build (macOS)
flutter build macos --release

# Release build (Windows)
flutter build windows --release
```

## 🤝 Katkıda Bulunma

### Katkı Süreci

1. **Fork** edin
2. **Feature branch** oluşturun (`git checkout -b feature/amazing-feature`)
3. **Commit** edin (`git commit -m 'Add amazing feature'`)
4. **Push** edin (`git push origin feature/amazing-feature`)
5. **Pull Request** açın

### Geliştirme Kuralları

- **Flutter/Dart** standartlarına uyun
- **Testler** yazın
- **Dokümantasyonu** güncelleyin
- **Commit mesajları** açıklayıcı olsun

### İssue Bildirme

Hata bildirimi veya özellik isteği için [GitHub Issues](https://github.com/amITranquil/price_list/issues) kullanın.

## 📄 Lisans

Bu proje özel kullanım içindir. Ticari kullanım yasaktır.

## 📞 İletişim

- **GitHub**: [@amITranquil](https://github.com/amITranquil)
- **Proje Linki**: [https://github.com/amITranquil/price_list](https://github.com/amITranquil/price_list)

## 🔄 Sürüm Geçmişi

### v2.0.0 (Güncel)
- ✅ TL para birimi desteği eklendi
- ✅ Dinamik para birimi simgeleri
- ✅ Geliştirilmiş kullanıcı arayüzü
- ✅ Çoklu dil desteği iyileştirildi
- ✅ Windows desktop platform desteği
- ✅ Tüm platformlar için unified release

### v1.0.2
- ✅ macOS ikon sorunları giderildi
- ✅ Flavor implementasyonu
- ✅ Windows ve macOS optimizasyonları

### v1.0.0
- ✅ İlk sürüm
- ✅ Temel hesaplama özellikleri
- ✅ PIN koruması
- ✅ Preset sistemi

---

*Bu uygulama Flutter framework'ü kullanılarak geliştirilmiştir.*
