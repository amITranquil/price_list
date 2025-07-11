@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    Price List Windows Build Script
echo ========================================
echo.

REM [1/5] Proje temizleniyor
echo [1/5] Proje temizleniyor...
call flutter clean
if errorlevel 1 (
    echo HATA: Flutter clean başarısız! Devam ediliyor...
) else (
    echo ✓ Proje temizleme başarılı
)
echo.

REM [2/5] Bağımlılıklar yükleniyor
echo [2/5] Bağımlılıklar yükleniyor...
call flutter pub get
if errorlevel 1 (
    echo UYARI: Flutter pub get başarısız! Devam ediliyor...
    echo Eğer build başarısız olursa bu adımı tekrar deneyin.
) else (
    echo ✓ Bağımlılıklar başarıyla yüklendi
)
echo.

REM [3/5] Windows desktop desteği
echo [3/5] Windows desktop desteği etkinleştiriliyor...
call flutter config --enable-windows-desktop
if errorlevel 1 (
    echo UYARI: Windows desktop yapılandırması başarısız! Devam ediliyor...
) else (
    echo ✓ Windows desktop desteği etkinleştirildi
)
echo.

REM [4/5] Build
echo [4/5] Windows release build'i oluşturuluyor...
echo Bu işlem birkaç dakika sürebilir...
call flutter build windows --release
if errorlevel 1 (
    echo.
    echo ========================================
    echo          BUILD BAŞARISIZ!
    echo ========================================
    echo.
    echo Muhtemel nedenler:
    echo - Visual Studio C++ tools yüklü değil
    echo - Windows development environment eksik
    echo - Bağımlılıklar yüklenemedi
    echo.
    echo Önerilen çözümler:
    echo 1. flutter doctor komutunu çalıştırın
    echo 2. Visual Studio Community'yi C++ tools ile yükleyin
    echo 3. flutter pub get komutunu manuel çalıştırın
    echo.
    pause
    exit /b 1
) else (
    echo ✓ Windows build başarıyla tamamlandı
)
echo.

REM [5/5] Zip arşivi
echo [5/5] Zip arşivi oluşturuluyor...
if not exist "build\windows\x64\runner\Release" (
    echo HATA: Build klasörü bulunamadı!
    echo Build başarısız olmuş olabilir.
    pause
    exit /b 1
)

powershell -Command "Compress-Archive -Path 'build\windows\x64\runner\Release\*' -DestinationPath 'price_list_windows_v2.5.0.zip' -Force"
if errorlevel 1 (
    echo HATA: Zip oluşturma başarısız!
    echo PowerShell hatası veya dosya erişim sorunu olabilir.
    pause
    exit /b 1
) else (
    echo ✓ Zip arşivi başarıyla oluşturuldu
)
echo.

echo ========================================
echo        BUILD BAŞARIYLA TAMAMLANDI!
echo ========================================
echo.
echo Oluşturulan dosyalar:
echo - price_list_windows_v2.5.0.zip
echo - build\windows\x64\runner\Release\ klasörü
echo.
echo GitHub Release güncellemesi için:
echo gh release delete-asset v2.5.0 price_list_windows_v2.5.0.zip --yes
echo gh release upload v2.5.0 price_list_windows_v2.5.0.zip
echo.
pause
