# Windows Build Talimatları

Bu klasörde Windows için otomatik build scriptleri bulunmaktadır.

## Gereksinimler

1. **Flutter SDK** - Flutter'ın yüklü ve PATH'e eklenmiş olması
2. **Visual Studio** - Windows development tools ile
3. **Git** - Kodları çekmek için
4. **GitHub CLI** (opsiyonel) - Release güncellemesi için

## Kullanım

### 1. Adım: Windows Build Oluşturma
```bat
build_windows.bat
```

Bu script:
- Proje temizler (`flutter clean`)
- Bağımlılıkları yükler (`flutter pub get`)
- Windows desktop desteğini etkinleştirir
- Release build oluşturur (`flutter build windows --release`)
- Zip arşivi oluşturur (`price_list_windows_v2.1.0.zip`)

### 2. Adım: GitHub Release Güncelleme
```bat
update_github_release.bat
```

Bu script:
- Eski Windows dosyasını GitHub release'den siler
- Yeni Windows dosyasını GitHub release'e yükler

## Manuel Yöntem (GitHub CLI olmadan)

1. `build_windows.bat` çalıştırın
2. Oluşan `price_list_windows_v2.1.0.zip` dosyasını alın
3. [GitHub Releases](https://github.com/amITranquil/price_list/releases/tag/v2.0.0) sayfasına gidin
4. "Edit release" butonuna tıklayın
5. Eski Windows dosyasını silin
6. Yeni zip dosyasını sürükle-bırak ile yükleyin

## Sorun Giderme

### Flutter build hatası
- Visual Studio'nun C++ tools ile yüklü olduğundan emin olun
- `flutter doctor` komutu ile eksiklikleri kontrol edin

### PowerShell execution policy hatası
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### GitHub CLI authentication
```bat
gh auth login
```

## Build Çıktıları

Başarılı build sonrası:
- `build\windows\x64\runner\Release\` - Çalıştırılabilir dosyalar
- `price_list_windows_v2.1.0.zip` - Release için hazır arşiv

## Yeni Özellikler v2.1.0

- 🔄 Döviz kuru kaynağı seçimi (PHP/Direkt)
- 🌍 Tam çoklu dil desteği
- 🔧 VS Code iyileştirmeleri
- 🐛 macOS build sorunları düzeltildi